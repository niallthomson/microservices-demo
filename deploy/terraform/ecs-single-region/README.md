# Watchn - ECS Single Region Deployment

This Terraform project will create a fully running deployment of Watchn running on AWS Elastic Container Service.

It demonstrates the following features:
- Combining EC2 and Fargate ECS launch types
- Leveraging On-demand and Spot instances
- Using ECS task security groups to lock down network access
- Applying IAM roles to specific ECS tasks with Task Roles
- Injecting secrets with SSM Parameter Store
- CloudWatch Container Insights with Prometheus integration
- HTTPS certifications provisioned via AWS ACM
- ECS Managed Cluster Autoscaling
- Autoscaling ECS services based on CloudWatch metrics
- Spreading ECS tasks across multiple availability zones with separate capacity providers

**NOTE:** This project will create resources which will incur costs in your AWS account. You are responsible for these costs, and should understand the resources being created before proceeding.

Prerequisites:
- An AWS account
- Terraform >= 0.14
- Route53 public hosted zone

## Example

The following is a basic example using the default configuration:

```
module "example" {
  source = "github.com/niallthomson/microservices-demo//deploy/terraform/ecs-single-region"

  hosted_zone_name = "demo.paasify.org"
}
```

## Architecture

![Architecture](architecture.png)

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| `environment_name` | Unique environment name used when creating resources | `string` | `watchn` | no |
| `region` | AWS region in which to create all resources | `string` | `us-west-2` | no |
| `availability_zones` | List of availability zones in which to create resources. If empty will automatically select three AZs. | `list(string)` | `[]` | no |
| `vpc_cidr` | CIDR expressing the IP range of the VPC that will be created | `string` | `10.0.0.0/16` | no |
| `hosted_zone_name` | Name of the Route53 hosted zone where DNS records will be created | `string` | n/a | yes |
| `fargate` | Whether to run all services using Fargate | `boolean` | `true` | no |
| `ami_override_id` | Specific AMI ID to use instead of retrieving from SSM Parameter Store | `string` | n\a | no |


## Outputs

| Name | Description |
|------|-------------|
| `endpoint` | HTTP(S) endpoint to access the store frontend |