FROM php:8.2-fpm

# Instala extensões PHP e pacotes necessários
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

# Instala extensão Redis
RUN pecl install redis && docker-php-ext-enable redis

# Instala Node.js e npm (v18.x)
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Cria usuário sem UID fixo (evita conflito entre ambientes)
RUN useradd -ms /bin/bash administrador && \
    usermod -aG www-data administrador && \
    echo "administrador ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Diretório de trabalho
WORKDIR /var/www/html

# Atualiza NPM para a versão mais recente
RUN npm install -g npm

# Define o usuário padrão
USER administrador

# Expõe a porta padrão do PHP-FPM
EXPOSE 9000

CMD ["php-fpm"]
