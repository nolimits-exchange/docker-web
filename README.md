# NolimitsExchange\docker-web

[![Software License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)
[![Docker Repository on Quay](https://quay.io/repository/thepixeldeveloper/nolimits-exchange-web/status "Docker Repository on Quay")](https://quay.io/repository/thepixeldeveloper/nolimits-exchange-web)

Development Dockerfile for powering the web component of Nolimits-Exchange.com

Usage
-----

Use in a `docker-compose.yml` file such as

``` yaml
version: "2"

services:
    web:
        image: thepixeldeveloper/nolimits-exchange-web:latest
        volumes:
            - .:/var/www/nolimits
            - ~/.composer/auth.json:/var/www/composer/auth.json
        links:
            - db
        environment:
            VIRTUAL_HOST: "nolimits.docker"

    blackfire:
        image: blackfire/blackfire
        environment:
            - BLACKFIRE_SERVER_ID
            - BLACKFIRE_SERVER_TOKEN

    db:
        image: mysql:latest
        ports:
            - "13306:3306"
        volumes:
            - ./resources/db/base.sql:/docker-entrypoint-initdb.d/base.sql
        environment:
            MYSQL_ROOT_PASSWORD: "nolimits"
            MYSQL_DATABASE: "nolimits"
            MYSQL_USER: "nolimits"
            MYSQL_PASSWORD: "nolimits"

```

A usable example is currently work in progress.
