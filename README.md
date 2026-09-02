# API Hub — Xtend

Next.js application for the Xtend Eco System Sales Portal API Hub.

## Stack

- **Framework:** Next.js 16 + React 19 + TypeScript
- **Styling:** Tailwind CSS v4
- **Database:** PostgreSQL + Prisma ORM v7
- **Auth:** bcryptjs (custom admin auth)
- **Deployment:** Docker + AWS EC2 + Caddy

## Local Development

```bash
# Install dependencies
npm install

# Set up environment
cp .env.example .env
# Edit .env with your database credentials

# Run database (requires Docker)
docker-compose up -d postgres

# Generate Prisma client and run migrations
npx prisma generate
npx prisma migrate dev

# Seed admin user
npx tsx prisma/seed.ts

# Start dev server
npm run dev
```

## Production Deployment

### AWS EC2 Setup

1. Launch an Ubuntu 22.04 EC2 instance (t3.medium recommended)
2. Open ports 22 (SSH), 80 (HTTP), and 443 (HTTPS)
3. SSH into the instance and run:

```bash
curl -fsSL https://raw.githubusercontent.com/Ash2428-1/apidata-next/main/scripts/setup-ec2.sh | bash
```

4. Clone the repo and configure `.env`
5. Deploy:

```bash
cd ~/apidata-next
docker-compose -f docker-compose.prod.yml up -d
```

### GitHub Actions CI/CD

Configure these secrets in your GitHub repository:

| Secret | Description |
|--------|-------------|
| `EC2_HOST` | EC2 public IP or domain |
| `EC2_USER` | SSH username (usually `ubuntu`) |
| `EC2_SSH_KEY` | Private SSH key contents |
| `DB_PASSWORD` | PostgreSQL password |
| `NEXTAUTH_SECRET` | NextAuth secret key |
| `ADMIN_PASSWORD_HASH` | Pre-hashed admin password (optional) |
| `ENCRYPTION_KEY` | Encryption key for connector credentials |

Pushes to `main` will automatically deploy to EC2.

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/health` | Health check |
| POST | `/api/auth/login` | Admin login |

## Database Schema

See `prisma/schema.prisma` for full schema.

### Key Models
- **Admin** — System administrators
- **ApiKey** — API access keys
- **Connector** — Data source connectors (CarTrack, Flickswitch, manual)
- **ConnectorRun** — Import job history
- **Contact / Deal / Vehicle / Sim** — Core business entities
- **Upload** — File import tracking
- **RequestLog** — API request logging
