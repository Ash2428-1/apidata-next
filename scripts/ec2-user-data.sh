#!/bin/bash
set -e
exec > >(tee /var/log/user-data.log) 2>&1

echo "=== APIDATA EC2 Setup — $(date) ==="

# Update system
apt-get update && apt-get upgrade -y

# Install Docker
apt-get install -y ca-certificates curl gnupg lsb-release
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
usermod -aG docker ubuntu

# Install Docker Compose standalone
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Git and other tools
apt-get install -y git nginx certbot python3-certbot-nginx

# Create app directory
mkdir -p /opt/apidata-next
cd /opt/apidata-next

# Clone the repo
git clone https://github.com/Ash2428-1/apidata-next.git .

# Create production .env file
cat > .env <<'EOF'
DB_USER=apidata
DB_NAME=apidata
DB_PASSWORD=CHANGE_ME_STRONG_PASSWORD
NEXTAUTH_SECRET=CHANGE_ME_SECRET
ADMIN_PASSWORD_HASH=
ENCRYPTION_KEY=CHANGE_ME_ENCRYPTION_KEY
EOF

# Pull and deploy
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d

# Wait for Postgres to be ready
sleep 10

# Run migrations
docker-compose -f docker-compose.prod.yml exec -T app npx prisma migrate deploy || true

# Seed admin user (optional)
# docker-compose -f docker-compose.prod.yml exec -T app npx tsx prisma/seed.ts

# Set up Nginx as reverse proxy (alternative to Caddy)
cat > /etc/nginx/sites-available/apidata <<'EOF'
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

ln -sf /etc/nginx/sites-available/apidata /etc/nginx/sites-enabled/apidata
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl restart nginx

echo "=== Setup complete — $(date) ==="
echo "IMPORTANT: Update /opt/apidata-next/.env with real values"
echo "Then run: cd /opt/apidata-next && docker-compose -f docker-compose.prod.yml up -d"
