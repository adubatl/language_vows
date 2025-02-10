#!/bin/bash
if [ ! -x "$(command -v aws)" ]; then
    echo "Error: aws CLI not found or not executable"
    exit 1
fi

if [ ! -f ".env.aws" ] && [ ! -f ".env.aws.template" ]; then
    echo "Error: Must be run from project root directory"
    exit 1
fi

set -e

if [ -f .env.aws ]; then
    source .env.aws
fi

handle_setup() {
    local resource=$1
    local command=$2
    local output
    
    output=$($command 2>&1)
    if [ $? -eq 0 ]; then
        echo "Created: $resource"
        return 0
    else
        case "$output" in
            *"already exists"* | \
            *"AlreadyExistsException"* | \
            *"has been taken"* | \
            *"RepositoryAlreadyExistsException"*)
                echo "Using existing: $resource"
                return 0
                ;;
            *"LimitExceeded"*)
                if [[ $resource == *"Internet Gateway"* ]]; then
                    IGW_ID=$(aws ec2 describe-internet-gateways \
                        --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
                        --query 'InternetGateways[0].InternetGatewayId' \
                        --output text)
                    if [ -n "$IGW_ID" ] && [ "$IGW_ID" != "None" ]; then
                        echo "Using existing IGW: $IGW_ID"
                        return 0
                    fi
                fi
                echo "$output"
                return 1
                ;;
            *)
                echo "$output"
                return 1
                ;;
        esac
    fi
}

handle_setup "ECS Service-Linked Role" "aws iam get-role --role-name AWSServiceRoleForECS" || \
handle_setup "ECS Service-Linked Role" "aws iam create-service-linked-role --aws-service-name ecs.amazonaws.com"

handle_setup "ECR Frontend Repository" "aws ecr create-repository \
    --repository-name ${PROJECT_NAME}-frontend \
    --image-scanning-configuration scanOnPush=true" || true

handle_setup "ECR Backend Repository" "aws ecr create-repository \
    --repository-name ${PROJECT_NAME}-backend \
    --image-scanning-configuration scanOnPush=true" || true

sleep 10

handle_setup "ECS Cluster" "aws ecs create-cluster \
    --cluster-name ${PROJECT_NAME} \
    --capacity-providers FARGATE \
    --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1" || exit 1

handle_setup "CloudWatch Frontend Log Group" "aws logs create-log-group --log-group-name ecs/${PROJECT_NAME}-frontend" || true
handle_setup "CloudWatch Backend Log Group" "aws logs create-log-group --log-group-name ecs/${PROJECT_NAME}-backend" || true

VPC_ID=$(aws ec2 describe-vpcs \
    --filters "Name=tag:Name,Values=${PROJECT_NAME}-vpc" \
    --query 'Vpcs[0].VpcId' \
    --output text)

if [ "$VPC_ID" != "None" ] && [ -n "$VPC_ID" ]; then
    echo "VPC SKIPPED Using existing: $VPC_ID"
else
    handle_setup "VPC Creation" "aws ec2 create-vpc \
        --cidr-block $VPC_CIDR \
        --tag-specifications \"ResourceType=vpc,Tags=[{Key=Name,Value=${PROJECT_NAME}-vpc}]\"" || exit 1
    
    VPC_ID=$(aws ec2 describe-vpcs \
        --filters "Name=tag:Name,Values=${PROJECT_NAME}-vpc" \
        --query 'Vpcs[0].VpcId' \
        --output text)
fi

IGW_ID=$(aws ec2 describe-internet-gateways \
    --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
    --query 'InternetGateways[0].InternetGatewayId' \
    --output text)

if [ "$IGW_ID" != "None" ] && [ -n "$IGW_ID" ]; then
    echo "Using existing Internet Gateway: $IGW_ID"
else
    handle_setup "Internet Gateway" "aws ec2 create-internet-gateway \
        --tag-specifications ResourceType=internet-gateway,Tags=[{Key=Name,Value=${PROJECT_NAME}-igw}]" || exit 1

    IGW_ID=$(aws ec2 describe-internet-gateways \
        --filters "Name=tag:Name,Values=${PROJECT_NAME}-igw" \
        --query 'InternetGateways[0].InternetGatewayId' \
        --output text)
fi

get_or_create_subnet() {
    local name=$1
    local cidr=$2
    local az=$3
    local type=$4  # public or private

    local subnet_id=$(aws ec2 describe-subnets \
        --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=${PROJECT_NAME}-${type}-${name}" \
        --query 'Subnets[0].SubnetId' \
        --output text)

    if [ "$subnet_id" != "None" ] && [ -n "$subnet_id" ]; then
        echo "Using existing subnet: $subnet_id" >&2
        printf "%s" "$subnet_id"
        return 0
    fi

    subnet_id=$(aws ec2 create-subnet \
        --vpc-id $VPC_ID \
        --cidr-block $cidr \
        --availability-zone $az \
        --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=${PROJECT_NAME}-${type}-${name}}]" \
        --query 'Subnet.SubnetId' \
        --output text)
    
    echo "Created new subnet: $subnet_id" >&2
    printf "%s" "$subnet_id"
}

AZS=($(aws ec2 describe-availability-zones \
    --query 'AvailabilityZones[0:2].ZoneName' \
    --output text))

echo "Setting up public subnets..." >&2
PUBLIC_SUBNET_1=$(get_or_create_subnet "1" "$SUBNET_1_CIDR" "${AZS[0]}" "public")
PUBLIC_SUBNET_2=$(get_or_create_subnet "2" "$SUBNET_2_CIDR" "${AZS[1]}" "public")

echo "Setting up private subnets..." >&2
PRIVATE_SUBNET_1=$(get_or_create_subnet "1" "$SUBNET_3_CIDR" "${AZS[0]}" "private")
PRIVATE_SUBNET_2=$(get_or_create_subnet "2" "$SUBNET_4_CIDR" "${AZS[1]}" "private")

PUBLIC_RTB=$(aws ec2 describe-route-tables \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=${PROJECT_NAME}-public-rtb" \
    --query 'RouteTables[0].RouteTableId' \
    --output text)

if [ "$PUBLIC_RTB" = "None" ] || [ -z "$PUBLIC_RTB" ]; then
    echo "Creating public route table..."
    PUBLIC_RTB=$(aws ec2 create-route-table \
        --vpc-id $VPC_ID \
        --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=${PROJECT_NAME}-public-rtb}]" \
        --query 'RouteTable.RouteTableId' \
        --output text)

    aws ec2 create-route \
        --route-table-id $PUBLIC_RTB \
        --destination-cidr-block 0.0.0.0/0 \
        --gateway-id $IGW_ID
else
    echo "Using existing route table: $PUBLIC_RTB"
fi

echo "Associating public subnets with route table..."
aws ec2 associate-route-table \
    --subnet-id $PUBLIC_SUBNET_1 \
    --route-table-id $PUBLIC_RTB || true

aws ec2 associate-route-table \
    --subnet-id $PUBLIC_SUBNET_2 \
    --route-table-id $PUBLIC_RTB || true

echo "Enabling auto-assign public IPs for public subnets..."
aws ec2 modify-subnet-attribute \
    --subnet-id $PUBLIC_SUBNET_1 \
    --map-public-ip-on-launch || true

aws ec2 modify-subnet-attribute \
    --subnet-id $PUBLIC_SUBNET_2 \
    --map-public-ip-on-launch || true

DB_SUBNET_GROUP=$(aws rds describe-db-subnet-groups \
    --db-subnet-group-name ${PROJECT_NAME}-db-subnet \
    --query 'DBSubnetGroups[0].DBSubnetGroupName' \
    --output text 2>/dev/null || echo "")

if [ -z "$DB_SUBNET_GROUP" ]; then
    echo "Creating DB subnet group..."
    aws rds create-db-subnet-group \
        --db-subnet-group-name ${PROJECT_NAME}-db-subnet \
        --db-subnet-group-description "Subnet group for ${PROJECT_NAME} RDS" \
        --subnet-ids $PRIVATE_SUBNET_1 $PRIVATE_SUBNET_2 \
        --tags Key=Project,Value=${PROJECT_NAME}
else
    echo "Using existing DB subnet group: $DB_SUBNET_GROUP"
fi

echo "Checking RDS instance..."
RDS_EXISTS=$(aws rds describe-db-instances \
    --db-instance-identifier ${PROJECT_NAME}-db \
    --query 'DBInstances[0].DBInstanceIdentifier' \
    --output text 2>/dev/null || echo "")

if [ -n "$RDS_EXISTS" ] && [ "$RDS_EXISTS" != "None" ]; then
    echo "Using existing RDS instance: $RDS_EXISTS"
    DB_PASSWORD=$(aws secretsmanager get-secret-value \
        --secret-id ${PROJECT_NAME}/db-password \
        --query 'SecretString' \
        --output text 2>/dev/null || echo "")
else
    echo "Creating new RDS instance (estimated time: 5-10 minutes)..."
    DB_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9#%^*+=' | fold -w 16 | head -n 1)

    aws rds create-db-instance \
        --db-instance-identifier ${PROJECT_NAME}-db \
        --db-instance-class db.t3.micro \
        --engine postgres \
        --master-username postgres \
        --master-user-password "$DB_PASSWORD" \
        --allocated-storage 20 \
        --backup-retention-period 7 \
        --no-multi-az \
        --auto-minor-version-upgrade \
        --no-publicly-accessible \
        --db-subnet-group-name ${PROJECT_NAME}-db-subnet \
        --tags Key=Project,Value=${PROJECT_NAME} || {
            echo "Failed to create RDS instance"
            exit 1
        }
    echo "RDS instance creation initiated successfully"
fi

cat > .env.aws.generated << EOL
# AWS Infrastructure Configuration
# Generated on $(date)

# VPC Configuration
VPC_ID=${VPC_ID}
PUBLIC_SUBNET_1=${PUBLIC_SUBNET_1}
PUBLIC_SUBNET_2=${PUBLIC_SUBNET_2}
PRIVATE_SUBNET_1=${PRIVATE_SUBNET_1}
PRIVATE_SUBNET_2=${PRIVATE_SUBNET_2}

# Database Credentials
DB_PASSWORD=${DB_PASSWORD}
EOL

echo "Infrastructure configuration saved to .env.aws.generated" 