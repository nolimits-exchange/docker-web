FROM php:7.1-apache

ENV COMPOSER_VERSION "1.4.1"
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV XDEBUG_VERSION="2.5.1"

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

RUN pecl install "xdebug-$XDEBUG_VERSION" imagick \
 && docker-php-ext-enable imagick xdebug

RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$version \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
    && mv /tmp/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > $PHP_INI_DIR/conf.d/blackfire.ini

RUN docker-php-ext-install -j$(nproc) \
    sockets \
    pcntl \
    bcmath \
    pdo_mysql \
    zip \
    bz2 \
    xsl \
    mcrypt \
    gd \
    gettext

ADD php.ini /usr/local/etc/php/
ADD 20-nolimits.conf /etc/apache2/sites-enabled/20-nolimits.conf

ADD https://getcomposer.org/installer /tmp/composer-setup.php
ADD https://composer.github.io/installer.sig /tmp/composer-setup.sig
RUN php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
  && php /tmp/composer-setup.php --quiet --no-ansi --install-dir=/usr/local/bin --filename=composer --version="$COMPOSER_VERSION" \
  && rm -rf /tmp/composer-setup.php \
  && composer global require "hirak/prestissimo:^0.3"
  
WORKDIR /var/www/nolimits
