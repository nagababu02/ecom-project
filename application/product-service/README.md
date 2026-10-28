# Product Service

A small Java 17 / Spring Boot REST API used to demonstrate application build, test, containerization, and delivery practices.

## Endpoints

| Method | Path | Purpose |
|---|---|---|
| GET | /api/products | List sample products |
| GET | /api/products/1 | Fetch a product by ID |
| GET | /actuator/health | Application health status |
| GET | /actuator/health/liveness | Kubernetes liveness probe |
| GET | /actuator/health/readiness | Kubernetes readiness probe |

The sample catalog is in memory and is intended for a portfolio/demo environment, not production data storage.

## Run locally

Requirements: JDK 17 and Maven 3.9 or compatible.

~~~bash
mvn -B clean verify
mvn spring-boot:run
~~~

Then test in another terminal:

~~~bash
curl http://localhost:8080/api/products
curl http://localhost:8080/api/products/1
curl http://localhost:8080/actuator/health
~~~

## Build and run with Docker

Run these commands from this directory:

~~~bash
docker build -t ecom-product-service:local .
docker run --rm -p 8080:8080 ecom-product-service:local
~~~

The runtime image uses a non-root user. The container listens on port 8080.

## Known limitations

- Sample data resets whenever the service restarts.
- No database, authentication, payment processing, or external integrations are included yet.
- Do not use this demo service for real customer or payment data.
