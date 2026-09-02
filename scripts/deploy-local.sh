#!/bin/bash
set -e

echo "=== APIDATA Deploy Script ==="

HOST="${EC2_HOST:-16.28.107.39}"
USER="${EC2_USER:-ubuntu}"
KEY="${EC2_KEY:-~/.ssh/xtend-hub-key.pem}"

echo "Deploying to $HOST..."

# Update code on server
ssh -i "$KEY" "$USER@$HOST" 'cd /opt/apidata-next && sudo git pull origin main'

# Rebuild and restart
ssh -i "$KEY" "$USER@$HOST" 'cd /opt/apidata-next && sudo docker-compose -f docker-compose.prod.yml up -d --build'

# Run migrations
ssh -i "$KEY" "$USER@$HOST" 'cd /opt/apidata-next && sudo docker-compose -f docker-compose.prod.yml exec -T app npx prisma migrate deploy || true'

echo "=== Deploy complete ==="
echo "Check: http://$HOST"
