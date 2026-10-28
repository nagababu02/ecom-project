locals {
  cluster_name = "ecom-eks"
  region       = "us-east-1"
  vpc_cidr     = "10.81.0.0/16"

  common_tags = {
    Project     = "ecom-project"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.0"

  name = "${local.cluster_name}-vpc"
  cidr = local.vpc_cidr

  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

  private_subnets = ["10.81.1.0/24", "10.81.2.0/24", "10.81.3.0/24"]
  public_subnets  = ["10.81.11.0/24", "10.81.12.0/24", "10.81.13.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = local.common_tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.26.0"

  name               = local.cluster_name
  kubernetes_version = "1.33"

  endpoint_public_access = true

  addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    ecom_nodes = {
      name           = "ecom-ng"
      instance_types = ["t3.small"]

      min_size     = 2
      max_size     = 4
      desired_size = 2

      capacity_type = "ON_DEMAND"

      labels = {
        workload = "ecom"
      }

      tags = local.common_tags
    }
  }

  enable_cluster_creator_admin_permissions = true

  tags = local.common_tags
}

resource "aws_ecr_repository" "product_service" {
  name                 = "ecom/product-service"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = local.common_tags
}

resource "aws_ecr_lifecycle_policy" "product_service" {
  repository = aws_ecr_repository.product_service.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep the latest 20 tagged images"
        selection = {
          tagStatus   = "tagged"
          tagPrefixList = ["v"]
          countType   = "imageCountMoreThan"
          countNumber = 20
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Remove untagged images"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
