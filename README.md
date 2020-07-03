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