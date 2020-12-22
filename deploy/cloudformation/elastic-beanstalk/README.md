# Watchn - Elastic Beanstalk Deployment

This CloudFormation project will create a fully running deployment of Watchn running on AWS Elastic Beanstalk.

**NOTE:** This project will create resources which will incur costs in your AWS account. You are responsible for these costs, and should understand the resources being created before proceeding.

Prerequisites:
- An AWS account
- AWS CLI

## Architecture

TODO

## Quick Start

The included convenience script `deploy-all.sh` is the quickest way to deploy the project. Run the following command for instructions:

```
./deploy-all.sh -h
```

Running this script will:
- Create a ZIP archive package for each application component, combining its directory under `src` with the respective component directory in this directory
- Use the AWS CLI to package the CloudFormation template, then upload it and the application ZIP packages to S3
- Use the AWS CLI to deploy the CloudFormation template

This deployment will take at least 45 minutes due to how CloudFormation handles nested stacks with dependencies between each other.

## CloudFormation Reference

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| `EnvironmentName` | Unique environment name used when creating resources | `string` |  | yes |

### Outputs

| Name | Description |
|------|-------------|
| `Endpoint` | HTTP(S) endpoint to access the store frontend |