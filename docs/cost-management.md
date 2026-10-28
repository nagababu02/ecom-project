# Cloud cost and cleanup guide

## Before creating resources

1. Choose a dedicated AWS account or isolated lab environment.
2. Select one AWS region and keep resources there unless the design requires otherwise.
3. Enable billing visibility and create an AWS Budget with alerts at sensible thresholds.
4. Understand that budget notifications are alerts, not guaranteed spending limits.
5. Review the Terraform plan and pricing for every managed service.
6. Use temporary lab resources and record their names/tags so they can be found later.

## Cost drivers to check

Actual pricing depends on region, usage, data transfer and configuration. Check current AWS pricing before deployment.

- EKS cluster control-plane charges may apply while a cluster exists.
- EC2 worker nodes, EBS volumes and snapshots can continue to cost money.
- Load balancers, public IPv4 addresses and NAT Gateways may incur hourly and data-processing charges.
- ECR storage and image transfers can incur charges.
- CloudWatch logs, metrics and alarms may incur charges.
- RDS, if added, can incur instance, storage and backup charges.
- Data transfer and resources left behind after a test can add unexpected costs.

## Safer learning sequence

1. Run format, validation and unit tests locally.
2. Build images locally.
3. Test Kubernetes manifests with local tooling or a local cluster.
4. Review Terraform formatting, validation and plan output.
5. Only then deploy a small AWS environment with an explicit budget and time window.
6. Destroy the environment after testing and verify the resources are removed.

## Teardown checklist

- Run Terraform destroy from the correct environment and state, after reviewing its plan.
- Check for leftover load balancers, NAT Gateways, public IPs, EBS volumes/snapshots, ECR images, log groups, databases and other separately managed resources.
- Check the AWS console and Cost Explorer after teardown; billing data can be delayed.
- Preserve Terraform state and important evidence until cleanup is verified. Do not delete state first.

Never run destructive commands against a shared or production account. Confirm the AWS account, region, workspace and state before any apply or destroy.
