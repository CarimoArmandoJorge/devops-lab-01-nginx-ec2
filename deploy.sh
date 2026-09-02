#!/bin/bash
set -e

echo "Starting deployment..."

echo "Step 1: Deploying new version..."
sudo cp ~/index.html /var/www/html/index.html

echo "Step 2: Reloading nginx..."
sudo systemctl reload nginx

echo "Step 3: Running healthcheck..."
./healthcheck.sh

echo "Deployment successful."
