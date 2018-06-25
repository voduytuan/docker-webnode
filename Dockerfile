FROM phusion/baseimage

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

ENV HOME /root

RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Nginx-PHP Installation
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y vim curl wget build-essential python-software-properties python-setuptools jpegoptim optipng gifsicle pngquant
RUN add-apt-repository -y ppa:ondrej/php
RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y --force-yes php7.2-cli php7.2-fpm php7.2-mysql php7.2-curl php7.2-redis php7.2-memcached \
		       php7.2-gd php7.1-mcrypt php7.2-intl php7.2-tidy php7.2-bcmath php7.2-zip php7.2-xml php7.2-soap php7.2-mbstring

RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php/7.2/fpm/php.ini
RUN sed -i 's/memory_limit\ =\ 128M/memory_limit\ =\ 2G/g' /etc/php/7.2/fpm/php.ini
RUN sed -i 's/\;date\.timezone\ =/date\.timezone\ =\ Asia\/Ho_Chi_Minh/g' /etc/php/7.2/fpm/php.ini
RUN sed -i 's/upload_max_filesize\ =\ 2M/upload_max_filesize\ =\ 200M/g' /etc/php/7.2/fpm/php.ini
RUN sed -i 's/post_max_size\ =\ 8M/post_max_size\ =\ 200M/g' /etc/php/7.2/fpm/php.ini
RUN sed -i 's/max_execution_time\ =\ 30/max_execution_time\ =\ 3600/g' /etc/php/7.2/fpm/php.ini
RUN sed -i 's/\;error_log\ =\ syslog/error_log\ =\ syslog/g' /etc/php/7.2/fpm/php.ini

# tweak php-fpm config (base on 20MB/process and 3800MB Memory, not include about 200MB for system services)
RUN sed -i -e "s/pm.max_children = 5/pm.max_children = 160/g" /etc/php/7.2/fpm/pool.d/www.conf && \
sed -i -e "s/pm.start_servers = 2/pm.start_servers = 16/g" /etc/php/7.2/fpm/pool.d/www.conf && \
sed -i -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 16/g" /etc/php/7.2/fpm/pool.d/www.conf && \
sed -i -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 40/g" /etc/php/7.2/fpm/pool.d/www.conf && \
sed -i -e "s/;pm.max_requests = 500/pm.max_requests = 2000/g" /etc/php/7.2/fpm/pool.d/www.conf



RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y nginx

RUN mkdir -p        /var/www
ADD build/default   /etc/nginx/sites-available/default
RUN mkdir           /etc/service/nginx
ADD build/nginx.sh  /etc/service/nginx/run
RUN chmod +x        /etc/service/nginx/run
RUN mkdir           /etc/service/phpfpm
ADD build/phpfpm.sh /etc/service/phpfpm/run
RUN chmod +x        /etc/service/phpfpm/run

EXPOSE 80
# End Nginx-PHP

# Copy source directory to default nginx root directory
ADD www             /var/www


# Copy startup script for getting environment information such as config...
ADD startup.sh      /var/startup.sh
RUN chmod +x /var/startup.sh

# Create private folder for download config
RUN mkdir /var/www/private

# Copy update script to download config
ADD config.sh      /var/config.sh
RUN chmod +x /var/config.sh

# composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD [ "/var/startup.sh" ]
