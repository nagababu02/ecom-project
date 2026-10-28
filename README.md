# E-Commerce DevOps Platform on AWS

[![CI](https://github.com/nagababu02/ecom-project/actions/workflows/ci.yml/badge.svg)](https://github.com/nagababu02/ecom-project/actions/workflows/ci.yml)
![Infrastructure](https://img.shields.io/badge/Infrastructure-Terraform-7B42BC)
![Containers](https://img.shields.io/badge/Containers-Docker-2496ED)
![Orchestration](https://img.shields.io/badge/Orchestration-Kubernetes-326CE5)
![Cloud](https://img.shields.io/badge/Cloud-AWS-FF9900)

An end-to-end portfolio project demonstrating how to build, secure, deploy, and observe an e-commerce microservices application using modern DevOps practices.

## Goals

- Build and validate application code through automated CI.
- Package services as reproducible Docker images.
- Provision AWS infrastructure with Terraform.
- Deploy container workloads to Amazon EKS using Kubernetes.
- Store immutable application images in Amazon ECR.
- Add quality and vulnerability checks to the delivery workflow.
- Use GitOps deployment patterns with Argo CD.
- Add metrics, dashboards, alerting, and operational runbooks.
- Keep cloud spend visible and provide explicit teardown instructions.

## Implemented application

The first runnable component is a Java 17 / Spring Boot product service.

- `GET /api/products` — list sample products
- `GET /api/products/{id}` — retrieve one product
- `GET /actuator/health` — application health status
- Maven integration tests cover list, lookup, not-found, and health behavior.
- A multi-stage Dockerfile builds the service and runs it as a non-root user.

See [the product service guide](application/product-service/README.md) for local commands.

## Kubernetes manifests

Kubernetes deployment manifests are committed under [kubernetes/](kubernetes/).

The base includes a Namespace, ConfigMap, ClusterIP Service, two-replica Deployment, rolling-update strategy, resource requests/limits, startup/readiness/liveness probes, container hardening, HorizontalPodAutoscaler, AWS Load Balancer Controller Ingress, and Kustomize configuration.

See [the Kubernetes guide](kubernetes/README.md) for rendering, deployment, and EKS prerequisites.

## Terraform AWS deployment

Terraform is now committed under [terraform/](terraform/).

The Terraform stack is designed to provision:

- Three-AZ VPC with public/private subnets and NAT gateway
- Amazon EKS cluster with managed node group
- EKS core add-ons
- Amazon ECR repository for `product-service`
- ECR scan-on-push and lifecycle policy
- Kubernetes namespace, Deployment, Service and HPA for `product-service`

The ECR repository uses immutable tags and the Kubernetes Deployment references `v1` as the initial image tag. Build and push the `v1` image before expecting pods to become Ready.

**Important:** Terraform code is committed, but this repository does not automatically run `terraform apply`. EKS, NAT Gateway, EC2 worker nodes and related AWS resources can incur charges. Review `terraform plan` and your AWS pricing before applying.

See [the Terraform deployment guide](terraform/README.md) for the exact workflow.

## Target architecture

~~~text
Developer -> GitHub -> GitHub Actions / Jenkins
                         |
                         v
                 Build + Unit Tests
                         |
               Quality / Security Scan
                         |
                    Docker Image
                         |
                    Amazon ECR
                         |
                  Amazon EKS
                 /           \\
          Kubernetes       Argo CD
          Services         GitOps sync
                 \\           /
                 Metrics / Logs
                  Prometheus
                    Grafana

Terraform -> VPC -> EKS -> Managed Nodes
                 |
                 +-> ECR
                 +-> Kubernetes Deployment / Service / HPA
~~~

See [the architecture notes](docs/architecture.md) for the intended components and delivery flow.

## Technology stack

| Area | Technologies |
|---|---|
| Source control | Git, GitHub |
| CI | GitHub Actions; Jenkins pipeline examples |
| Build | Maven, Java 17, Spring Boot |
| Containers | Docker |
| Image registry | Amazon ECR |
| Infrastructure as Code | Terraform |
| Cloud | AWS (VPC, IAM, EKS, EC2, load balancing, CloudWatch as applicable) |
| Orchestration | Kubernetes |
| GitOps | Argo CD |
| Quality and security | SonarQube, Trivy |
| Observability | Prometheus, Grafana |
| Operations | Runbooks, health checks, rollback and cost controls |

## Repository layout

~~~text
.
├── .github/workflows/   # Automated build, test and validation
├── application/
│   └── product-service/ # Spring Boot API, tests and Dockerfile
├── jenkins/             # Jenkins pipeline and guidance
├── kubernetes/           # Kubernetes workload manifests
├── terraform/            # VPC, EKS, ECR and Kubernetes deployment
├── argocd/               # GitOps application definitions (planned)
├── monitoring/           # Metrics and dashboard configuration (planned)
└── docs/                 # Architecture, deployment, operations and cost notes
~~~

## Getting started

### Prerequisites

- Git
- JDK 17 and Maven 3.9 or compatible
- Docker Desktop or Docker Engine
- Terraform >= 1.6
- kubectl
- AWS CLI configured locally

### Build and test locally

From the repository root:

~~~bash
mvn -B -f application/product-service/pom.xml clean verify
docker build -t ecom-product-service:local -f application/product-service/Dockerfile application/product-service
docker run --rm -p 8080:8080 ecom-product-service:local
~~~

Try `http://localhost:8080/api/products` and `http://localhost:8080/actuator/health`.

### Run with Docker Compose

~~~bash
docker compose up --build
~~~

Stop with `Ctrl+C`, then run `docker compose down`.

### Deploy AWS infrastructure

~~~bash
cd terraform
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
~~~

Review the plan before applying. After the apply, follow [terraform/README.md](terraform/README.md) to push the Docker image to ECR and connect kubectl to EKS.

### Local-first workflow

1. Clone the repository.
2. Review architecture and cost guidance.
3. Run application tests and Docker validation locally.
4. Render and review Kubernetes manifests.
5. Review the Terraform plan, permissions, expected costs and teardown procedure.
6. Provision AWS deliberately.
7. Push the immutable application image to ECR.
8. Verify the EKS Deployment, Service and HPA.

AWS resources are **not** created merely by cloning this repository.

## Cost and security guardrails

- Never commit AWS credentials, tokens, passwords, private keys, or real application secrets.
- Use GitHub Actions OIDC/secrets or an appropriate secret manager for sensitive values.
- Review Terraform plans before applying them.
- Set AWS Budgets and billing alerts before launching paid resources; alerts are not hard spending caps.
- Delete test infrastructure when finished and verify billable resources are gone.
- Read [docs/cost-management.md](docs/cost-management.md) before cloud deployment.

## Project status

**Status: application, CI/CD foundations, Kubernetes manifests, and Terraform EKS/ECR deployment configuration committed.** Cloud resources have not been created by these repository commits.

## Roadmap

- [x] Add a Java/Maven service and API integration tests
- [x] Add a multi-stage Dockerfile
- [x] Add GitHub Actions build and test workflow
- [x] Add local Compose-based development
- [x] Add Jenkins pipeline example
- [x] Add Kubernetes manifests with probes, resources and HPA
- [x] Add Terraform VPC/EKS/ECR configuration
- [x] Add Terraform-managed Kubernetes Deployment/Service/HPA
- [ ] Add SonarQube and Trivy integration
- [ ] Add GitHub Actions ECR publishing with AWS OIDC
- [ ] Add AWS Load Balancer Controller configuration
- [ ] Add Argo CD GitOps configuration
- [ ] Add Prometheus/Grafana dashboards and alert examples
- [ ] Validate the full AWS deployment and update status from actual results

## Contributions

See [CONTRIBUTING.md](CONTRIBUTING.md) for project conventions.

## License

No license has been selected yet. Until one is added, reuse and redistribution permissions are not explicitly granted.
