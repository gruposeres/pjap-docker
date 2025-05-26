FROM php:8.2-fpm

# Instala extensões do PHP e ferramentas básicas
RUN apt-get update && apt-get install -y \
    git \
    curl \
    sudo \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    pkg-config \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Instala extensão Redis via PECL
RUN pecl install redis && docker-php-ext-enable redis

# Instala Node.js (18.x) e npm
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Instala Composer (usando imagem oficial)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Criar grupo/usuário com UID e GID 1001
RUN groupadd -g 1001 gruposeres \
    && useradd -m -u 1001 -g 1001 -s /bin/bash gruposeres \
    && usermod -aG www-data gruposeres \
    && echo "gruposeres ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Diretório de trabalho
WORKDIR /var/www/html

# Atualiza o NPM para versão mais recente
RUN npm install -g npm

# Ajusta permissões do diretório do projeto
RUN sudo chown -R gruposeres:www-data /var/www/html \
    && chmod -R 775 /var/www/html

# Define usuário padrão
USER gruposeres

# Expõe a porta padrão do PHP-FPM
EXPOSE 9000

# Comando padrão
CMD ["php-fpm"]