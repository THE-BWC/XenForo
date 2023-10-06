FROM php:7.4-fpm-alpine

LABEL maintainer="Patrick Pedersen <patricksoeholtpedersen@gmail.com> Black Widow Company <S-1@the-bwc.com>"

RUN set -ex

RUN apk update && apk add --no-cache \
    build-base \
    autoconf \
    imagemagick \
    wget \
    fcgi \
    libmcrypt-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    mariadb-client \
    imagemagick-dev \
    libxml2-dev \
    libzip-dev \
    libmemcached-dev \
    openssl-dev \
    unzip \
    zip \
    gmp-dev

RUN set -ex && pecl install imagick

RUN docker-php-ext-configure zip; \
    docker-php-ext-enable imagick;

RUN docker-php-ext-install imap; \
    docker-php-ext-install pdo_mysql; \
    docker-php-ext-install mysqli; \
    docker-php-ext-install zip; \
    docker-php-ext-install exif; \
    docker-php-ext-install zip; \
    docker-php-ext-install gmp

RUN apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*;

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Install health check tool for use in container health check
# https://github.com/renatomefi/php-fpm-healthcheck
RUN wget -O /usr/local/bin/php-fpm-healthcheck \
    https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck \
    && chmod +x /usr/local/bin/php-fpm-healthcheck

RUN echo "pm.status_path = /status" >> /usr/local/etc/php-fpm.d/zz-docker.conf

# Copy files
COPY . /var/www/html/

# Set permissions
RUN chown -R $(whoami):$(whoami) /var/www/html/
RUN chmod -R 755 /var/www/html/
RUN chmod -R 777 /var/www/html/data /var/www/html/internal_data

# https://github.com/docker-library/php/issues/926
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install -j$(nproc) gd