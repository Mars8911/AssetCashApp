FROM php:8.4-fpm

# 安裝系統依賴
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# 清除快取
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# 安裝 PHP 擴充
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# 取得最新的 Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www