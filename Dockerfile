FROM php:5.5-apache

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

RUN apt-get update && apt-get install -y \
        git \
        imagemagick \
        libcurl4-openssl-dev \
        libfreetype6-dev \
        libjpeg-turbo-progs \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        mysql-client \
        pngquant \
        ssmtp \
        sudo \
        unzip \
        wget \
        zlib1g-dev \
    && docker-php-ext-install \
        curl \
        exif \
        mbstring \
        mcrypt \
        mysql \
        mysqli \
        pcntl \
        pdo_mysql \
        zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd

RUN rm /usr/local/etc/php/conf.d/docker-php-ext-curl.ini

RUN pecl install \
        imagick \
    && echo "extension=imagick.so" > /usr/local/etc/php/conf.d/pecl-imagick.ini

RUN echo "output_buffering = Off" >> /usr/local/etc/php/conf.d/conf-output.ini \
 && echo "upload_max_filesize = 2048M" >> /usr/local/etc/php/conf.d/conf-upload.ini \
 && echo "post_max_size = 2048M" >> /usr/local/etc/php/conf.d/conf-upload.ini \
 && echo "session.save_path = /tmp" >> /usr/local/etc/php/conf.d/conf-session.ini

RUN cd /tmp \
 && wget http://heanet.dl.sourceforge.net/project/ajaxplorer/pydio/stable-channel/6.2.1/pydio-core-6.2.1.tar.gz \
 && tar xzf pydio-core-6.2.1.tar.gz \
 && rm -rf /var/www/html \
 && mv pydio-core-6.2.1 /var/www/html \
 && cp -rp /var/www/html/data /var/www/pydio-stub-data

ADD ./install-stub-data.sh /var/www/

VOLUME /var/www/html/data

RUN apt-get clean

RUN a2enmod deflate \
    && a2enmod expires \
    && a2enmod headers \
    && a2enmod mime \
    && a2enmod rewrite
