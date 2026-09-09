This project has been created as part of the 42 curriculum by vpushkar.

# Inception

## Description

Inception is a small infrastructure built with Docker Compose. It contains three services:

- **NGINX**: the only public entry point. It handles HTTPS on port 443.
- **WordPress**: runs WordPress with PHP-FPM on port 9000 inside the Docker network.
- **MariaDB**: stores the WordPress database on port 3306 inside the Docker network.

The services are built from their own Dockerfiles and communicate through a private Docker network.

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

## Requirements

- Linux virtual machine
- Docker
- Docker Compose plugin
- GNU Make
- A local domain entry for `vpushkar.42.fr`

Add the domain to `/etc/hosts` if necessary:

```text
127.0.0.1 vpushkar.42.fr
```

Use the IP address of the evaluation machine instead of `127.0.0.1` when required.

## Instructions

Start the project from the repository root:

```bash
make
```

This creates the host data directories, builds the images, and starts the containers.

Open the website at:

```text
https://vpushkar.42.fr
```

The certificate is self-signed, so the browser can display a security warning during local testing.

Check the services:

```bash
docker compose -f srcs/docker-compose.yml ps
```

Stop the project:

```bash
make down
```

Rebuild and restart it:

```bash
make re
```

`make re` removes the persistent data first. Use it only when a clean installation is wanted.

## Data and secrets

Persistent data is stored on the host in:

- `/home/vpushkar/data/wordpress`
- `/home/vpushkar/data/mariadb`

Passwords are stored locally in Docker secret files:

- `secrets/db_password.txt`
- `secrets/db_root_password.txt`
- `secrets/wp_admin_password.txt`
- `secrets/wp_user_password.txt`

These files must not be committed to Git. The `.env` file is also local and is ignored by Git.

## Resources

- Docker documentation: images, containers, networks, volumes, and secrets.
- Docker Compose documentation: service definitions, builds, ports, and dependencies.
- NGINX documentation: HTTPS, TLS, reverse proxy, and FastCGI.
- WordPress documentation: installation and administration.
- WP-CLI documentation: WordPress command-line installation and user management.
- MariaDB documentation: databases, users, permissions, and server configuration.

These resources were used to understand the services, connect them through Docker Compose, configure HTTPS, create the WordPress database, and preserve data with volumes.
