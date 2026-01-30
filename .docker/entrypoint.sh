#!/bin/sh
set -e

# Function to check if a service is ready (simple TCP check)
wait_for() {
    echo "Waiting for $1..."
    # logic could be added here if needed, e.g. using nc
}

echo "Starting deployment..."

if [ "$APP_ENV" != "local" ]; then
    echo "Caching configuration..."
    php artisan config:cache
    php artisan event:cache
    php artisan route:cache
    php artisan view:cache
fi

# Run custom command or default
exec "$@"
