FROM alpine:latest

RUN apk update && apk upgrade

# Install packages
RUN apk add --no-cache bash git libwebp libzip libpng wget curl nginx

# Install php8.1
RUN apk --no-cache add php81 php81-cli php81-fpm php81-opcache php81-pecl-apcu php81-mysqli \
        php81-json php81-openssl php81-curl php81-zlib php81-soap php81-xml \
        php81-fileinfo php81-phar php81-intl php81-dom php81-xmlreader \
        php81-ctype php81-session php81-iconv php81-tokenizer php81-zip \
        php81-simplexml php81-mbstring php81-gd php81-pdo php81-pdo_mysql php81-xmlwriter \
        php81-sodium nodejs yarn

# https://gitlab.alpinelinux.org/alpine/aports/-/issues/7473
RUN ln -s /usr/bin/php81 /usr/bin/php

# Install composer
RUN wget https://getcomposer.org/composer-stable.phar -cO /usr/local/bin/composer && chmod +x /usr/local/bin/composer

# Copy configurations
COPY .docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY .docker/nginx/default.conf /etc/nginx/http.d/default.conf
COPY .docker/php/php-fpm.conf /etc/php81/php-fpm.conf
COPY .docker/php/www.conf /etc/php81/php-fpm.d/www.conf

# Configure nvm
ENV NVM_DIR="$HOME/.nvm"

# Install nvm
RUN mkdir -p .nvm
RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
RUN [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
RUN chmod +x $NVM_DIR/nvm.sh
RUN $NVM_DIR/nvm.sh install -s 14.19.0

# Composer configurations
RUN composer config --global github-protocols https
RUN composer config --global gitlab-protocol https

WORKDIR /var/www/html/

COPY . .

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
