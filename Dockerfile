# Menggunakan image resmi PHP 8.2 dengan Apache
FROM php:8.3-apache

# Menginstal dependensi sistem yang dibutuhkan Laravel
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    git \
    curl \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Mengonfigurasi dan menginstal ekstensi PHP (termasuk pdo_pgsql untuk AWS RDS Anda)
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql pdo_pgsql

# Mengaktifkan mod_rewrite Apache untuk routing Laravel
RUN a2enmod rewrite

# Mengatur ServerName untuk menghindari peringatan Apache
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Mengatur direktori kerja
WORKDIR /var/www/html

# Menyalin seluruh kode sumber aplikasi ke dalam container
COPY . .

# Menginstal Composer secara mandiri
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Menjalankan instalasi dependensi Laravel (mengabaikan dev dependencies)
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Mengatur hak akses folder agar bisa ditulis oleh Apache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Mengubah DocumentRoot Apache agar menunjuk ke folder /public Laravel
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Mengekspos port 80
EXPOSE 80