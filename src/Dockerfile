ARG PHP_VERSION

FROM php:${PHP_VERSION}

ARG HOST_FILES_OWNER_UID
ARG HOST_FILES_OWNER_NAME

MAINTAINER Alexey Chugunov <web@achugunov.ru>

RUN apt update -y \
    && apt install -y \
        bash \
        curl \
        git \
        unzip \
        libicu-dev \
        libzip-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install -j$(nproc) intl bcmath pdo_mysql opcache zip \
    && pecl install apcu \
    && pecl install xdebug \
    && docker-php-ext-enable intl apcu xdebug \
    && pear install PHP_CodeSniffer \
    && curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
    && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
    && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
    && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --snapshot \
    && rm -f /tmp/composer-setup.*

WORKDIR /var/www/sandbox

RUN adduser --disabled-password --uid ${HOST_FILES_OWNER_UID} ${HOST_FILES_OWNER_NAME} \
    && usermod -a -G www-data ${HOST_FILES_OWNER_NAME}

USER ${HOST_FILES_OWNER_NAME}