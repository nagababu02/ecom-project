# Terraform AWS EKS + ECR + Kubernetes Deployment

This directory provisions the AWS infrastructure and deploys the `product-service` workload.

## What Terraform creates

- VPC across three Availability Zones
- Public and private subnets
- NAT gateway
- Amazon EKS cluster
- EKS managed node group with two `t3.small` nodes initially
- EKS core add-ons
- Amazon ECR repository for `product-service`
- ECR image scanning on push
- ECR lifecycle policy
- Kubernetes `ecom` namespace
- `product-service` ConfigMap
- `product-service` Deployment
- ClusterIP Service
- CPU-based HPA

The AWS provider and the EKS module are pinned to current major/minor-compatible versions so the infrastructure remains reproducible. Terraform AWS Provider 6.x supports EKS and ECR resources, while the EKS module provides managed EKS cluster and node-group resources.

## Important cost note

`terraform apply` creates billable AWS infrastructure, including EKS and networking/NAT resources. Review `terraform plan` and the AWS pricing for your account before applying. This repository does **not** automatically run `terraform apply` from GitHub Actions.

## Prerequisites

- Terraform >= 1.6
- AWS CLI configured locally
- Docker installed
- kubectl installed
- AWS credentials with permissions to create EKS, VPC, IAM and ECR resources

Do not put AWS access keys in Terraform files or GitHub source code.

## Deploy

From the repository root:

```bash
cd terraform
terraform init
terraform fmt -check
terraform validate
terraform plan
```

Only after reviewing the plan:

```bash
terraform apply
```

Terraform prints the EKS cluster name and ECR repository URL after a successful apply.

## Build and push the image

Get the repository URL:

```bash
terraform output -raw ecr_repository_url
```

Log in to ECR:

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(terraform output -raw ecr_repository_url | sed 's#/ecom/product-service##')
```

Build the application image:

```bash
docker build -t ecom-product-service:v1 application/product-service
```

Tag it with the ECR repository URL:

```bash
docker tag ecom-product-service:v1 $(terraform output -raw ecr_repository_url):v1
```

Push it:

```bash
docker push $(terraform output -raw ecr_repository_url):v1
```

The Kubernetes deployment created by Terraform references the `v1` image tag.

## Connect kubectl to EKS

```bash
aws eks update-kubeconfig --region us-east-1 --name $(terraform output -raw eks_cluster_name)
```

Verify:

```bash
kubectl get nodes
kubectl get pods -n ecom
kubectl get svc -n ecom
kubectl get hpa -n ecom
```

## Ingress / AWS Load Balancer Controller

The repository also contains an ALB Ingress manifest under `kubernetes/base/ingress.yaml`. The EKS cluster needs the AWS Load Balancer Controller before that Ingress can create an AWS Application Load Balancer. Installing that controller is intentionally kept as a separate infrastructure step rather than silently creating additional IAM/Helm resources.

After the controller is installed, the GitOps/Kubernetes manifests can be applied with:

```bash
kubectl apply -k kubernetes/base
```

For the Terraform-managed deployment, use the Terraform resources in `kubernetes.tf` as the source of truth instead of creating duplicate Deployment/Service/HPA objects with `kubectl apply`.

## Destroy

When the lab is finished, review the resources first and then run:

```bash
terraform destroy
```

This removes the infrastructure managed by this Terraform directory. ECR image data and other retained AWS resources should be checked separately if they are configured outside this stack.
