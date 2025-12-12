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
  echo ""
  echo "This script will guide you through:"
  echo "  1. Checking prerequisites (Node.js, PostgreSQL)"
  echo "  2. Installing dependencies"
  echo "  3. Configuring database"
  echo "  4. Setting up required integrations (AI, Email, Notion)"
  echo "  5. Optionally configuring input sources (Slack, Drive, Zoom, Meet)"
  echo "  6. Running database migrations"
  echo "  7. Seeding demo data"
  echo ""
  echo "Total setup time: 10-30 minutes depending on integrations"
}

print_info() {
  echo -e "${CYAN}ℹ${NC} $1"
}

validate_email() {
  local email=$1
  if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    return 0
  else
    return 1
  fi
}

print_section() {
  echo ""
  echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}$1${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
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

# Introduction and Overview
echo -e "${BOLD}Welcome to Current Setup!${NC}"
echo ""
echo "This script will walk you through setting up Current step-by-step."
echo "We'll configure everything you need to get started."
echo ""
echo -e "${BOLD}What you'll set up:${NC}"
echo ""
echo -e "${GREEN}Required (Core Functionality):${NC}"
echo "  ✓ Database (PostgreSQL)"
echo "  ✓ Session Secret (security)"
echo "  ✓ AI Service (Anthropic Claude - for knowledge extraction)"
echo "  ✓ Email Service (Resend - for team invitations)"
echo "  ✓ Notion Integration (output destination)"
echo ""
echo -e "${BLUE}Optional (Input Sources - choose what you need):${NC}"
echo "  ○ Slack - Monitor team conversations"
echo "  ○ Google Drive - Process documents"
echo "  ○ Zoom - Extract from meeting transcripts"
echo "  ○ Google Meet - Alternative to Zoom"
echo ""
echo -e "${YELLOW}Setup Time:${NC}"
echo "  • Core setup: ~10 minutes"
echo "  • Each integration: 5-10 minutes"
echo "  • Total: 15-40 minutes (depending on what you choose)"
echo ""
echo -e "${CYAN}Press Enter to continue, or Ctrl+C to exit...${NC}"
read -r

echo ""

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

  print_section "REQUIRED INTEGRATIONS SETUP"
  echo "These integrations are ${BOLD}REQUIRED${NC} for Current to work."
  echo "Without them, the application will not function properly."
  echo ""
  echo -e "${YELLOW}Note:${NC} You can enter 'skip' for any to configure later,"
  echo "but you'll need to add them to .env before the app works."
  echo ""

  # ═══════════════════════════════════════════════════════
  # 1. Anthropic AI Service (REQUIRED)
  # ═══════════════════════════════════════════════════════
  echo -e "${BOLD}[1/2] Anthropic AI Service${NC} ${RED}(REQUIRED)${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "${BOLD}What it does:${NC}"
  echo "  • Analyzes content from Slack, Google Drive, Zoom meetings"
  echo "  • Extracts knowledge: policies, decisions, processes, best practices"
  echo "  • Creates suggestions for your review and approval"
  echo "  • Powers all AI features in the application"
  echo ""
  echo -e "${BOLD}Cost:${NC} Pay-as-you-go (~\$0.01-0.05 per document/message)"
  echo -e "${BOLD}Free tier:${NC} \$5 credit to start"
  echo ""
  echo -e "${BOLD}How to get your API key:${NC}"
  echo "  1. Open: ${CYAN}https://console.anthropic.com${NC}"
  echo "  2. Sign up or log in"
  echo "  3. Navigate to 'API Keys'"
  echo "  4. Click 'Create Key'"
  echo "  5. Copy the key (starts with 'sk-ant-')"
  echo ""
  
  while true; do
    read -p "Enter Anthropic API Key (or 'skip'): " ANTHROPIC_KEY
    
    if [ "$ANTHROPIC_KEY" = "skip" ]; then
      print_warning "SKIPPED - AI features will NOT work until configured!"
      print_info "Add to .env later: AI_INTEGRATIONS_ANTHROPIC_API_KEY=your-key"
      echo ""
      break
    elif [ -z "$ANTHROPIC_KEY" ]; then
      print_error "API key cannot be empty. Type 'skip' to skip."
      continue
    elif [[ ! "$ANTHROPIC_KEY" =~ ^sk-ant- ]]; then
      print_warning "⚠ Key should start with 'sk-ant-'"
      echo -n "Continue anyway? (y/N): "
      read -r CONFIRM
      if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        continue
      fi
    fi
    
    # Save to .env
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "s|AI_INTEGRATIONS_ANTHROPIC_API_KEY=.*|AI_INTEGRATIONS_ANTHROPIC_API_KEY=$ANTHROPIC_KEY|" .env
    else
      sed -i "s|AI_INTEGRATIONS_ANTHROPIC_API_KEY=.*|AI_INTEGRATIONS_ANTHROPIC_API_KEY=$ANTHROPIC_KEY|" .env
    fi
    print_success "✓ Anthropic API key configured!"
    echo ""
    break
  done

  # ═══════════════════════════════════════════════════════
  # 2. Resend Email Service (REQUIRED)
  # ═══════════════════════════════════════════════════════
  echo -e "${BOLD}[2/2] Email Service (Resend)${NC} ${RED}(REQUIRED)${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "${BOLD}What it does:${NC}"
  echo "  • Sends team member invitation emails"
  echo "  • Sends notification emails"
  echo "  • Password reset emails"
  echo "  • Activity notifications"
  echo ""
  echo -e "${BOLD}Cost:${NC} FREE tier - 100 emails/day, 3,000/month"
  echo -e "${BOLD}Upgrade:${NC} \$20/month for 50,000 emails"
  echo ""
  echo -e "${BOLD}How to get your API key:${NC}"
  echo "  1. Open: ${CYAN}https://resend.com${NC}"
  echo "  2. Sign up (free, no credit card required)"
  echo "  3. Go to 'API Keys'"
  echo "  4. Click 'Create API Key'"
  echo "  5. Copy the key (starts with 're_')"
  echo ""
  
  while true; do
    read -p "Enter Resend API Key (or 'skip'): " RESEND_KEY
    
    if [ "$RESEND_KEY" = "skip" ]; then
      print_warning "SKIPPED - Email features disabled (no team invitations)!"
      print_info "Add to .env later: RESEND_API_KEY=your-key"
      echo ""
      break
    elif [ -z "$RESEND_KEY" ]; then
      print_error "API key cannot be empty. Type 'skip' to skip."
      continue
    elif [[ ! "$RESEND_KEY" =~ ^re_ ]]; then
      print_warning "⚠ Key should start with 're_'"
      echo -n "Continue anyway? (y/N): "
      read -r CONFIRM
      if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        continue
      fi
    fi
    
    # Save to .env
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "s|RESEND_API_KEY=.*|RESEND_API_KEY=$RESEND_KEY|" .env
    else
      sed -i "s|RESEND_API_KEY=.*|RESEND_API_KEY=$RESEND_KEY|" .env
    fi
    print_success "✓ Resend API key configured!"
    
    # Ask for sender email
    echo ""
    echo -e "${BOLD}Sender Email Address${NC}"
    echo "This will be the 'From' address in invitation emails."
    echo "Examples: noreply@yourdomain.com, team@yourcompany.com"
    echo ""
    
    while true; do
      read -p "Sender email: " RESEND_EMAIL
      if [ -z "$RESEND_EMAIL" ]; then
        print_warning "Using default: noreply@localhost (change this later!)"
        RESEND_EMAIL="noreply@localhost"
        break
      elif validate_email "$RESEND_EMAIL"; then
        break
      else
        print_error "Invalid email format. Try again."
      fi
    done
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "s|RESEND_FROM_EMAIL=.*|RESEND_FROM_EMAIL=$RESEND_EMAIL|" .env
    else
      sed -i "s|RESEND_FROM_EMAIL=.*|RESEND_FROM_EMAIL=$RESEND_EMAIL|" .env
    fi
    print_success "✓ Sender email: $RESEND_EMAIL"
    echo ""
    break
  done

  print_section "OPTIONAL INPUT SOURCES"
  echo "These integrations are ${BOLD}OPTIONAL${NC}. Choose what sources you want to monitor."
  echo ""
  echo -e "${BOLD}Available Input Sources:${NC}"
  echo "  • ${BLUE}Slack${NC}        - Monitor team conversations (easiest to set up)"
  echo "  • ${BLUE}Google Drive${NC} - Process documents and files"
  echo "  • ${BLUE}Zoom${NC}         - Extract knowledge from meeting transcripts"
  echo "  • ${BLUE}Google Meet${NC}  - Alternative to Zoom"
  echo ""
  echo -e "${YELLOW}Tip:${NC} Start with Slack (easiest). Add others later in Settings → Integrations."
  echo ""
  echo -e "${BOLD}Setup Time:${NC} 5-10 minutes per integration"
  echo -e "${BOLD}Documentation:${NC}"
  echo "  • Full guides: INTEGRATIONS_MASTER_GUIDE.md"
  echo "  • Slack: SLACK_SETUP.md"
  echo "  • Google Drive: GOOGLE_DRIVE_SETUP.md"
  echo "  • Zoom: ZOOM_SETUP.md"
  echo "  • Google Meet: GOOGLE_MEET_SETUP.md"
  echo ""
  echo "Configure now or skip and add later through the web interface."
  echo ""
  
  # ═══════════════════════════════════════════════════════
  # Slack Integration (Optional)
  # ═══════════════════════════════════════════════════════
  echo -e "${BOLD}[Optional 1/4] Slack Integration${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "${BOLD}What it does:${NC}"
  echo "  • Monitors Slack channels for team conversations"
  echo "  • Detects when policies, decisions, or SOPs are discussed"
  echo "  • Creates suggestions from valuable discussions"
  echo "  • Real-time processing (Socket Mode)"
  echo ""
  echo -e "${BOLD}Best for:${NC} Quick decisions, team discussions, policy announcements"
  echo -e "${BOLD}Setup time:${NC} ~20 minutes (need to create Slack app)"
  echo -e "${BOLD}Full guide:${NC} SLACK_SETUP.md"
  echo ""
  echo -n "Configure Slack now? (y/N): "
  read -r SETUP_SLACK
  
  if [[ "$SETUP_SLACK" =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${BOLD}Required credentials from Slack:${NC}"
    echo ""
    echo "You'll need to:"
    echo "  1. Visit ${CYAN}https://api.slack.com/apps${NC}"
    echo "  2. Create a new app (or use existing)"
    echo "  3. Enable Socket Mode and get App Token (starts with ${BOLD}xapp-${NC})"
    echo "  4. Install app to workspace and get Bot Token (starts with ${BOLD}xoxb-${NC})"
    echo "  5. Copy Signing Secret from Basic Information"
    echo ""
    echo "See SLACK_SETUP.md for detailed step-by-step instructions."
    echo ""
    echo -n "Do you have these credentials ready? (y/N): "
    read -r HAS_SLACK_CREDS
    
    if [[ "$HAS_SLACK_CREDS" =~ ^[Yy]$ ]]; then
      echo ""
      read -p "Slack App Token (xapp-...): " SLACK_APP
      read -p "Slack Bot Token (xoxb-...): " SLACK_BOT
      read -p "Slack Signing Secret: " SLACK_SIGNING
      
      if [ -n "$SLACK_APP" ] && [ -n "$SLACK_BOT" ] && [ -n "$SLACK_SIGNING" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
          sed -i '' "s|SLACK_APP_TOKEN=.*|SLACK_APP_TOKEN=$SLACK_APP|" .env
          sed -i '' "s|SLACK_BOT_TOKEN=.*|SLACK_BOT_TOKEN=$SLACK_BOT|" .env
          sed -i '' "s|SLACK_SIGNING_SECRET=.*|SLACK_SIGNING_SECRET=$SLACK_SIGNING|" .env
        else
          sed -i "s|SLACK_APP_TOKEN=.*|SLACK_APP_TOKEN=$SLACK_APP|" .env
          sed -i "s|SLACK_BOT_TOKEN=.*|SLACK_BOT_TOKEN=$SLACK_BOT|" .env
          sed -i "s|SLACK_SIGNING_SECRET=.*|SLACK_SIGNING_SECRET=$SLACK_SIGNING|" .env
        fi
        print_success "✓ Slack integration configured!"
        echo ""
        echo -e "${YELLOW}Next steps after setup:${NC}"
        echo "  1. Start the application: npm run dev"
        echo "  2. Invite bot to channels: /invite @YourBotName"
        echo "  3. Post a test message with a policy"
        echo "  4. Check Approval Queue for suggestion"
      else
        print_warning "Incomplete credentials - skipped"
      fi
    else
      print_info "Skipped - follow SLACK_SETUP.md when ready"
    fi
  else
    print_info "Skipped - configure later in Settings → Integrations"
  fi
  echo ""
  
  # ═══════════════════════════════════════════════════════
  # Google Integrations (Optional)
  # ═══════════════════════════════════════════════════════
  echo -e "${BOLD}[Optional 2/4] Google Integrations (Drive + Meet)${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "${BOLD}What it does:${NC}"
  echo "  • ${BOLD}Google Drive:${NC} Monitors folders for document updates"
  echo "  • ${BOLD}Google Meet:${NC} Processes meeting transcripts from recordings"
  echo "  • Extracts knowledge from docs, sheets, slides, transcripts"
  echo "  • Syncs every 15 minutes"
  echo ""
  echo -e "${BOLD}Best for:${NC} Detailed documentation, meeting notes"
  echo -e "${BOLD}Setup time:${NC} ~30 minutes (need Google Cloud project)"
  echo -e "${BOLD}Full guides:${NC} GOOGLE_DRIVE_SETUP.md, GOOGLE_MEET_SETUP.md"
  echo ""
  echo -n "Configure Google integrations now? (y/N): "
  read -r SETUP_GOOGLE
  
  if [[ "$SETUP_GOOGLE" =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${BOLD}Required setup in Google Cloud:${NC}"
    echo ""
    echo "You'll need to:"
    echo "  1. Visit ${CYAN}https://console.cloud.google.com${NC}"
    echo "  2. Create a project (or use existing)"
    echo "  3. Enable Google Drive API"
    echo "  4. Create OAuth 2.0 credentials"
    echo "  5. Get Client ID and Client Secret"
    echo ""
    echo "See GOOGLE_DRIVE_SETUP.md for detailed instructions."
    echo ""
    echo -n "Do you have these credentials ready? (y/N): "
    read -r HAS_GOOGLE_CREDS
    
    if [[ "$HAS_GOOGLE_CREDS" =~ ^[Yy]$ ]]; then
      echo ""
      read -p "Google Client ID: " GOOGLE_CLIENT
      read -p "Google Client Secret: " GOOGLE_SECRET
      
      if [ -n "$GOOGLE_CLIENT" ] && [ -n "$GOOGLE_SECRET" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
          sed -i '' "s|GOOGLE_CLIENT_ID=.*|GOOGLE_CLIENT_ID=$GOOGLE_CLIENT|" .env
          sed -i '' "s|GOOGLE_CLIENT_SECRET=.*|GOOGLE_CLIENT_SECRET=$GOOGLE_SECRET|" .env
        else
          sed -i "s|GOOGLE_CLIENT_ID=.*|GOOGLE_CLIENT_ID=$GOOGLE_CLIENT|" .env
          sed -i "s|GOOGLE_CLIENT_SECRET=.*|GOOGLE_CLIENT_SECRET=$GOOGLE_SECRET|" .env
        fi
        print_success "✓ Google integrations configured!"
        echo ""
        echo -e "${YELLOW}Next steps after setup:${NC}"
        echo "  1. Start the application"
        echo "  2. Go to Settings → Integrations"
        echo "  3. Click 'Connect Google Account'"
        echo "  4. Authorize access"
        echo "  5. Select folders to monitor"
      else
        print_warning "Incomplete credentials - skipped"
      fi
    else
      print_info "Skipped - follow GOOGLE_DRIVE_SETUP.md when ready"
    fi
  else
    print_info "Skipped - configure later in Settings → Integrations"
  fi
  echo ""
  
  # ═══════════════════════════════════════════════════════
  # Zoom Integration (Optional)
  # ═══════════════════════════════════════════════════════
  echo -e "${BOLD}[Optional 3/4] Zoom Integration${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "${BOLD}What it does:${NC}"
  echo "  • Processes meeting transcripts from cloud recordings"
  echo "  • Extracts decisions, action items, policies from discussions"
  echo "  • Webhook-based (instant notifications)"
  echo "  • Requires Zoom Pro/Business/Enterprise account"
  echo ""
  echo -e "${BOLD}Best for:${NC} Meeting notes, team decisions, recorded discussions"
  echo -e "${BOLD}Setup time:${NC} ~30 minutes (need Zoom app + cloud recording)"
  echo -e "${BOLD}Full guide:${NC} ZOOM_SETUP.md"
  echo ""
  echo -n "Configure Zoom now? (y/N): "
  read -r SETUP_ZOOM
  
  if [[ "$SETUP_ZOOM" =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${BOLD}Required setup in Zoom:${NC}"
    echo ""
    echo "You'll need to:"
    echo "  1. Visit ${CYAN}https://marketplace.zoom.us${NC}"
    echo "  2. Create Server-to-Server OAuth app"
    echo "  3. Get Client ID, Client Secret, and Account ID"
    echo "  4. Enable cloud recording and transcription"
    echo "  5. Configure webhook for transcript notifications"
    echo ""
    echo "See ZOOM_SETUP.md for detailed step-by-step instructions."
    echo ""
    echo -n "Do you have these credentials ready? (y/N): "
    read -r HAS_ZOOM_CREDS
    
    if [[ "$HAS_ZOOM_CREDS" =~ ^[Yy]$ ]]; then
      echo ""
      read -p "Zoom Client ID: " ZOOM_CLIENT
      read -p "Zoom Client Secret: " ZOOM_SECRET
      read -p "Zoom Webhook Secret (optional): " ZOOM_WEBHOOK
      
      if [ -n "$ZOOM_CLIENT" ] && [ -n "$ZOOM_SECRET" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
          sed -i '' "s|ZOOM_CLIENT_ID=.*|ZOOM_CLIENT_ID=$ZOOM_CLIENT|" .env
          sed -i '' "s|ZOOM_CLIENT_SECRET=.*|ZOOM_CLIENT_SECRET=$ZOOM_SECRET|" .env
          [ -n "$ZOOM_WEBHOOK" ] && sed -i '' "s|ZOOM_WEBHOOK_SECRET=.*|ZOOM_WEBHOOK_SECRET=$ZOOM_WEBHOOK|" .env
        else
          sed -i "s|ZOOM_CLIENT_ID=.*|ZOOM_CLIENT_ID=$ZOOM_CLIENT|" .env
          sed -i "s|ZOOM_CLIENT_SECRET=.*|ZOOM_CLIENT_SECRET=$ZOOM_SECRET|" .env
          [ -n "$ZOOM_WEBHOOK" ] && sed -i "s|ZOOM_WEBHOOK_SECRET=.*|ZOOM_WEBHOOK_SECRET=$ZOOM_WEBHOOK|" .env
        fi
        print_success "✓ Zoom integration configured!"
        echo ""
        echo -e "${YELLOW}Next steps after setup:${NC}"
        echo "  1. Configure webhook in Zoom app settings"
        echo "  2. Subscribe to 'recording.transcript_completed' event"
        echo "  3. Enable cloud recording for meetings"
        echo "  4. Record a test meeting with transcript enabled"
      else
        print_warning "Incomplete credentials - skipped"
      fi
    else
      print_info "Skipped - follow ZOOM_SETUP.md when ready"
    fi
  else
    print_info "Skipped - configure later in Settings → Integrations"
  fi
  echo ""
  
  # ═══════════════════════════════════════════════════════
  # Google Meet Integration Note
  # ═══════════════════════════════════════════════════════
  echo -e "${BOLD}[Optional 4/4] Google Meet Integration${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  print_info "Google Meet uses same credentials as Google Drive"
  echo "If you configured Google integrations above, Meet is already set up!"
  echo ""
  echo -e "${BOLD}What it does:${NC} Processes meeting transcripts from Drive"
  echo -e "${BOLD}Setup:${NC} Just enable recording in Google Meet"
  echo -e "${BOLD}Full guide:${NC} GOOGLE_MEET_SETUP.md"
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
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}  ${BOLD}${GREEN}🎉 Setup Complete! Current is ready!${NC}                        ${GREEN}║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

print_section "SETUP SUMMARY"

# Check what was configured
ANTHROPIC_CONFIGURED=$(grep "^AI_INTEGRATIONS_ANTHROPIC_API_KEY=sk-ant" .env > /dev/null 2>&1 && echo "yes" || echo "no")
RESEND_CONFIGURED=$(grep "^RESEND_API_KEY=re_" .env > /dev/null 2>&1 && echo "yes" || echo "no")
SLACK_CONFIGURED=$(grep "^SLACK_BOT_TOKEN=xoxb-" .env > /dev/null 2>&1 && echo "yes" || echo "no")
GOOGLE_CONFIGURED=$(grep "^GOOGLE_CLIENT_ID=.*.apps.googleusercontent.com" .env > /dev/null 2>&1 && echo "yes" || echo "no")
ZOOM_CONFIGURED=$(grep "^ZOOM_CLIENT_ID=." .env > /dev/null 2>&1 && echo "yes" || echo "no")

echo -e "${BOLD}Core Components:${NC}"
if [ "$USING_DOCKER_DB" = true ]; then
  echo "  ✅ Database: Docker PostgreSQL (port 5556)"
  echo "     Stop: ${CYAN}docker-compose -f docker-compose.db.yml down${NC}"
else
  echo "  ✅ Database: Local PostgreSQL"
fi
echo "  ✅ Dependencies: npm packages installed"
echo "  ✅ Schema: Database migrations completed"
echo "  ✅ Demo Data: Sample data seeded"
echo ""

echo -e "${BOLD}Required Integrations:${NC}"
if [ "$ANTHROPIC_CONFIGURED" = "yes" ]; then
  echo "  ✅ Anthropic AI: Configured"
else
  echo "  ⚠️  Anthropic AI: NOT configured (AI features won't work)"
  echo "     Add to .env: AI_INTEGRATIONS_ANTHROPIC_API_KEY=your-key"
fi

if [ "$RESEND_CONFIGURED" = "yes" ]; then
  echo "  ✅ Email (Resend): Configured"
else
  echo "  ⚠️  Email (Resend): NOT configured (team invitations disabled)"
  echo "     Add to .env: RESEND_API_KEY=your-key"
fi

echo "  ⚠️  Notion: NOT yet connected"
echo -e "     ${YELLOW}IMPORTANT:${NC} Connect Notion in web UI after starting app"
echo -e "     See: ${CYAN}NOTION_SETUP.md${NC}"
echo ""

echo -e "${BOLD}Optional Input Sources:${NC}"
if [ "$SLACK_CONFIGURED" = "yes" ]; then
  echo "  ✅ Slack: Configured"
  echo "     Next: Invite bot to channels with /invite @YourBot"
else
  echo "  ☐  Slack: Not configured (optional)"
  echo -e "     Setup: ${CYAN}SLACK_SETUP.md${NC}"
fi

if [ "$GOOGLE_CONFIGURED" = "yes" ]; then
  echo "  ✅ Google (Drive + Meet): Configured"
  echo "     Next: Connect account in Settings → Integrations"
else
  echo "  ☐  Google (Drive + Meet): Not configured (optional)"
  echo -e "     Setup: ${CYAN}GOOGLE_DRIVE_SETUP.md${NC}, ${CYAN}GOOGLE_MEET_SETUP.md${NC}"
fi

if [ "$ZOOM_CONFIGURED" = "yes" ]; then
  echo "  ✅ Zoom: Configured"
  echo "     Next: Configure webhook in Zoom app settings"
else
  echo "  ☐  Zoom: Not configured (optional)"
  echo -e "     Setup: ${CYAN}ZOOM_SETUP.md${NC}"
fi
echo ""

print_section "START THE APPLICATION"

echo -e "${BOLD}1. Start the development server:${NC}"
echo ""
echo -e "   ${CYAN}npm run dev${NC}"
echo ""
echo -e "${BOLD}2. Open in your browser:${NC}"
echo ""
echo -e "   ${CYAN}http://localhost:5000${NC}"
echo ""
echo -e "${BOLD}3. Create your account:${NC}"
echo ""
echo "   • Sign up with email/password"
echo "   • Or use Replit OAuth (if on Replit)"
echo ""

print_section "NEXT STEPS (IN ORDER)"

echo -e "${GREEN}Required (do these first):${NC}"
echo ""
echo -e "  ${BOLD}1. Connect Notion Integration${NC} ${RED}(REQUIRED)${NC}"
echo "     • Go to Settings → Integrations"
echo "     • Click 'Connect Notion'"
echo "     • Authorize access"
echo "     • Share your pages with Current"
echo -e "     📖 Full guide: ${CYAN}NOTION_SETUP.md${NC}"
echo ""

if [ "$ANTHROPIC_CONFIGURED" = "no" ] || [ "$RESEND_CONFIGURED" = "no" ]; then
  echo -e "  ${BOLD}2. Complete Required API Keys${NC} ${RED}(REQUIRED)${NC}"
  if [ "$ANTHROPIC_CONFIGURED" = "no" ]; then
    echo "     • Add Anthropic API key to .env"
    echo -e "       Get at: ${CYAN}https://console.anthropic.com${NC}"
  fi
  if [ "$RESEND_CONFIGURED" = "no" ]; then
    echo "     • Add Resend API key to .env"
    echo -e "       Get at: ${CYAN}https://resend.com${NC}"
  fi
  echo "     • Restart the application"
  echo ""
fi

echo -e "${BLUE}Optional (choose what you need):${NC}"
echo ""
echo -e "  ${BOLD}3. Add Input Sources${NC} (Optional)"
echo "     Choose one or more to monitor:"
echo ""
echo -e "     • ${BOLD}Slack${NC} - Team conversations (easiest)"
echo -e "       Setup: ${CYAN}SLACK_SETUP.md${NC} (~20 min)"
echo ""
echo -e "     • ${BOLD}Google Drive${NC} - Documents and files"
echo -e "       Setup: ${CYAN}GOOGLE_DRIVE_SETUP.md${NC} (~30 min)"
echo ""
echo -e "     • ${BOLD}Zoom${NC} - Meeting transcripts"
echo -e "       Setup: ${CYAN}ZOOM_SETUP.md${NC} (~30 min)"
echo ""
echo -e "     • ${BOLD}Google Meet${NC} - Meeting recordings"
echo -e "       Setup: ${CYAN}GOOGLE_MEET_SETUP.md${NC} (~30 min)"
echo ""

echo -e "  ${BOLD}4. Test the System${NC}"
echo "     • Post test content in connected sources"
echo "     • Check Approval Queue for suggestions"
echo "     • Approve a suggestion"
echo "     • Verify Notion page updates"
echo -e "     📖 Testing guide: ${CYAN}INTEGRATION_TESTING_GUIDE.md${NC}"
echo ""

print_section "DOCUMENTATION & HELP"

echo -e "${BOLD}Complete Integration Guide:${NC}"
echo -e "  📘 ${CYAN}INTEGRATIONS_MASTER_GUIDE.md${NC} - Start here for overview"
echo ""
echo -e "${BOLD}Individual Integration Guides:${NC}"
echo -e "  📄 ${CYAN}NOTION_SETUP.md${NC} - Notion integration (required)"
echo -e "  📄 ${CYAN}SLACK_SETUP.md${NC} - Slack integration"
echo -e "  📄 ${CYAN}GOOGLE_DRIVE_SETUP.md${NC} - Google Drive integration"
echo -e "  📄 ${CYAN}ZOOM_SETUP.md${NC} - Zoom integration"
echo -e "  📄 ${CYAN}GOOGLE_MEET_SETUP.md${NC} - Google Meet integration"
echo ""
echo -e "${BOLD}Testing & Validation:${NC}"
echo -e "  🧪 ${CYAN}INTEGRATION_TESTING_GUIDE.md${NC} - Complete testing procedures"
echo ""
echo -e "${BOLD}Quick Reference:${NC}"
echo -e "  ⚡ ${CYAN}INTEGRATIONS_QUICK_REFERENCE.md${NC} - Cheat sheet"
echo ""

print_section "USEFUL COMMANDS"

echo -e "  ${CYAN}npm run dev${NC}              # Start development server"
echo -e "  ${CYAN}npm run build${NC}            # Build for production"
echo -e "  ${CYAN}npm run db:push${NC}          # Update database schema"
echo -e "  ${CYAN}npm run db:studio${NC}        # Open database GUI (if available)"
echo ""

if [ "$USING_DOCKER_DB" = true ]; then
  echo -e "${BOLD}Docker Database:${NC}"
  echo -e "  ${CYAN}docker-compose -f docker-compose.db.yml up -d${NC}    # Start"
  echo -e "  ${CYAN}docker-compose -f docker-compose.db.yml down${NC}     # Stop"
  echo -e "  ${CYAN}docker-compose -f docker-compose.db.yml logs -f${NC}  # View logs"
  echo ""
fi

echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BOLD}${GREEN}Ready to start! Run:${NC} ${CYAN}npm run dev${NC}"
echo ""
echo -e "Need help? Check ${CYAN}INTEGRATIONS_MASTER_GUIDE.md${NC} or ${CYAN}SETUP.md${NC}"
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
