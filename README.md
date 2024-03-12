NO LONGER MAINTAINED

You can find the successor to this project here:

https://github.com/aws-containers/retail-store-sample-app

# Watchn - Microservices Demo

Watchn is a project that provides a demo for illustrating various concepts related to the development and deployment of applications that are made up of distributed, decoupled components. Like projects that inspired is such as Hipster Shop and Sock Shop it is deliberately over-architected to provide a foundation for truely exploring more complex techniques and technologies.

![Screenshot](/docs/images/screenshot.png)

It looks to explore:
- Frameworks and programming models for developing decoupled, stateless service components in multiple languages
- Aggregation techniques such as API gateways
- Leveraging heterogenous persistence across different services (relational, NoSQL)
- Using scalable persistence techniques such as splitting write/read endpoints
- Implementing cross-cutting concerns such as authentication, monitoring, logging and tracing
- Packaging with containers leveraging "best practices" (re-use, security, size optimization)
- Provisioning infrastructure via IaC
- Mechanisms for building out complex CI/CD pipelines
- Working with a monorepo model

These facets will be gradually worked through over time, and none of them are guaranteed to be in place at any given time.

There are several high level implementation themes that are used throughout this repository:
- Nothing is coupled to a single deployment mechanism or orchestrator
- REST APIs are generally used and documented through the OpenAPI specification
- Events that each service publishes are documented with JSONSchema
- Services should avoid making synchronous calls to each other where possible
- Container setup designed to work with both x64 and ARM64 CPU architecture

## Application Architecture

The application has been deliberately over-engineered to generate multiple de-coupled components. These components generally have different infrastructure dependencies, and may support multiple "backends" (example: Carts service supports MongoDB or DynamoDB).

![Architecture](/docs/images/architecture.png)

| Component | Language | Dependencies        | Description                                                                 |
|-----------|----------|---------------------|-----------------------------------------------------------------------------|
| UI        | Java     | None                | Aggregates API calls to the various other services and renders the HTML UI. |
| Catalog   | Go       | MySQL               | Product catalog API                                                         |
| Carts     | Java     | MongoDB or DynamoDB | User shopping carts API                                                     |
| Orders    | Java     | MySQL               | User orders API                                                             |
| Checkout  | Node     | Redis               | API to orchestrate the checkout process                                     |
| Assets    | Nginx    |                     | Serves static assets like images related to the product catalog             |


## Quickstart

The following sections provide quickstart instructions for various platforms. All of these assume that you have cloned this repository locally and are using a CLI thats current directory is the root of the code repository.

```
git clone https://github.com/niallthomson/microservices-demo.git

cd microservices-demo
```

### Minikube

This deployment method will run the application on your local machine using `minikube`, and will reference pre-built container images by default.

Pre-requisites:
- Minikube installed locally
- Helm and Helmfile utilities installed

To run the application on Minikube we'll need at least 2Gb of memory for the cluster:

```
minikube start --memory=2g
```

Change directory to the Kubernetes deploy directory:

```
cd deploy/kubernetes
```

Use `helmfile` to install all of the components via their Helm charts:

```
NODE_PORT=1 helmfile apply
```

Open the frontend in a browser window:

```
minikube service -n watchn ui
```

### Docker Compose

This deployment method will run the application on your local machine using `docker-compose`, and will build the containers as part of the deployment.

Pre-requisites:
- Docker and Docker Compose installed locally

Change directory to the Docker Compose deploy directory:

```
cd deploy/docker-compose
```

Use `docker-compose` to run the application containers:

```
docker-compose up
```

Open the frontend in a browser window:

```
http://localhost
```

### Cloud Environments

Terraform configuration is provided for various cloud providers:

| Name | Description | Link |
|------|-------------|------|
| AWS EKS | Kubernetes-based deployment on AWS Elastic Kubernetes Service | [Docs](/deploy/terraform/eks-single-region/README.md) |
| AWS ECS | Deploys to AWS Elastic Container Service | [Docs](/deploy/terraform/ecs-single-region/README.md) |
| GKE | Kubernetes-based deployment on Google Kubernetes Engine | TODO |
