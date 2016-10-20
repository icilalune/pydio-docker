FROM php:7-apache

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

RUN apt-get update && apt-get install -y \
        git \
        graphicsmagick-imagemagick-compat \
        graphicsmagick-libmagick-dev-compat \
        libcurl4-openssl-dev \
        libfreetype6-dev \
        libjpeg-turbo-progs \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libmemcached-dev \
        libpng12-dev \
        libxml2-dev \
        mysql-client \
        pngquant \
        ssmtp \
        sudo \
        unzip \
        wget \
        zlib1g-dev \
    && docker-php-ext-install \
        bcmath \
        curl \
        exif \
        intl \
        mbstring \
        mcrypt \
        mysqli \
        opcache \
        pcntl \
        pdo_mysql \
        soap \
        zip \
    && apt-get clean && apt-get autoremove -q \
    && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man /tmp/* \
    && a2enmod deflate expires headers mime rewrite \
    && echo "<Directory /var/www/html>\nAllowOverride All\n</Directory>" > /etc/apache2/conf-enabled/allowoverride.conf \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && git clone https://github.com/php-memcached-dev/php-memcached /usr/src/php/ext/memcached \
    && cd /usr/src/php/ext/memcached && git checkout 6ace07da69a5ebc021e56a9d2f52cdc8897b4f23 \
    && docker-php-ext-configure memcached \
    && docker-php-ext-install memcached \
    && echo "sendmail_path = /usr/sbin/ssmtp -t" > /usr/local/etc/php/conf.d/conf-sendmail.ini \
    && echo "date.timezone='Europe/Paris'\n" > /usr/local/etc/php/conf.d/conf-date.ini

COPY bin/docker-php-pecl-install /usr/local/bin/

RUN docker-php-pecl-install imagick

RUN echo "output_buffering = Off" >> /usr/local/etc/php/conf.d/conf-output.ini \
 && echo "upload_max_filesize = 2048M" >> /usr/local/etc/php/conf.d/conf-upload.ini \
 && echo "post_max_size = 2048M" >> /usr/local/etc/php/conf.d/conf-upload.ini \
 && echo "memory_limit=512M" >> /usr/local/etc/php/conf.d/conf-memory.ini \
 && echo "session.save_path = /tmp" >> /usr/local/etc/php/conf.d/conf-session.ini

COPY ./bin/install-stub-data.sh /var/www/

RUN cd /tmp \
 && wget https://download.pydio.com/pub/core/archives/pydio-core-7.0.0.tar.gz \
 && tar xzf pydio-core-7.0.0.tar.gz \
 && rm -rf /var/www/html \
 && mv pydio-core-7.0.0 /var/www/html \
 && cp -rp /var/www/html/data /var/www/pydio-stub-data

VOLUME /var/www/html/data
