*This project has been created as part of the 42 curriculum by vpushkar.*

# Inception

## Description

Inception builds a small web infrastructure with Docker Compose. The project runs three services in separate containers:

- **NGINX** is the only public entry point. It serves HTTPS on port 443 and sends PHP requests to WordPress.
- **WordPress** runs WordPress and PHP-FPM. It listens on port 9000 inside the Docker network.
- **MariaDB** stores the WordPress database. It listens on port 3306 inside the Docker network.

The goal is to understand how containers, images, networks, secrets, volumes, NGINX, PHP-FPM, WordPress, and MariaDB work together. Each service is built from its own Dockerfile. The services communicate through a private Docker bridge network, while persistent data is stored on the host.

## Project description and design choices

The main source files are in `srcs/`:

- `srcs/docker-compose.yml` defines services, networks, volumes, secrets, and the public port.
- `srcs/requirements/nginx/` contains the NGINX Dockerfile and HTTPS configuration.
- `srcs/requirements/wordpress/` contains the PHP-FPM Dockerfile, PHP-FPM configuration, and WordPress entrypoint.
- `srcs/requirements/mariadb/` contains the MariaDB Dockerfile, server configuration, and database entrypoint.
- `srcs/.env` contains non-secret configuration values.
- `secrets/` contains local password files used as Docker secrets. These files are ignored by Git.

The main design choices are one container per service, NGINX as the only public entry point, TLS 1.2 and TLS 1.3 on port 443, a private Docker network, Docker secrets for passwords, host-backed volumes for persistence, and foreground processes with `exec` so the real daemon is PID 1.

### Virtual machines and Docker

A virtual machine runs a complete guest operating system and its own kernel. A Docker container shares the host kernel and isolates the application process, filesystem, and network.

Docker containers usually start faster and use fewer resources. Virtual machines provide stronger operating-system isolation but need more resources. Docker is suitable here because each service needs process and filesystem isolation, not a complete operating system.

### Secrets and environment variables

Environment variables are useful for normal configuration such as the domain name, database name, usernames, and email addresses. They are easy to inspect and can appear in process or Compose information.

Secrets are intended for sensitive values such as passwords. Docker mounts them as files under `/run/secrets/` inside the required containers. This project keeps database and WordPress passwords in `secrets/` instead of putting them in Dockerfiles or normal environment variables.

### Docker network and host network

A Docker bridge network gives the services a private network and Docker DNS names. WordPress connects to `mariadb:3306`, and NGINX connects to `wordpress:9000`.

Host networking would place a container directly on the host network and would remove this network isolation. It is not used here. Only NGINX publishes a host port.

### Docker volumes and bind mounts

A Docker volume is managed by Docker. A bind mount maps a specific host path into a container. This project uses Docker volumes with bind options so the data is visible at known host paths:

- `/home/vpushkar/data/mariadb` -> `/var/lib/mysql`
- `/home/vpushkar/data/wordpress` -> `/var/www/wordpress`

This combines Compose volume management with predictable host storage required by the project.

## Instructions

### Requirements

- Linux virtual machine
- Docker Engine
- Docker Compose plugin
- GNU Make
- Internet access during image builds

Add the domain to `/etc/hosts` on the Docker host:

```text
127.0.0.1 vpushkar.42.fr
```

Use the Docker host IP instead of `127.0.0.1` when the browser runs on another machine.

### Start the project

From the repository root:

```bash
make
```

This creates the data directories, builds the three images, and starts the containers. The website is available at:

```text
https://vpushkar.42.fr
```

The certificate is self-signed, so a browser warning is expected during local testing.

### Check and stop the project

```bash
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs
make down
```

`make down` stops and removes containers and the project network, but keeps the data directories.

To rebuild and start without deleting data:

```bash
make down
make build
make up
```

`make re` performs a full reset and deletes the contents of the WordPress and MariaDB data directories. Use it only when a clean installation is required.

## Resources

- [Docker documentation](https://docs.docker.com/): images, containers, networks, volumes, and secrets.
- [Docker Compose documentation](https://docs.docker.com/compose/): services, builds, ports, dependencies, and volumes.
- [NGINX documentation](https://nginx.org/en/docs/): HTTPS, TLS, reverse proxy, and FastCGI.
- [WordPress documentation](https://wordpress.org/documentation/): WordPress installation and administration.
- [WP-CLI documentation](https://developer.wordpress.org/cli/commands/): command-line installation and user management.
- [MariaDB documentation](https://mariadb.com/docs/): databases, users, permissions, and server configuration.

These resources were used to understand the services, configure their communication, set up HTTPS, install WordPress, initialize MariaDB, and preserve data.

### AI use

AI tools were used as a learning and review aid. They helped explain Docker and Docker Compose concepts, compare networking and storage options, review configuration files for consistency, suggest validation commands, and improve the structure and wording of this documentation.

The Dockerfiles, Compose configuration, shell scripts, and service configuration were checked and understood by the project author. AI output was not treated as a replacement for testing or for explaining the project during evaluation.
