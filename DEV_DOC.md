# Inception Developer Documentation

This guide explains how to prepare, build, run, inspect, and reset the project.

## Prerequisites

Install the following on the Linux virtual machine:

- Docker Engine
- Docker Compose plugin
- GNU Make
- Git
- Internet access during image builds

The current repository path is:

```text
/home/vpushkar/inception_42
```

## Configuration from scratch

### Domain

Add the project domain to `/etc/hosts`:

```text
127.0.0.1 vpushkar.42.fr
```

Use the Docker host IP instead of `127.0.0.1` when access comes from another machine.

### Environment file

The file `srcs/.env` contains non-secret values:

- `DOMAIN_NAME=vpushkar.42.fr`
- `MYSQL_DATABASE=wordpress`
- `MYSQL_USER=wp_user`
- WordPress title, usernames, and email addresses

Do not put passwords in this file.

### Secret files

Create these local files under `secrets/`:

```text
db_password.txt
db_root_password.txt
wp_admin_password.txt
wp_user_password.txt
```

Each file should contain only its password and a final newline. Compose mounts the required files under `/run/secrets/` inside the containers.

The secret directory and `srcs/.env` are ignored by Git. Never commit them or place credentials in Dockerfiles, scripts, or documentation.

## Project structure

```text
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        ├── nginx/
        └── wordpress/
```

Each service has its own Dockerfile. The Compose file builds the images, creates the bridge network, attaches the volumes, and publishes only NGINX port 443.

## Build and launch

From the repository root:

```bash
make
```

The Makefile runs these steps:

1. `prepare` creates `/home/vpushkar/data/wordpress` and `/home/vpushkar/data/mariadb`.
2. `build` builds the three service images with Docker Compose.
3. `up` starts the services in detached mode.

Equivalent Compose commands:

```bash
docker compose -f srcs/docker-compose.yml build
docker compose -f srcs/docker-compose.yml up -d
```

Validate the Compose file before starting:

```bash
docker compose -f srcs/docker-compose.yml config
```

## Manage containers

Check service status:

```bash
docker compose -f srcs/docker-compose.yml ps
```

Show logs:

```bash
docker compose -f srcs/docker-compose.yml logs --tail=100
docker compose -f srcs/docker-compose.yml logs --tail=100 mariadb
docker compose -f srcs/docker-compose.yml logs --tail=100 wordpress
docker compose -f srcs/docker-compose.yml logs --tail=100 nginx
```

Follow logs:

```bash
docker compose -f srcs/docker-compose.yml logs -f
```

Stop and remove containers and the project network:

```bash
make down
```

Rebuild without deleting persistent data:

```bash
make down
make build
make up
```

Use `--no-cache` when a completely fresh image build is required:

```bash
docker compose -f srcs/docker-compose.yml build --no-cache
```

## Manage volumes and persistent data

The project uses two Docker volumes with host bind options:

- `mariadb_data` maps `/home/vpushkar/data/mariadb` to `/var/lib/mysql`.
- `wordpress_data` maps `/home/vpushkar/data/wordpress` to `/var/www/wordpress`.

List volumes:

```bash
docker volume ls
```

Inspect the host path:

```bash
docker volume inspect srcs_mariadb_data
docker volume inspect srcs_wordpress_data
```

The volume names can include the Compose project prefix. Use the names shown by `docker volume ls` if they differ.

Data persists when containers are removed because it is stored in the host directories. To test persistence:

1. Create or edit WordPress content.
2. Run `make down`.
3. Run `make up`.
4. Confirm the content still exists.
5. Reboot the virtual machine.
6. Run `make up` and check the website again.

`make fclean` removes Docker resources and deletes the contents of both host data directories. It is destructive and should be used only for a clean reset.

## Network and service connections

Compose creates the `inception_network` bridge network. Docker DNS provides service names:

- WordPress connects to MariaDB at `mariadb:3306`.
- NGINX connects to PHP-FPM at `wordpress:9000`.

Neither MariaDB nor PHP-FPM is published to the host. NGINX is the only public entry point on port 443.

Inspect the network:

```bash
docker network ls
docker network inspect srcs_inception_network
```

Use the network name shown by `docker network ls` if the Compose project prefix is different.

## Service details

### MariaDB

The MariaDB Dockerfile installs MariaDB server and client packages. Its entrypoint reads secrets, initializes the database on the first run, creates the WordPress database and user, and starts MariaDB as the main process.

### WordPress

The WordPress Dockerfile installs PHP-FPM, the MySQL PHP extension, the MariaDB client, and WP-CLI. Its entrypoint waits for MariaDB, downloads and installs WordPress on the first run, creates the administrator and regular user, and starts PHP-FPM in the foreground.

### NGINX

The NGINX Dockerfile installs NGINX and OpenSSL, creates a local self-signed certificate, and copies the HTTPS configuration. NGINX serves the shared WordPress volume and forwards PHP requests to `wordpress:9000` through FastCGI.

## Diagnostics

Test the HTTPS endpoint:

```bash
curl -vkI --resolve vpushkar.42.fr:443:127.0.0.1 https://vpushkar.42.fr
```

Check NGINX configuration:

```bash
docker exec nginx nginx -t
```

List WordPress users:

```bash
docker exec wordpress wp user list --allow-root
```

Check MariaDB databases and WordPress tables:

```bash
docker exec -it mariadb mariadb -uroot -p -e "SHOW DATABASES;"
docker exec -it mariadb mariadb -uroot -p wordpress -e "SHOW TABLES;"
```

Enter passwords directly in the terminal. Do not write them into this file or into shell history.

## Configuration change test

To test a different host port for NGINX, temporarily change this in `srcs/docker-compose.yml`:

```yaml
ports:
  - "8443:443"
```

The first number is the host port. The second number is the container port and remains 443.

Recreate the stack:

```bash
make down
docker compose -f srcs/docker-compose.yml up -d --build --force-recreate
```

Test the new port:

```bash
curl -vkI --resolve vpushkar.42.fr:8443:127.0.0.1 https://vpushkar.42.fr:8443
```

Restore `443:443` after the test and recreate the stack again.

## Clean reset

Normal stop, keeping data:

```bash
make down
```

Full reset, deleting project data:

```bash
make fclean
```

Rebuild after a full reset:

```bash
make
```
