# Kubernetes manifests

This directory contains the Kubernetes deployment definition for the product service. The manifests are kept in Git so the desired state can be reviewed, versioned, rolled back, and later consumed by Argo CD.

## Included resources

- Namespace
- ConfigMap
- ClusterIP Service
- Deployment with two replicas and rolling updates
- CPU/memory requests and limits
- Startup, readiness, and liveness probes
- Non-root/read-only-root-filesystem container security settings
- HorizontalPodAutoscaler using CPU and memory
- AWS Load Balancer Controller Ingress for the `/products` route
- Kustomize base

Kubernetes recommends keeping manifests in version control and using Deployments rather than unmanaged Pods for continuously running applications. The project follows that approach. See the Kubernetes documentation for workload management and configuration guidance.

## Local validation

The base is intentionally written so it can be rendered without connecting to an AWS cluster:

~~~bash
kubectl kustomize kubernetes/base
~~~

To apply it to a cluster where the `ecom-product-service:local` image is available:

~~~bash
kubectl apply -k kubernetes/base
kubectl -n ecom rollout status deployment/product-service --timeout=5m
kubectl -n ecom get pods,svc,hpa,ingress
~~~

## EKS notes

The current Ingress assumes the AWS Load Balancer Controller is installed and configured. It also uses the example hostname `www.nagababu.com`; DNS and TLS will be configured later as part of the AWS deployment stage.

Before an EKS deployment, the image reference must be changed from the local tag to the immutable image tag pushed to Amazon ECR. This will be handled by the CI/CD and GitOps stages rather than committing AWS account-specific values into the base manifest.

The HPA requires a working Kubernetes metrics API, normally provided by Metrics Server or an equivalent metrics implementation.
