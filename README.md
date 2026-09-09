*This project has been created as part of the 42 curriculum by vpushkar.*

# Inception

## Description

Inception builds a small web infrastructure with Docker Compose. The project runs three services in separate containers:

- **NGINX** is the only public entry point. It serves HTTPS on port 443 and sends PHP requests to WordPress.
- **WordPress** runs WordPress and PHP-FPM. It listens on port 9000 inside the Docker network.
- **MariaDB** stores the WordPress database. It listens on port 3306 inside the Docker network.

The goal is to understand how containers, images, networks, secrets, volumes, NGINX, PHP-FPM, WordPress, and MariaDB work together. Each service is built from its own Dockerfile. The services communicate through a private Docker bridge network, while persistent data is stored on the host.

## Project description

### How Docker is used

Docker packages each service with its dependencies and runs it in an isolated container. Docker Compose describes the complete infrastructure in one file and creates the containers, images, network, volumes, and secrets together.

This project uses one container for each main responsibility:

1. NGINX terminates HTTPS on port 443 and is the only service exposed to the host.
2. WordPress runs PHP-FPM and serves the application through the internal `wordpress:9000` connection.
3. MariaDB stores the application database through the internal `mariadb:3306` connection.

The containers use the same private Docker network, but MariaDB and WordPress are not published directly on host ports. This keeps the infrastructure separated and makes the stack reproducible with Docker Compose.

### Sources included in the project

- `Makefile`: creates the host data directories and provides commands to build, start, stop, clean, and reset the stack.
- `srcs/docker-compose.yml`: defines the three services, image builds, container names, private network, host port, volumes, and Docker secrets.
- `srcs/.env`: stores non-sensitive configuration such as the domain, database name, usernames, and email addresses.
- `srcs/requirements/nginx/Dockerfile`: builds the NGINX image and creates the local TLS certificate.
- `srcs/requirements/nginx/conf/nginx.conf`: configures HTTPS, the WordPress document root, and FastCGI requests to PHP-FPM.
- `srcs/requirements/wordpress/Dockerfile`: builds the WordPress image with PHP-FPM, the MySQL PHP extension, MariaDB client tools, and WP-CLI.
- `srcs/requirements/wordpress/conf/www.conf`: configures PHP-FPM to listen on port 9000.
- `srcs/requirements/wordpress/tools/entrypoint.sh`: waits for MariaDB, installs WordPress on the first run, creates the users, and starts PHP-FPM.
- `srcs/requirements/mariadb/Dockerfile`: builds the MariaDB image and copies its server configuration and entrypoint.
- `srcs/requirements/mariadb/conf/50-server.conf`: configures the MariaDB server and its internal port.
- `srcs/requirements/mariadb/tools/entrypoint.sh`: initializes the database, creates the WordPress database user, and starts MariaDB.
- `secrets/`: contains local password files mounted by Docker as secrets. This directory is ignored by Git.

### Main design choices

- Separate containers keep NGINX, WordPress/PHP-FPM, and MariaDB independently configurable.
- NGINX is the only public entry point, so the host exposes only port 443.
- TLS 1.2 and TLS 1.3 protect the HTTPS connection.
- A private bridge network provides service discovery through names such as `mariadb` and `wordpress`.
- Docker secrets keep passwords out of Dockerfiles and normal environment variables.
- Host-backed volumes preserve WordPress files and MariaDB data after container recreation.
- Services run their real foreground daemon as PID 1. The entrypoint scripts use `exec` instead of an artificial background process.

### Virtual machines vs Docker

A virtual machine emulates or virtualizes a complete computer. It runs a guest operating system with its own kernel. This provides strong isolation, but each virtual machine needs its own operating system, memory, storage, and boot process.

Docker containers isolate applications at the operating-system level while sharing the host kernel. They normally start faster and use fewer resources than virtual machines, but they do not provide a separate kernel.

Docker is the correct choice for this project because the goal is to package and connect three services, not to run three complete operating systems. Each service gets its own filesystem, process space, and network identity while the whole stack remains lightweight and reproducible.

### Secrets vs environment variables

Environment variables are appropriate for non-sensitive settings. In this project, `DOMAIN_NAME`, `MYSQL_DATABASE`, `MYSQL_USER`, WordPress usernames, and email addresses are loaded from `srcs/.env`.

Passwords should not be placed in Dockerfiles or ordinary environment variables because environment values can be exposed through process information, Compose output, or debugging tools. Docker secrets are designed for sensitive values: Docker mounts each secret as a file under `/run/secrets/` only in the containers that need it.

This project uses separate secret files for the database user, MariaDB root user, WordPress administrator, and regular WordPress user. The entrypoints read those files at runtime.

### Docker network vs host network

A Docker bridge network creates an isolated virtual network for the services. Docker provides internal DNS, so WordPress can use `mariadb:3306` and NGINX can use `wordpress:9000` without hard-coded container IP addresses.

Host networking would place a container directly on the host network. It would reduce network isolation and make the container share the host's network namespace. It is also forbidden by the project subject.

This project uses a user-defined bridge network named `inception_network`. Only NGINX publishes a host port (`443:443`); MariaDB and PHP-FPM remain reachable only through the Docker network.

### Docker volumes vs bind mounts

A Docker volume is managed by Docker and is normally stored in Docker's own data directory. It is portable between container recreations and does not require the application to know a host path.

A bind mount maps an exact host path into a container. It gives direct control over where files are stored, but it depends on that host path existing and having suitable permissions.

This project declares Docker volumes with local bind options. This gives Compose-managed volume names while storing the actual data in the required host directories:

- `mariadb_data`: `/home/vpushkar/data/mariadb` -> `/var/lib/mysql`
- `wordpress_data`: `/home/vpushkar/data/wordpress` -> `/var/www/wordpress`

This design satisfies the project requirement for data under `/home/login/data` and makes persistence easy to demonstrate during evaluation.

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
