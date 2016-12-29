FROM php:7-apache

ENV COMPOSER_VERSION "master"
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV XDEBUG_VERSION="2.5.0"

RUN a2enmod rewrite \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libmagickwand-dev \
        libbz2-dev \
        libxslt-dev \
        curl \
        git \
        subversion \
        unzip \
        wget \
    && rm -r /var/lib/apt/lists/*

ADD https://pecl.php.net/get/xdebug-$XDEBUG_VERSION.tgz /usr/src/php/ext/xdebug.tgz
RUN tar -xf /usr/src/php/ext/xdebug.tgz -C /usr/src/php/ext/ \
    && rm /usr/src/php/ext/xdebug.tgz

RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$version \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
    && mv /tmp/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so

RUN docker-php-ext-install \
    sockets \
    pcntl \
    bcmath \
    pdo_mysql \
    xdebug-$XDEBUG_VERSION \
    zip \
    bz2 \
    xsl \
    mcrypt \
    gd \
    gettext

ADD 20-xdebug.ini /usr/local/etc/php/conf.d/20-xdebug.ini
ADD 20-blackfire.ini /usr/local/etc/php/conf.d/20-blackfire.ini
ADD 20-performance.ini /usr/local/etc/php/conf.d/20-performance.ini
ADD 20-nolimits.conf /etc/apache2/sites-enabled/20-nolimits.conf

ADD https://getcomposer.org/installer /tmp/composer-setup.php
ADD https://composer.github.io/installer.sig /tmp/composer-setup.sig
RUN php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
  && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --snapshot \
  && rm -rf /tmp/composer-setup.php \
  && composer global require "hirak/prestissimo:^0.3"
  
WORKDIR /var/www/nolimits
