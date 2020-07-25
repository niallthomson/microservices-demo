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

## Application Architecture

The application has been deliberately over-engineered to generate multiple de-coupled components. These components generally have different infrastructure dependencies, and may support multiple "backends" (example: Carts service supports MongoDB or DynamoDB).

![Screenshot](/docs/images/architecture.png)

| Component | Language | Dependencies        | Description                                                                 |
|-----------|----------|---------------------|-----------------------------------------------------------------------------|
| UI        | Java     | None                | Aggregates API calls to the various other services and renders the HTML UI. |
| Catalog   | Go       | MySQL               | Serves the product catalog API and related images                           |
| Carts     | Java     | MongoDB or DynamoDB | Provides an API for user shopping carts                                     |
| Orders    | Java     | MySQL               | Stores user orders after they have been completed through checkout          |