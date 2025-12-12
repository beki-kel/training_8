#!/bin/bash
# ══════════════════════════════════════════════════════════
# Current - Local Development Setup Script
# ══════════════════════════════════════════════════════════
# One command to bootstrap your local development environment
#
# Usage:
#   ./setup.sh           # Standard setup
#   ./setup.sh --docker  # Force Docker PostgreSQL
#   ./setup.sh --reset   # Clean slate (drop DB, regenerate .env)
#   ./setup.sh --help    # Show help
# ══════════════════════════════════════════════════════════

set -e

# ─────────────────────────────────────────────────────────
# Colors
# ─────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ─────────────────────────────────────────────────────────
# Flags
# ─────────────────────────────────────────────────────────
RESET=false
USE_DOCKER=false
DB_HOST=""
USING_DOCKER_DB=false

# ─────────────────────────────────────────────────────────
# Helper Functions
# ─────────────────────────────────────────────────────────
print_banner() {
  echo ""
  echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║${NC}  ${BOLD}Current${NC} - Local Development Setup                        ${CYAN}║${NC}"
  echo -e "${CYAN}║${NC}  AI-Powered Knowledge Base Manager                        ${CYAN}║${NC}"
  echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
  echo ""
}

print_step() {
  echo -e "${BLUE}▶${NC} $1"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

show_help() {
  echo "Usage: ./setup.sh [options]"
  echo ""
  echo "Options:"
  echo "  --docker    Force Docker PostgreSQL (skip local detection)"
  echo "  --reset     Clean slate (drop DB, regenerate .env)"
  echo "  --help      Show this help message"
  echo ""
  echo "Examples:"
  echo "  ./setup.sh             # Standard setup with local PostgreSQL detection"
  echo "  ./setup.sh --docker    # Use Docker PostgreSQL"
  echo "  ./setup.sh --reset     # Start fresh"
}

check_command() {
  if ! command -v "$1" &> /dev/null; then
    return 1
  fi
  return 0
}

# ─────────────────────────────────────────────────────────
# Parse Arguments
# ─────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case $1 in
    --reset)
      RESET=true
      shift
      ;;
    --docker)
      USE_DOCKER=true
      shift
      ;;
    --help)
      show_help
      exit 0
      ;;
    *)
      print_error "Unknown option: $1"
      show_help
      exit 1
      ;;
  esac
done

# ─────────────────────────────────────────────────────────
# Main Script
# ─────────────────────────────────────────────────────────
print_banner

# ─────────────────────────────────────────────────────────
# Step 1: Prerequisites Check
# ─────────────────────────────────────────────────────────
print_step "Checking prerequisites..."

# Check Node.js
if ! check_command node; then
  print_error "Node.js is not installed. Please install Node.js 18+ from https://nodejs.org"
  exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
  print_error "Node.js 18+ is required. Current version: $(node -v)"
  exit 1
fi
print_success "Node.js $(node -v)"

# Check npm
if ! check_command npm; then
  print_error "npm is not installed."
  exit 1
fi
print_success "npm $(npm -v)"

# Check Docker (only warn, not required)
if ! check_command docker; then
  print_warning "Docker not found. Will require local PostgreSQL."
  DOCKER_AVAILABLE=false
else
  DOCKER_AVAILABLE=true
  print_success "Docker $(docker -v | cut -d' ' -f3 | tr -d ',')"
fi

echo ""

# ─────────────────────────────────────────────────────────
# Step 2: Handle Reset Flag
# ─────────────────────────────────────────────────────────
if [ "$RESET" = true ]; then
  print_step "Resetting environment..."

  # Remove .env
  if [ -f ".env" ]; then
    rm .env
    print_success "Removed .env"
  fi

  # Stop and remove Docker database
  if [ "$DOCKER_AVAILABLE" = true ]; then
    if docker ps -a --format '{{.Names}}' | grep -q "current_db"; then
      docker-compose -f docker-compose.db.yml down -v 2>/dev/null || true
      print_success "Removed Docker database"
    fi
  fi

  echo ""
fi

# ─────────────────────────────────────────────────────────
# Step 3: Install Dependencies
# ─────────────────────────────────────────────────────────
print_step "Installing dependencies..."

if [ ! -d "node_modules" ] || [ "package.json" -nt "node_modules/.package-lock.json" ] 2>/dev/null; then
  npm install
  print_success "Dependencies installed"
else
  print_success "Dependencies up to date"
fi

echo ""

# ─────────────────────────────────────────────────────────
# Step 4: Database Detection
# ─────────────────────────────────────────────────────────
print_step "Setting up database..."

setup_docker_db() {
  # Check if Docker daemon is running
  if ! docker info &>/dev/null; then
    print_error "Docker is installed but not running!"
    echo ""
    echo "  Please start Docker Desktop and run this script again."
    exit 1
  fi

  # Check if container already exists and is running
  if docker ps --format '{{.Names}}' | grep -q "current_db"; then
    print_success "Docker PostgreSQL already running"
  else
    # Remove old stopped container if exists
    if docker ps -a --format '{{.Names}}' | grep -q "current_db"; then
      docker rm current_db &>/dev/null
    fi

    print_step "Starting Docker PostgreSQL..."
    docker-compose -f docker-compose.db.yml up -d

    # Wait for database to be ready
    echo -n "  Waiting for database"
    for i in {1..30}; do
      if docker exec current_db pg_isready -U current -d current_db &>/dev/null; then
        echo ""
        print_success "Docker PostgreSQL ready (port 5556)"
        break
      fi
      echo -n "."
      sleep 1
      if [ $i -eq 30 ]; then
        echo ""
        print_error "Database failed to start within 30 seconds"
        exit 1
      fi
    done
  fi
  USING_DOCKER_DB=true
  DB_HOST="localhost"
  DB_PORT="5433"
}

test_db_connection() {
  # Test if we can actually connect with the credentials in .env.example
  PGPASSWORD=current_password psql -h localhost -U current -d current_db -c "SELECT 1" &>/dev/null
  return $?
}

if [ "$USE_DOCKER" = true ]; then
  # User explicitly requested Docker
  if [ "$DOCKER_AVAILABLE" = false ]; then
    print_error "Docker requested but not available. Please install Docker."
    exit 1
  fi
  setup_docker_db
else
  # Try local PostgreSQL first
  LOCAL_PG_WORKS=false

  if check_command psql; then
    # Check if PostgreSQL is running
    if pg_isready -q 2>/dev/null; then
      print_success "Local PostgreSQL detected and running"

      # Try to connect with default credentials
      if test_db_connection; then
        print_success "Database 'current_db' exists and is accessible"
        LOCAL_PG_WORKS=true
        USING_DOCKER_DB=false
        DB_HOST="localhost"
      else
        # Try to create the database and user
        print_warning "Database not configured for this project"
        echo ""
        echo -e "  ${CYAN}We need to create a database and user for the app.${NC}"
        echo -e "  This requires your PostgreSQL admin (postgres) password."
        echo ""
        read -p "  Enter PostgreSQL 'postgres' user password (or press Enter to use Docker instead): " -s PG_ADMIN_PASS
        echo ""

        if [ -n "$PG_ADMIN_PASS" ]; then
          print_step "Creating database and user..."

          # Create user (ignore error if exists)
          PGPASSWORD="$PG_ADMIN_PASS" psql -h localhost -U postgres -c "CREATE USER current WITH PASSWORD 'current_password';" 2>/dev/null || true

          # Create database
          if PGPASSWORD="$PG_ADMIN_PASS" psql -h localhost -U postgres -c "CREATE DATABASE current_db OWNER current;" 2>/dev/null; then
            PGPASSWORD="$PG_ADMIN_PASS" psql -h localhost -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE current_db TO current;" 2>/dev/null
            print_success "Created database 'current_db' with user 'current'"
            LOCAL_PG_WORKS=true
            USING_DOCKER_DB=false
            DB_HOST="localhost"
          else
            # Database might already exist, try granting privileges
            if PGPASSWORD="$PG_ADMIN_PASS" psql -h localhost -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE current_db TO current;" 2>/dev/null; then
              print_success "Database already exists, granted privileges"
              LOCAL_PG_WORKS=true
              USING_DOCKER_DB=false
              DB_HOST="localhost"
            else
              print_error "Failed to create database. Check your password and try again."
            fi
          fi
        else
          print_warning "No password provided, will try Docker instead..."
        fi
      fi
    else
      print_warning "Local PostgreSQL found but not running"
    fi
  fi

  # Fallback to Docker if local didn't work
  if [ "$LOCAL_PG_WORKS" = false ]; then
    if [ "$DOCKER_AVAILABLE" = true ]; then
      print_warning "Local PostgreSQL not available or not configured"
      print_step "Falling back to Docker..."
      setup_docker_db
    else
      print_error "No PostgreSQL available!"
      echo ""
      echo -e "  ${BOLD}Option 1:${NC} Install and start Docker Desktop"
      echo "           Then run: ./setup.sh"
      echo ""
      echo -e "  ${BOLD}Option 2:${NC} Configure local PostgreSQL manually:"
      echo "           psql -U postgres"
      echo "           CREATE USER current WITH PASSWORD 'current_password';"
      echo "           CREATE DATABASE current_db OWNER current;"
      echo "           Then run: ./setup.sh"
      exit 1
    fi
  fi
fi

echo ""

# ─────────────────────────────────────────────────────────
# Step 5: Environment Configuration
# ─────────────────────────────────────────────────────────
print_step "Configuring environment..."

if [ -f ".env" ]; then
  print_success ".env already exists"
else
  # Copy template
  cp .env.example .env

  # Update DATABASE_URL if using Docker (port 5556)
  if [ "$USING_DOCKER_DB" = true ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "s|DATABASE_URL=.*|DATABASE_URL=postgresql://current:current_password@localhost:5556/current_db|" .env
    else
      sed -i "s|DATABASE_URL=.*|DATABASE_URL=postgresql://current:current_password@localhost:5556/current_db|" .env
    fi
    print_success "Created .env from template (Docker DB on port 5556)"
  else
    print_success "Created .env from template"
  fi

  echo ""
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}Optional Configuration${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo "Press Enter to skip any option."
  echo ""

  # Anthropic API Key
  echo -e "${BLUE}Anthropic API Key${NC} (for AI features)"
  echo "Get your key at: https://console.anthropic.com"
  read -p "API Key: " ANTHROPIC_KEY
  if [ -n "$ANTHROPIC_KEY" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "s|AI_INTEGRATIONS_ANTHROPIC_API_KEY=.*|AI_INTEGRATIONS_ANTHROPIC_API_KEY=$ANTHROPIC_KEY|" .env
    else
      sed -i "s|AI_INTEGRATIONS_ANTHROPIC_API_KEY=.*|AI_INTEGRATIONS_ANTHROPIC_API_KEY=$ANTHROPIC_KEY|" .env
    fi
    print_success "Anthropic API key configured"
  else
    print_warning "Skipped (AI features won't work)"
  fi
  echo ""

  # Resend API Key
  echo -e "${BLUE}Resend API Key${NC} (for email notifications)"
  echo "Get your key at: https://resend.com"
  read -p "API Key: " RESEND_KEY
  if [ -n "$RESEND_KEY" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "s|RESEND_API_KEY=.*|RESEND_API_KEY=$RESEND_KEY|" .env
    else
      sed -i "s|RESEND_API_KEY=.*|RESEND_API_KEY=$RESEND_KEY|" .env
    fi
    print_success "Resend API key configured"
  else
    print_warning "Skipped (email features won't work)"
  fi

  echo ""
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
fi

echo ""

# ─────────────────────────────────────────────────────────
# Step 6: Database Migration
# ─────────────────────────────────────────────────────────
print_step "Running database migrations..."

# Source .env for DATABASE_URL
set -a
source .env
set +a

npm run db:push

print_success "Database schema updated"
echo ""

# ─────────────────────────────────────────────────────────
# Step 7: Seed Demo Data
# ─────────────────────────────────────────────────────────
print_step "Seeding demo data..."

# The seed runs automatically on server start, but we can trigger it manually too
# Check if we should seed by looking for existing data
npx tsx -e "
import { db } from './server/db.js';
import { suggestions } from './shared/schema.js';

async function checkAndSeed() {
  const existing = await db.select().from(suggestions).limit(1);
  if (existing.length === 0) {
    const { seedDemoData } = await import('./server/seed.js');
    await seedDemoData();
    console.log('Demo data seeded');
  } else {
    console.log('Data already exists, skipping seed');
  }
  process.exit(0);
}
checkAndSeed();
" 2>/dev/null || print_warning "Seeding will happen on first server start"

print_success "Demo data ready"
echo ""

# ─────────────────────────────────────────────────────────
# Success!
# ─────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}  ${BOLD}${GREEN}✓ Setup complete!${NC}                                        ${GREEN}║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${BOLD}To start developing:${NC}"
echo -e "    ${CYAN}npm run dev${NC}"
echo ""
echo -e "  Then open: ${CYAN}http://localhost:5000${NC}"
echo ""

if [ "$USING_DOCKER_DB" = true ]; then
  echo -e "  ${YELLOW}Database:${NC} Docker PostgreSQL (current_db)"
  echo -e "  ${YELLOW}Stop DB:${NC}  docker-compose -f docker-compose.db.yml down"
else
  echo -e "  ${YELLOW}Database:${NC} Local PostgreSQL"
fi

echo ""
echo -e "  ${BOLD}Optional next steps:${NC}"
echo "  • Edit .env to add more API keys (Slack, Zoom, Google)"
echo "  • Read SETUP.md for integration setup guides"
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
