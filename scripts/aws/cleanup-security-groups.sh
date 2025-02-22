#!/usr/bin/env sh
. ./scripts/utils/status.sh

print_status_header "$DEFAULT_FORMAT" \
    "RESOURCE STATUS DETAILS" \
    "-------- ------ -------" \
    "Security Groups Cleanup"

VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=language-vows-vpc" --query 'Vpcs[0].VpcId' --output text)
if [ -z "$VPC_ID" ] || [ "$VPC_ID" = "None" ]; then
    handle_status "VPC" "false"
    exit 0
fi

DEFAULT_SG=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=default" --query 'SecurityGroups[0].GroupId' --output text)
if [ -n "$DEFAULT_SG" ] && [ "$DEFAULT_SG" != "None" ]; then
    handle_status "Default SG Ingress" "aws ec2 revoke-security-group-ingress --group-id $DEFAULT_SG --ip-permissions \"\$(aws ec2 describe-security-groups --group-ids $DEFAULT_SG --query 'SecurityGroups[0].IpPermissions' --output json)\" 2>/dev/null"
    handle_status "Default SG Egress" "aws ec2 revoke-security-group-egress --group-id $DEFAULT_SG --ip-permissions \"\$(aws ec2 describe-security-groups --group-ids $DEFAULT_SG --query 'SecurityGroups[0].IpPermissionsEgress' --output json)\" 2>/dev/null"
fi

SG_IDS=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=language-vows-*" --query 'SecurityGroups[].GroupId' --output text)

for SG_ID in $SG_IDS; do
    handle_status "SG Ingress ($SG_ID)" "aws ec2 revoke-security-group-ingress --group-id $SG_ID --ip-permissions \"\$(aws ec2 describe-security-groups --group-ids $SG_ID --query 'SecurityGroups[0].IpPermissions' --output json)\" 2>/dev/null"
    handle_status "SG Egress ($SG_ID)" "aws ec2 revoke-security-group-egress --group-id $SG_ID --ip-permissions \"\$(aws ec2 describe-security-groups --group-ids $SG_ID --query 'SecurityGroups[0].IpPermissionsEgress' --output json)\" 2>/dev/null"
    
    ENIs=$(aws ec2 describe-network-interfaces --filters "Name=group-id,Values=$SG_ID" --query 'NetworkInterfaces[].NetworkInterfaceId' --output text)
    if [ -n "$ENIs" ] && [ "$ENIs" != "None" ]; then
        for ENI in $ENIs; do
            handle_status "ENI Detach ($ENI)" "aws ec2 detach-network-interface --attachment-id \$(aws ec2 describe-network-interfaces --network-interface-ids $ENI --query 'NetworkInterfaces[0].Attachment.AttachmentId' --output text) --force"
            handle_status "ENI Delete ($ENI)" "aws ec2 delete-network-interface --network-interface-id $ENI"
        done
    fi
    
    handle_status "SG Delete ($SG_ID)" "aws ec2 delete-security-group --group-id $SG_ID"
done

printf "\nSecurity groups cleanup completed.\n" 