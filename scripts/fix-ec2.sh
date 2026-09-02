#!/bin/bash
set -e

echo "=== APIDATA Manual Setup ==="

# Go to app directory
cd /opt || sudo mkdir -p /opt && cd /opt

# Clone the repo (now public)
if [ ! -d "apidata-next" ]; then
    sudo git clone https://github.com/Ash2428-1/apidata-next.git
fi

cd apidata-next
sudo git pull origin main

# Create .env file
sudo tee .env > /dev/null <<'EOF'
DB_USER=apidata
DB_NAME=apidata
DB_PASSWORD=XtendStaging2026!
NEXTAUTH_SECRET=$(openssl rand -base64 32)
ADMIN_PASSWORD_HASH=
ENCRYPTION_KEY=$(openssl rand -base64 32)
EOF

# Start the app
docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
docker-compose -f docker-compose.prod.yml up -d

# Wait for postgres
sleep 10

# Run migrations
docker-compose -f docker-compose.prod.yml exec -T app npx prisma migrate deploy || true

# Restart nginx to proxy to the app
sudo tee /etc/nginx/sites-available/apidata > /dev/null <<'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/apidata /etc/nginx/sites-enabled/apidata
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl restart nginx

echo "=== Setup complete ==="
echo "App should be live at http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
