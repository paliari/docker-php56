FROM debian:9.0

MAINTAINER Marcos Paliari <marcos@paliari.com.br>

LABEL Description="A Simple apache-sll/php image using debian 9.0"

RUN apt-get update && apt-get -y install wget curl vim apt-transport-https lsb-release ca-certificates
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb https://packages.sury.org/php/ stretch main" > /etc/apt/sources.list.d/php.list
RUN apt-get update && apt-get -y install php5.6 php5.6-curl php5.6-gd php5.6-json php5.6-mbstring \
    php5.6-mcrypt php5.6-mysql php5.6-soap php5.6-zip php5.6-xml

RUN sed -i "s#short_open_tag = Off#short_open_tag = On#" /etc/php/5.6/cli/php.ini
RUN ln -sf /etc/php/5.6/cli/php.ini /etc/php/5.6/apache2/php.ini
RUN printf "ServerName localhost" >> /etc/apache2/apache2.conf
RUN sed -i "s#DirectoryIndex.*#DirectoryIndex\ index.html\ index.php\ index.xhtml\ index.htm#" /etc/apache2/mods-enabled/dir.conf

RUN mkdir -p /etc/apache2/ssl
ADD ssl/* /etc/apache2/ssl/

RUN sed -i "s#DocumentRoot.*#DocumentRoot /var/www/html/dev/public#" /etc/apache2/sites-available/000-default.conf \
    && sed -i "s#</VirtualHost>##" /etc/apache2/sites-available/000-default.conf \
    && printf "\t<Directory /var/www/html/dev/public>\n\t\tOptions Indexes FollowSymLinks\n\t\tAllowOverride All\n\t\tRequire all granted\n\t</Directory>\n</VirtualHost>" >> /etc/apache2/sites-available/000-default.conf \
    && sed -i "s#DocumentRoot.*#DocumentRoot /var/www/html/dev/public#" /etc/apache2/sites-available/default-ssl.conf \
    && sed -i "s#</IfModule>##" /etc/apache2/sites-available/default-ssl.conf \
    && sed -i "s#</VirtualHost>##" /etc/apache2/sites-available/default-ssl.conf \
    && printf "\t\t<Directory /var/www/html/dev/public>\n\t\t\tOptions Indexes FollowSymLinks\n\t\t\tAllowOverride All\n\t\t\tRequire all granted\n\t\t</Directory>\n\t</VirtualHost>\n</IfModule>" >> /etc/apache2/sites-available/default-ssl.conf \

    && sed -i "s#SSLCertificateFile.*#SSLCertificateFile\ /etc/apache2/ssl/apache.crt#g" /etc/apache2/sites-available/default-ssl.conf \
    && sed -i "s#SSLCertificateKeyFile.*#SSLCertificateKeyFile\ /etc/apache2/ssl/apache.key#" /etc/apache2/sites-available/default-ssl.conf \
    && a2enmod ssl headers rewrite && a2ensite default-ssl

#RUN apt-get clean && rm -rf /var/lib/apt/lists/*

EXPOSE 80
EXPOSE 443

CMD apache2ctl -D FOREGROUND

#docker run --name isse -v $(pwd)/../:/var/www/html -p 81:80 -p 444:443 --net=bridge -it isse /bin/bash
