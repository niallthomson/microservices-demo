# Watchn - EKS Single Region Deployment

This Terraform project will create a fully running deployment of Watchn running on AWS Elastic Kubernetes Service.

**NOTE:** This project will create resources which will incur costs in your AWS account. You are responsible for these costs, and should understand the resources being created before proceeding.

Prerequisites:
- An AWS account
- Terraform >= 0.14
- Route53 public hosted zone

## Example

The following is a basic example using the default configuration:

```
module "example" {
  source = "github.com/niallthomson/microservices-demo//deploy/terraform/eks-single-region"

  hosted_zone_name = "demo.paasify.org"
}
```

## Architecture

![Architecture](docs/architecture.png)

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| `environment_name` | Unique environment name used when creating resources | `string` | `watchn` | no |
| `region` | AWS region in which to create all resources | `string` | `us-west-2` | no |
| `availability_zones` | List of availability zones in which to create resources. If empty will automatically select three AZs. | `list(string)` | `[]` | no |
| `vpc_cidr` | CIDR expressing the IP range of the VPC that will be created | `string` | `10.0.0.0/16` | no |
| `hosted_zone_name` | Name of the Route53 hosted zone where DNS records will be created | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| `endpoint` | HTTP(S) endpoint to access the store frontend |