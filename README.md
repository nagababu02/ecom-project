# E-Commerce DevOps Platform on AWS

[![CI](https://github.com/nagababu02/ecom-project/actions/workflows/ci.yml/badge.svg)](https://github.com/nagababu02/ecom-project/actions/workflows/ci.yml)
![Infrastructure](https://img.shields.io/badge/Infrastructure-Terraform-7B42BC)
![Containers](https://img.shields.io/badge/Containers-Docker-2496ED)
![Orchestration](https://img.shields.io/badge/Orchestration-Kubernetes-326CE5)
![Cloud](https://img.shields.io/badge/Cloud-AWS-FF9900)

An end-to-end portfolio project demonstrating how to build, secure, deploy, and observe an e-commerce microservices application using modern DevOps practices. The repository is being developed incrementally; documentation distinguishes implemented and tested components from planned work.

## Goals

- Build and validate application code through automated CI.
- Package services as reproducible Docker images.
- Provision AWS infrastructure with Terraform.
- Deploy container workloads to Amazon EKS using Kubernetes.
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
                 /           \
          Kubernetes       Argo CD
          Services         GitOps sync
                 \           /
                 Metrics / Logs
                  Prometheus
                    Grafana

Terraform -> VPC, subnets, IAM, EKS, node groups and supporting AWS resources
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

A technology listed here is part of the project target; its presence does not by itself mean it has already been deployed or validated.

## Repository layout

~~~text
.
├── .github/workflows/   # Automated build, test and validation
├── application/
│   └── product-service/ # Spring Boot API, tests and Dockerfile
├── docker/              # Shared container assets as needed
├── jenkins/             # Jenkins pipeline (planned)
├── terraform/           # AWS infrastructure as code (planned)
├── kubernetes/          # Kubernetes workload manifests (planned)
├── argocd/              # GitOps application definitions (planned)
├── monitoring/          # Metrics and dashboard configuration (planned)
└── docs/                # Architecture, deployment, operations and cost notes
~~~

## Getting started

### Prerequisites

- Git
- JDK 17 and Maven 3.9 or compatible
- Docker Desktop or Docker Engine for image builds
- Terraform, kubectl and AWS CLI only for later infrastructure/deployment steps

### Build and test locally

From the repository root:

~~~bash
mvn -B -f application/product-service/pom.xml clean verify
docker build -t ecom-product-service:local -f application/product-service/Dockerfile application/product-service
docker run --rm -p 8080:8080 ecom-product-service:local
~~~

In another terminal, try `http://localhost:8080/api/products` and `http://localhost:8080/actuator/health`. See the [service guide](application/product-service/README.md) for details.

### Local-first workflow

1. Clone this repository.
2. Review the architecture and cost guidance.
3. Run the automated build and tests before considering a cloud deployment.
4. Review the Terraform plan, expected costs, permissions, and teardown procedure before provisioning anything.
5. Deploy to AWS only when the environment is deliberately configured and approved.

AWS resources are **not** created merely by cloning this repository. Terraform commands that create or change infrastructure can incur charges.

## Cost and security guardrails

- Start with local validation whenever possible.
- Never commit AWS credentials, tokens, passwords, private keys, or real application secrets.
- Use GitHub Actions secrets or an appropriate secret manager for sensitive values.
- Review Terraform plans before applying them.
- Set AWS Budgets and billing alerts before launching paid resources; alerts are not hard spending caps.
- Delete test infrastructure when finished and verify that billable resources are gone.
- Read [docs/cost-management.md](docs/cost-management.md) before cloud deployment.

## Project status

**Status: application foundation implemented; CI verification in progress.** The product service, tests, and Docker build definition are committed. The GitHub Actions result still needs to be checked before claiming the build passes. No production deployment or performance/security result is claimed by this README.

## Roadmap

- [x] Add a Java/Maven service and API integration tests
- [x] Add a multi-stage Dockerfile
- [x] Add GitHub Actions build and test workflow
- [ ] Add local Compose-based development
- [ ] Add Jenkins pipeline example
- [ ] Add SonarQube and Trivy integration
- [ ] Add Terraform modules and AWS deployment configuration
- [ ] Add Kubernetes manifests, health probes, resource requests and limits
- [ ] Add Argo CD GitOps configuration
- [ ] Add Prometheus/Grafana dashboards and alert examples
- [ ] Document deployment, rollback, troubleshooting and teardown
- [ ] Validate all steps and update status based on actual results

## Contributions

See [CONTRIBUTING.md](CONTRIBUTING.md) for the project conventions.

## License

No license has been selected yet. Until one is added, reuse and redistribution permissions are not explicitly granted.
