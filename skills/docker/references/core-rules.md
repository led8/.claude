# Docker Core Rules

## Dockerfile Location
- Dockerfiles should be at top level of the project, or in a `docker/` folder
- `docker-compose.yml` should be at top level

## Build Requirements
- All docker images must be buildable using:
  - `docker build . -f Dockerfile` OR
  - `docker compose build`

## Default Preferences
- Prefer multi-stage builds when they reduce runtime size or isolate build tooling
- Prefer non-root users for long-running application containers
- Prefer smaller runtime images when they remain compatible with the app and its dependencies
- Choose the base image for compatibility first, then size and hardening

## Proxy Configuration
- Always pass proxy configuration as build args:
  - `http_proxy`
  - `https_proxy`
  - `no_proxy`
  - `HTTP_PROXY`
  - `HTTPS_PROXY`
  - `NO_PROXY`
- **DO NOT** pass `http_proxy`, `https_proxy`, `HTTP_PROXY`, `HTTPS_PROXY` environment variables

Example in Dockerfile:
```Dockerfile
ARG http_proxy
ARG https_proxy
ARG no_proxy
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY

# Use these only as build arguments, not runtime ENV values
```

## SSL Certificates
Install the corporate SSL certificate only when the environment or dependency chain requires it:

```Dockerfile
# Configure SSL certificates, example for debian based image (ubuntu, ...)
# curl, openssl ca-certificates must be installed
RUN curl -k -L --silent https://artifactory-ncsa01.ubisoft.org/generic/ssl/cacert.pem | \
    openssl x509 -inform PEM -out /usr/local/share/ca-certificates/cacert.crt
RUN update-ca-certificates
```

## Validation
- Validate all stages can be built
- When applicable, validate that `docker compose build` is working
- Validate dockerfile with hadolint: `hadolint Dockerfile`
- Ensure the docker builds and runs without error

## Docker Compose
- When needed, configure build-args in docker compose
- **DO NOT** pass `http_proxy`, `https_proxy`, `HTTP_PROXY`, `HTTPS_PROXY` environment variables
