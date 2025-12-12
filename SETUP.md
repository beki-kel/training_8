# *Current* - Setup Guide

This guide will help you get *Current* up and running for your team.

---

## Local Development Quick Start

**New engineers can start contributing in under 10 minutes!**

```bash
git clone <repo>
cd heycurrent
./setup.sh
npm run dev
```

Then open: http://localhost:5000

### What the setup script does:
1. Checks prerequisites (Node.js 18+, npm)
2. Installs npm dependencies
3. Detects local PostgreSQL (or uses Docker as fallback)
4. Creates `.env` with interactive prompts for optional API keys
5. Runs database migrations
6. Seeds demo data

### Setup options:
```bash
./setup.sh           # Standard setup
./setup.sh --docker  # Force Docker PostgreSQL
./setup.sh --reset   # Clean slate (drop DB, regenerate .env)
./setup.sh --help    # Show help
```

### Prerequisites:
- **Node.js 18+** - [nodejs.org](https://nodejs.org)
- **PostgreSQL** - Local installation OR Docker

---

## Integration Setup

Current connects to your team's tools to automatically keep your knowledge base up-to-date. See detailed guides for each integration below.

### Quick Reference

| Integration | Status | Setup Time | Documentation |
|------------|--------|------------|---------------|
| **Notion** | Required | 10 min | [NOTION_SETUP.md](./NOTION_SETUP.md) |
| **Anthropic AI** | Required | 5 min | Get key at [console.anthropic.com](https://console.anthropic.com) |
| **Email (Resend)** | Required | 5 min | Get key at [resend.com](https://resend.com) |
| **Slack** | Optional | 20 min | [SLACK_SETUP.md](./SLACK_SETUP.md) |
| **Google Drive** | Optional | 30 min | [GOOGLE_DRIVE_SETUP.md](./GOOGLE_DRIVE_SETUP.md) |
| **Zoom** | Optional | 30 min | [MEETING_SETUP.md](./MEETING_SETUP.md) |
| **Google Meet** | Optional | 30 min | [MEETING_SETUP.md](./MEETING_SETUP.md) |

### Complete Integration Guide

**📚 See [INTEGRATIONS_MASTER_GUIDE.md](./INTEGRATIONS_MASTER_GUIDE.md)** for:
- Complete integration overview
- Setup order recommendations
- Comparison of all integrations
- Troubleshooting guide
- Best practices

### Setup Priority

**1. Core Requirements (Required)**
```bash
✅ Database (PostgreSQL)
✅ Session Secret
✅ Anthropic AI API Key
✅ Email Service (Resend)
✅ Notion Integration
```

**2. Input Sources (Choose one or more)**
```bash
☐ Slack - Best for team conversations
☐ Google Drive - Best for documents
☐ Zoom - Best for meeting transcripts
☐ Google Meet - Alternative to Zoom
```

### Environment Variables

#### Required Variables

```env
# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/current_db

# Session
SESSION_SECRET=<generate with: openssl rand -hex 32>

# AI Service (Required for knowledge extraction)
AI_INTEGRATIONS_ANTHROPIC_API_KEY=sk-ant-your-key-here

# Email Service (Required for team invitations)
RESEND_API_KEY=re_your-key-here
RESEND_FROM_EMAIL=noreply@yourdomain.com

# Notion (Required - output destination)
NOTION_CLIENT_ID=your-client-id
NOTION_CLIENT_SECRET=your-client-secret
```

#### Optional Variables (Input Sources)

```env
# Slack Integration
SLACK_APP_TOKEN=xapp-your-token
SLACK_BOT_TOKEN=xoxb-your-token
SLACK_SIGNING_SECRET=your-secret

# Google Integrations (Drive, Meet)
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-client-secret

# Zoom Integration
ZOOM_CLIENT_ID=your-zoom-client-id
ZOOM_CLIENT_SECRET=your-zoom-client-secret
ZOOM_WEBHOOK_SECRET=your-webhook-secret
```

**📄 See [.env.example](./.env.example)** for complete configuration template with detailed comments.

### 3. Invite Your Team

1. Go to **Settings > Team**
2. Click **Invite Member**
3. Enter their email and select a role (Admin or Member)
4. They'll receive an email invitation to join

## How It Works

### Knowledge Detection Flow

```
Source (Slack/Drive/Meeting) 
    ↓
AI Extraction (Claude analyzes content)
    ↓
Validation (confidence scoring)
    ↓
Suggestion Queue (human review)
    ↓
Approved → Notion Update
```

### Approval Workflow

1. **Dashboard** shows pending suggestions with confidence scores
2. **Review** each suggestion with side-by-side comparison
3. **Approve** to sync to Notion, or **Reject** with feedback
4. **Activity Log** tracks all decisions for audit

## Pricing Tiers

| Plan | Price | Suggestions/mo | Sources | Team Seats |
|------|-------|----------------|---------|------------|
| Starter | $99/mo | 100 | 2 | 3 |
| Growth | $199/mo | 500 | 4 | 10 |
| Scale | $399/mo | 2,000 | 6 | 25 |
| Pro Scale | $699/mo | 5,000 | Unlimited | 50 |
| Enterprise | Custom | Unlimited | Unlimited | Unlimited |

All plans include a **14-day free trial**.

## Troubleshooting

### "Notion not connected"

1. Go to Settings > Integrations
2. Click "Connect" next to Notion
3. Authorize *Current* to access your Notion workspace
4. Make sure you share the pages you want to update

### "No matching Notion page found"

When approving a suggestion, *Current* searches for a matching page title in Notion. Ensure:
- The page exists in your connected Notion workspace
- The page is shared with the *Current* integration
- The title matches closely (AI will suggest the best match)

### Slack messages not appearing

1. Ensure Slack is connected in Settings > Integrations
2. Invite the *Current* bot to the channels you want to monitor
3. Check that Socket Mode is enabled in your Slack app settings

## Support

- **Email**: support@getcurrent.ai
- **Documentation**: This guide + in-app help
- **Book a Demo**: [/book-demo](/book-demo)

---

*Current* - AI-Powered Knowledge Base
