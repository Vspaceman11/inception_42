#!/bin/bash
set -e

# Read secrets
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/credentials)
WP_USER_PASSWORD=$(cat /run/secrets/credentials)

# Wait when MariaDB will be ready to recive connections
echo "Waiting for MariaDB..."
while ! mariadb -hmariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" -e "SELECT 1;" >/dev/null 2>&1; do
    sleep 2
done
echo "MariaDB is ready!"

# Create dir for php-fpm socket/pid
mkdir -p /run/php

if [ ! -f /var/www/wordpress/wp-config.php ]; then
    echo "Downloading and configuring WordPress..."

    # Download core of WordPress
    wp core download --allow-root

    # Create wp-config.php
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost=mariadb:3306 \
        --allow-root

    # Install WordPress (create admin)
    wp core install \
        --url="https://$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root

    # Create second usual user
    wp user create \
        "$WP_USER" \
        "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --role=author \
        --allow-root

    echo "WordPress configured successfully!"
fi

# Install right files owner
chown -R www-data:www-data /var/www/wordpress

# Run PHP-FPM in the background mode in PID 1 (-F — don't daemonize)
exec php-fpm8.2 -F