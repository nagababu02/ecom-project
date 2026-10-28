# Architecture and delivery design

## Status

This document describes the intended portfolio architecture. Components are not considered implemented or deployed until their configuration exists and validation has been recorded.

## Delivery flow

1. A developer opens a pull request or pushes a change to GitHub.
2. GitHub Actions performs repository checks, then service-specific builds and tests as those are added.
3. A delivery pipeline builds a container image and runs code-quality and image-vulnerability checks.
4. Approved images are published to Amazon ECR with immutable version tags where configured.
5. Terraform provisions the required AWS network, IAM roles, EKS cluster and worker capacity.
6. Kubernetes deploys services using resource requests/limits, readiness/liveness probes, and configuration separated from application images.
7. Argo CD reconciles Kubernetes manifests from a dedicated Git path/repository.
8. Prometheus collects metrics and Grafana presents dashboards; alerts and runbooks describe operational response.

## Target service boundaries

The sample e-commerce domain may contain product, user, cart, order, inventory and payment services. Service boundaries and API contracts should remain small and documented. Payment examples must not store real payment-card data or credentials.

## AWS network and access

- Place workloads in private subnets where practical.
- Expose only the required application entry point through a load balancer or ingress controller.
- Apply least-privilege IAM roles and security groups.
- Prefer short-lived role-based credentials and avoid static access keys.
- Keep cluster, node and database access restricted to explicitly required sources.
- Use managed services only after their cost and operational trade-offs are understood.

## Reliability

- Define health endpoints and Kubernetes probes.
- Set CPU/memory requests and limits based on measured needs.
- Use rolling updates and documented rollback procedures.
- Configure disruption and scaling policies only where justified.
- Test failure and recovery paths; do not claim high availability without evidence.

## Environments

Keep local development separate from cloud environments. If dev/stage/prod are introduced, isolate configuration and state, use separate identities and restrict production changes. Do not put production secrets in Git.

## Security checks

- Unit tests and dependency checks in CI.
- SonarQube or equivalent static analysis.
- Trivy scans for image and filesystem vulnerabilities.
- Review Terraform changes before apply.
- Pin third-party workflow actions to full commit SHAs for hardened production workflows.
- Record findings and exceptions rather than silently ignoring scanner output.
