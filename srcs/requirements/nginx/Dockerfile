FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Create dir for SSL-certificates
RUN mkdir -p /etc/nginx/ssl

# Generate selfsigned SSL-certificate (TLS)
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -out /etc/nginx/ssl/inception.crt \
    -keyout /etc/nginx/ssl/inception.key \
    -subj "/C=DE/ST=Baden-Wurttemberg/L=Heilbronn/O=42/OU=42Heilbronn/CN=vpushkar.42.fr"

# Copy config file NGINX
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

# Ensure the WordPress directory exists and is usable by nginx
RUN mkdir -p /var/www/wordpress
RUN chown -R www-data:www-data /var/www/wordpress

EXPOSE 443

ENTRYPOINT ["nginx", "-g", "daemon off;"]