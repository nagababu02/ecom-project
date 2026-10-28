# Jenkins pipeline

The Jenkinsfile in this directory checks out the repository, runs Maven tests, builds a local Docker image, and optionally scans the image with Trivy.

## Agent prerequisites

- JDK 17
- Maven 3.9 or compatible
- Docker Engine with permission for the Jenkins agent to run Docker commands
- Git access to this repository

## Configure

1. Create a Pipeline job in Jenkins.
2. Configure the job to use this repository and select the `jenkins/Jenkinsfile` script path.
3. Ensure the agent has the prerequisites above.
4. Run the pipeline and review the test report.

The optional Trivy stage is enabled by adding the empty marker file `jenkins/ENABLE_TRIVY_SCAN` and installing Trivy on the agent. When enabled, the stage fails on HIGH or CRITICAL image findings. Review and remediate findings rather than suppressing them without justification.

This pipeline does not push images to a registry, use cloud credentials, or deploy to AWS. Those steps should be added only after registry authentication, environment approvals, and deployment permissions are designed.
