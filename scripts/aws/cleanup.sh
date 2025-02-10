#!/usr/bin/env sh
echo "=== Cleaning up AWS resources ==="

# Delete ECS services
echo "Deleting ECS services..."
aws ecs update-service --no-cli-pager --cluster language-vows --service backend --desired-count 0 || true
aws ecs update-service --no-cli-pager --cluster language-vows --service frontend --desired-count 0 || true
aws ecs delete-service --no-cli-pager --cluster language-vows --service backend || true
aws ecs delete-service --no-cli-pager --cluster language-vows --service frontend || true

# Delete task definitions
echo "Deregistering task definitions..."
aws ecs list-task-definitions --no-cli-pager --family-prefix language-vows \
    --query 'taskDefinitionArns[]' \
    --output text | tr '\t' '\n' | \
    xargs -I {} aws ecs deregister-task-definition --no-cli-pager --task-definition {} || true

# Delete secrets
echo "Deleting secrets..."
aws secretsmanager delete-secret --no-cli-pager \
    --secret-id language-vows/db-password \
    --force-delete-without-recovery || true

echo "Cleanup complete" 