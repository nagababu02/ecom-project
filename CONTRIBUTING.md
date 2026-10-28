# Contributing

Thanks for helping improve this learning project.

## Guidelines

- Keep changes focused and explain the reason for them.
- Never commit credentials, tokens, private keys, personal data or real secrets.
- Prefer small, reviewable pull requests.
- Update documentation when commands, architecture or operational behavior changes.
- Include tests or validation steps for new functionality.
- Do not claim that a service is deployed or tested unless there is evidence.
- Review Terraform plans and cost implications before applying infrastructure changes.

## Local checks

- Run git diff --check.
- Run the tests relevant to the changed service.
- Run terraform fmt -check -recursive and terraform validate where Terraform files exist.
- Validate Kubernetes YAML before deployment.
- Review the final diff for secrets and generated files.
