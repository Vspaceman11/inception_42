# Inception User Documentation

This guide explains what the stack provides and how an administrator can use it.

## Services provided

The stack contains three services:

- **NGINX**: accepts HTTPS connections on port 443. It is the only service accessible from outside Docker.
- **WordPress**: provides the website and the administration panel through PHP-FPM.
- **MariaDB**: stores WordPress users, pages, settings, and other website data.

WordPress and MariaDB are private services. They communicate through the Docker network and are not published directly on the host.

## Start the project

Requirements:

- Docker Engine
- Docker Compose plugin
- GNU Make

Add this entry to `/etc/hosts` on the Docker host:

```text
127.0.0.1 vpushkar.42.fr
```

From the repository root, start the stack:

```bash
make
```

Open the website at:

```text
https://vpushkar.42.fr
```

The certificate is self-signed. A browser security warning is normal for local testing.

## Website and administration panel

Website:

```text
https://vpushkar.42.fr
```

Administration panel:

```text
https://vpushkar.42.fr/wp-admin/
```

The administrator username is configured by `WP_ADMIN_USER` in `srcs/.env`. In this project it is:

```text
vpushkar_wp_a
```

The administrator password is stored locally in:

```text
secrets/wp_admin_password.txt
```

Do not publish this file or copy its password into documentation. A regular WordPress user is configured separately with `WP_USER` and `secrets/wp_user_password.txt`.

## Check that services are running

```bash
docker compose -f srcs/docker-compose.yml ps
```

The services `mariadb`, `wordpress`, and `nginx` should show an `Up` status.

View all logs:Prerequisites for validation
In addition to the existing requirements, the following documentation files must be present
at the root of your repository. They must be written in Markdown format (.md).
• USER_DOC.md — User documentation This file must explain, in clear and simple
terms, how an end user or administrator can:
◦ Understand what services are provided by the stack.
◦ Start and stop the project.
◦ Access the website and the administration panel.
◦ Locate and manage credentials.
◦ Check that the services are running correctly.
• DEV_DOC.md — Developer documentation This file must describe how a developer can:
◦ Set up the environment from scratch (prerequisites, configuration files, secrets).
◦ Build and launch the project using the Makefile and Docker Compose.
◦ Use relevant commands to manage the containers and volumes.
◦ Identify where the project data is stored and how it persists.

```bash
docker compose -f srcs/docker-compose.yml logs
```

View one service:

```bash
docker compose -f srcs/docker-compose.yml logs mariadb
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs nginx
```

Test HTTPS:

```bash
curl -vkI --resolve vpushkar.42.fr:443:127.0.0.1 https://vpushkar.42.fr
```

A working installation normally returns `HTTP/1.1 200 OK`.

## Stop and restart

Stop the stack:

```bash
make down
```

Start it again without deleting data:

```bash
make up
```

After a virtual machine reboot, go to the repository root and run `make up` again. The WordPress website and MariaDB data should still be present.

## Credentials and persistent data

The local secret files are:

- `secrets/db_password.txt`: MariaDB password for the WordPress database user.
- `secrets/db_root_password.txt`: MariaDB root password.
- `secrets/wp_admin_password.txt`: WordPress administrator password.
- `secrets/wp_user_password.txt`: regular WordPress user password.

Persistent data is stored on the host at:

- `/home/vpushkar/data/wordpress`
- `/home/vpushkar/data/mariadb`

Do not delete these directories unless you want to remove the website and database.

## Basic troubleshooting

If a service is not running:

```bash
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs --tail=100
```

Check the following:

1. Docker is running.
2. The `/etc/hosts` entry points to the Docker host.
3. NGINX publishes port 443.
4. All three services are `Up`.
5. The secret files exist locally.
