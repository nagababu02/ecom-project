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
| Build | Maven, Java |
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
├── .github/workflows/   # Automated validation
├── application/         # Microservices source code
├── docker/              # Container build definitions
├── jenkins/             # Jenkins pipeline
├── terraform/           # AWS infrastructure as code
├── kubernetes/          # Kubernetes workload manifests
├── argocd/              # GitOps application definitions
├── monitoring/          # Metrics and dashboard configuration
└── docs/                # Architecture, deployment, operations and cost notes
~~~

Directories and implementation files will be added as the project is built and tested.

## Getting started

### Prerequisites

- Git
- Docker Desktop or Docker Engine
- Java and Maven for local application builds
- Terraform for infrastructure validation
- kubectl for Kubernetes workflows
- AWS CLI only for AWS deployment steps

Exact versions and service-specific setup instructions will be documented alongside each component.

### Local-first workflow

1. Clone this repository.
2. Review the architecture and cost guidance.
3. Run the repository validation workflow and local tests.
4. Build and test services locally before considering a cloud deployment.
5. Provision AWS only after reviewing the plan, expected costs, access permissions, and teardown procedure.

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

**Status: Foundation and documentation in progress.** Features will be marked complete only after their files exist and the relevant checks have been run. No production deployment or performance/security result is claimed by this README.

## Roadmap

- [ ] Add a working Java/Maven service and unit tests
- [ ] Add Dockerfiles and local Compose-based development
- [ ] Add GitHub Actions build and test workflow
- [ ] Add Jenkins pipeline example
- [ ] Add SonarQube and Trivy integration guidance
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
