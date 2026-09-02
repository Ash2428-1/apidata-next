#!/bin/bash
set -e

echo "=== APIDATA Deploy Script ==="

cd ~/apidata-next

git pull origin main

docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.prod.yml up -d

# Run migrations
docker-compose -f docker-compose.prod.yml exec -T app npx prisma migrate deploy || true

# Cleanup
docker system prune -f

echo "=== Deployment complete ==="
