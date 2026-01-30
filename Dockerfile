FROM dunglas/frankenphp:php8.4-alpine AS build

# Copy composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies for build
RUN apk add --no-cache \
    nodejs \
    npm \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    icu-dev \
    libpq-dev \
    oniguruma-dev

# Install PHP extensions
RUN install-php-extensions \
    pdo_pgsql \
    pcntl \
    bcmath \
    gd \
    intl \
    zip \
    opcache \
    redis

WORKDIR /app

# Copy dependency definitions
COPY composer.json composer.lock ./

# Install Composer dependencies (no autoloader yet)
RUN composer install --no-dev --no-autoloader --no-scripts --prefer-dist

# Copy the rest of the application
COPY . .

# Build assets
RUN npm install && npm run build

# Finish composer install (optimize autoloader)
RUN composer dump-autoload --optimize --no-dev

# -----------------------------------------------------------------------------
# Production Stage
# -----------------------------------------------------------------------------
FROM dunglas/frankenphp:php8.4-alpine AS production

# Environment variables
ENV SERVER_NAME=:80
ENV APP_ENV=production
ENV APP_DEBUG=false

# Install runtime dependencies (minimal)
RUN apk add --no-cache \
    libzip \
    libpng \
    icu-libs \
    libpq \
    oniguruma \
    supervisor

# Install PHP extensions (must match build stage)
RUN install-php-extensions \
    pdo_pgsql \
    pcntl \
    bcmath \
    gd \
    intl \
    zip \
    opcache \
    redis

# Configure PHP (OpCache)
COPY .docker/php/conf.d/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY .docker/php/php.ini /usr/local/etc/php/php.ini

WORKDIR /app

# Copy application from build stage
COPY --from=build /app /app

# Set permissions
RUN chown -R root:root /app && \
    chmod -R 775 /app/storage /app/bootstrap/cache

# Entrypoint
COPY .docker/entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint

ENTRYPOINT ["entrypoint"]
CMD ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile"]
