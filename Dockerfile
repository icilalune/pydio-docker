FROM tutum/apache-php

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

RUN apt-get update && apt-get install php5-mcrypt php5-imagick wget -y

RUN php5enmod mcrypt

RUN sed -i "s/output_buffering = 4096/output_buffering = Off/g" /etc/php5/apache2/php.ini
RUN sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 1024M/g" /etc/php5/apache2/php.ini
RUN sed -i "s/post_max_size = 8M/post_max_size = 1024M/g" /etc/php5/apache2/php.ini
RUN sed -i "s/<\/VirtualHost>/<Directory \/var\/www\/html>\nAllowOverride All\n<\/Directory>\n<\/VirtualHost>/g" /etc/apache2/sites-enabled/000-default.conf

RUN cd /tmp\
 && wget http://heanet.dl.sourceforge.net/project/ajaxplorer/pydio/stable-channel/6.0.7/pydio-core-6.0.7.tar.gz\
 && tar xzf pydio-core-6.0.7.tar.gz\
 && rm -rf /app\
 && mv pydio-core-6.0.7 /app

VOLUME /app/data

