#!/bin/bash
set -e

echo "=== APIDATA EC2 Setup Script ==="

# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install Docker
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker $USER
    echo "Docker installed successfully"
fi

# Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Create app directory
mkdir -p ~/apidata-next
cd ~/apidata-next

# Clone repo (you'll need to set up deploy keys or use HTTPS with token)
echo "Clone your repo: git clone https://github.com/Ash2428-1/apidata-next.git ."

# Create initial .env file
cat > ~/apidata-next/.env <<EOF
DB_PASSWORD=changeme-strong-password-here
NEXTAUTH_SECRET=$(openssl rand -base64 32)
ADMIN_PASSWORD_HASH=
ENCRYPTION_KEY=$(openssl rand -base64 32)
DB_USER=apidata
DB_NAME=apidata
EOF

echo "=== Setup complete ==="
echo "Next steps:"
echo "1. Clone the repo into ~/apidata-next"
echo "2. Update .env with real values"
echo "3. Run: docker-compose -f docker-compose.prod.yml up -d"
echo "4. Configure GitHub secrets for CI/CD"
