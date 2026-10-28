# Jenkins deployment pipeline

Jenkins is the primary CI/CD orchestrator for this project. GitHub is used as source control, while Jenkins performs build, test, Docker image creation, Trivy scanning, ECR publishing, GitOps manifest updates, and Argo CD synchronization to EKS.

## Pipeline flow

```text
Developer
   |
   v
GitHub main
   |
   v
Jenkins webhook / Pipeline
   |
   +--> Maven build + tests
   |
   +--> Docker build
   |
   +--> Trivy image scan
   |
   +--> Amazon ECR push (immutable BUILD_NUMBER tag)
   |
   +--> Update Kubernetes Kustomize image tag
   |
   +--> Push GitOps change to GitHub
   |
   v
Argo CD
   |
   v
Amazon EKS
   |
   v
AWS Load Balancer Controller / Ingress
   |
   v
product-service
```

Jenkins Pipeline is stored as code in `jenkins/Jenkinsfile`, which follows the Jenkins Pipeline-as-code model. Jenkins documents Jenkinsfiles as the version-controlled definition of the delivery pipeline. citeturn0search0turn0search3

## Jenkins agent prerequisites

- JDK 17
- Maven 3.9 or compatible
- Docker Engine and permission for the Jenkins agent to run Docker commands
- AWS CLI
- `kubectl`
- `argocd` CLI
- Trivy
- Git
- Python 3 for the small Kustomize tag update helper

## Jenkins credentials

Create these Jenkins credentials before running the deployment pipeline:

| Credential ID | Type | Purpose |
|---|---|---|
| `github-token` | Username with password/token | Push the updated GitOps manifest to GitHub |
| `argocd-admin` | Username with password | Authenticate Jenkins to Argo CD |

For AWS, prefer an IAM role attached to the Jenkins EC2 instance/agent rather than storing long-lived AWS access keys in Jenkins. The IAM identity needs permissions for ECR push, EKS cluster discovery, and the AWS resources required by the deployment process.

Set the Jenkins environment variable `ARGOCD_SERVER` to the Argo CD server endpoint.

## ECR

The pipeline obtains the AWS account ID from `aws sts get-caller-identity`, logs in to ECR, tags the image with the Jenkins `BUILD_NUMBER`, and pushes the immutable tag.

The ECR repository expected by the pipeline is:

```text
ecom-product-service
```

The AWS region is currently configured as:

```text
us-east-1
```

## Argo CD

The repository contains `argocd/application.yaml`. It points Argo CD to:

```text
kubernetes/base
```

Argo CD continuously observes that Git path. Jenkins changes the Kustomize image tag after publishing a new ECR image, and Argo CD synchronizes the desired state into the `ecom` namespace.

The Argo CD application uses automated sync with prune and self-heal enabled.

## Kubernetes / EKS

The cluster must already have:

- Amazon EKS cluster and worker nodes
- AWS Load Balancer Controller
- Kubernetes metrics API for HPA
- Argo CD installed
- ECR access from the EKS nodes/pods

The Kubernetes manifests remain under `kubernetes/base/`. The Ingress is configured for the AWS Load Balancer Controller and routes `/products` to the product service.

## Important safety point

The Jenkinsfile is deployment-ready, but committing the file does **not** create AWS resources. Before the first real deployment, review the Terraform plan, IAM permissions, expected AWS costs, Jenkins credentials, EKS cluster, ECR repository, Load Balancer Controller and Argo CD configuration.

No AWS resource creation is performed by this repository change.
