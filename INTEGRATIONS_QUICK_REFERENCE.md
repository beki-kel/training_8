# Integrations Quick Reference Guide

## 🚀 Quick Start (5 Minutes)

```bash
# 1. Clone and setup
git clone <repo>
cd Archive
./setup.sh

# 2. Start application
npm run dev

# 3. Open browser
http://localhost:5000
```

## 📚 Documentation Files

| File | Purpose | When to Use |
|------|---------|-------------|
| **INTEGRATIONS_MASTER_GUIDE.md** | Complete overview | Start here |
| **NOTION_SETUP.md** | Notion integration | Required setup |
| **SLACK_SETUP.md** | Slack integration | Optional: Team chat |
| **GOOGLE_DRIVE_SETUP.md** | Google Drive | Optional: Documents |
| **MEETING_SETUP.md** | Zoom & Google Meet | Optional: Meetings |
| **INTEGRATION_TESTING_GUIDE.md** | Testing procedures | Verify everything works |
| **SETUP.md** | General setup | Getting started |

## 🔧 Environment Variables Cheat Sheet

### Required (Core)
```bash
DATABASE_URL=postgresql://user:pass@localhost:5432/current_db
SESSION_SECRET=<run: openssl rand -hex 32>
AI_INTEGRATIONS_ANTHROPIC_API_KEY=sk-ant-your-key
RESEND_API_KEY=re_your-key
RESEND_FROM_EMAIL=noreply@yourdomain.com
```

### Required (Notion)
```bash
NOTION_CLIENT_ID=your-notion-client-id
NOTION_CLIENT_SECRET=your-notion-client-secret
```

### Optional (Slack)
```bash
SLACK_APP_TOKEN=xapp-your-token
SLACK_BOT_TOKEN=xoxb-your-token
SLACK_SIGNING_SECRET=your-secret
```

### Optional (Google)
```bash
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-secret
```

### Optional (Zoom)
```bash
ZOOM_CLIENT_ID=your-zoom-client-id
ZOOM_CLIENT_SECRET=your-zoom-secret
ZOOM_WEBHOOK_SECRET=your-webhook-secret
```

## 🎯 Setup Priorities

### Phase 1: Core (Required) - 20 minutes
1. ✅ Database setup
2. ✅ Generate session secret
3. ✅ Get Anthropic API key ([console.anthropic.com](https://console.anthropic.com))
4. ✅ Get Resend API key ([resend.com](https://resend.com))

### Phase 2: Notion (Required) - 10 minutes
1. ✅ Read `NOTION_SETUP.md`
2. ✅ Create Notion integration
3. ✅ Add to `.env`
4. ✅ Share pages with integration

### Phase 3: Input Source (Optional) - 20-30 minutes
**Choose ONE to start:**
- **Easiest**: Slack → `SLACK_SETUP.md`
- **Documents**: Google Drive → `GOOGLE_DRIVE_SETUP.md`
- **Meetings**: Zoom → `MEETING_SETUP.md`

## 🧪 Testing Checklist

### Core Services
```bash
# Database
psql -h localhost -U current -d current_db -c "SELECT 1;"

# Application health
curl http://localhost:5000/api/health
```

### Notion
1. Settings → Integrations → Check "Connected"
2. Create test suggestion
3. Approve → Verify in Notion page

### Slack
1. Post in monitored channel: "New policy: Test"
2. Check Approval Queue (< 30 seconds)
3. Approve → Verify in Notion

### Google Drive
1. Create doc in monitored folder
2. Wait 15 minutes for sync
3. Check Approval Queue
4. Approve → Verify in Notion

### Zoom
1. Record meeting with transcript
2. Wait for processing
3. Check Approval Queue
4. Approve → Verify in Notion

## 🔍 Troubleshooting Quick Fixes

### "Database connection failed"
```bash
# Start PostgreSQL
sudo service postgresql start
# OR use Docker
docker-compose -f docker-compose.db.yml up -d
```

### "Notion not connected"
```bash
# Check environment variables
cat .env | grep NOTION

# Restart application
# Ctrl+C then: npm run dev
```

### "Slack not processing messages"
- ✅ Bot invited to channel? `/invite @BotName`
- ✅ Socket Mode connected? Check logs
- ✅ Message format clear? Try: "New policy: [description]"

### "Google Drive not syncing"
- ✅ Folder shared with integration?
- ✅ Last sync time? Check Settings
- ✅ OAuth token valid? Reconnect if expired

### "AI not working"
```bash
# Verify API key
cat .env | grep ANTHROPIC

# Check Anthropic dashboard for quota
# Visit: https://console.anthropic.com
```

## 📊 Integration Status Dashboard

Check: **Settings → Integrations**

| Status | Icon | Meaning |
|--------|------|---------|
| Connected | 🟢 | Working normally |
| Warning | 🟡 | Minor issues |
| Error | 🔴 | Not working |
| Not Connected | ⚪ | Not set up |

## 🔗 Quick Links

### Setup API Keys
- Anthropic AI: https://console.anthropic.com
- Resend Email: https://resend.com
- Notion: https://www.notion.com/my-integrations
- Slack: https://api.slack.com/apps
- Google Cloud: https://console.cloud.google.com
- Zoom: https://marketplace.zoom.us

### Documentation
- Anthropic API: https://docs.anthropic.com
- Notion API: https://developers.notion.com
- Slack API: https://api.slack.com
- Google Drive API: https://developers.google.com/drive
- Zoom API: https://developers.zoom.us

## ⚡ Common Commands

```bash
# Setup
./setup.sh                    # Standard setup
./setup.sh --docker           # Force Docker PostgreSQL
./setup.sh --reset            # Clean slate

# Development
npm run dev                   # Start application
npm run db:push               # Update database schema
npm run build                 # Build for production

# Database
psql -h localhost -U current -d current_db     # Connect to DB
npm run db:studio             # Open Drizzle Studio (if available)

# Testing
curl http://localhost:5000/api/health          # Health check
curl http://localhost:5000/api/integrations/status  # Integration status
```

## 📝 File Locations

```
Archive/
├── .env                          # Your configuration (create from .env.example)
├── .env.example                  # Template with all variables
├── setup.sh                      # Automated setup script
│
├── Documentation/
│   ├── INTEGRATIONS_MASTER_GUIDE.md      # Start here
│   ├── NOTION_SETUP.md                   # Required
│   ├── SLACK_SETUP.md                    # Optional
│   ├── GOOGLE_DRIVE_SETUP.md             # Optional
│   ├── MEETING_SETUP.md                  # Optional (Zoom/Meet)
│   ├── INTEGRATION_TESTING_GUIDE.md      # Testing
│   └── INTEGRATIONS_QUICK_REFERENCE.md   # This file
│
└── Application/
    ├── server/                   # Backend code
    ├── client/                   # Frontend code
    └── shared/                   # Shared types/schema
```

## 🎓 Learning Path

### For Developers
1. Read `SETUP.md`
2. Read `INTEGRATIONS_MASTER_GUIDE.md`
3. Follow setup for your chosen integrations
4. Read `INTEGRATION_TESTING_GUIDE.md`
5. Test everything

### For QA/Testing
1. Read `INTEGRATION_TESTING_GUIDE.md`
2. Run all test scenarios
3. Report issues

### For DevOps
1. Read `.env.example`
2. Read `INTEGRATIONS_MASTER_GUIDE.md` (Production Checklist)
3. Set up monitoring
4. Configure backups

### For End Users
1. Read integration "How It Works" sections
2. Learn approval workflow
3. Understand what gets processed

## 💡 Tips & Best Practices

### Setup
- ✅ Start with required integrations only
- ✅ Add optional ones gradually
- ✅ Test each integration before adding next
- ✅ Use `setup.sh` for automated setup

### Configuration
- ✅ Never commit `.env` to git
- ✅ Generate strong SESSION_SECRET
- ✅ Rotate API keys periodically
- ✅ Use minimal permissions

### Testing
- ✅ Test after each integration setup
- ✅ Verify end-to-end flow
- ✅ Check error handling
- ✅ Monitor logs

### Production
- ✅ Use HTTPS only
- ✅ Enable monitoring/alerts
- ✅ Set up backups
- ✅ Review security regularly
- ✅ Document custom configurations

## 📞 Getting Help

### Check These First
1. **Application logs** - Look for error messages
2. **Integration status** - Settings → Integrations
3. **Activity log** - See what's happening
4. **Environment variables** - Verify all set correctly

### Then Consult
1. **Troubleshooting sections** in each guide
2. **INTEGRATIONS_MASTER_GUIDE.md** - Troubleshooting Decision Tree
3. **INTEGRATION_TESTING_GUIDE.md** - Test procedures
4. **External API documentation** - Official docs

## ⏱️ Time Estimates

| Task | Time | Difficulty |
|------|------|------------|
| Initial Setup (./setup.sh) | 10 min | Easy |
| Notion Integration | 10 min | Easy |
| Slack Integration | 20 min | Medium |
| Google Drive Integration | 30 min | Medium |
| Zoom Integration | 30 min | Hard |
| Google Meet Integration | 30 min | Hard |
| Testing All | 60 min | Medium |
| **Total (All Integrations)** | **3 hours** | - |
| **Minimum (Core + Notion)** | **30 min** | - |

## ✅ Daily Checklist

### Morning
- [ ] Check integration status
- [ ] Review overnight suggestions
- [ ] Check for errors in logs

### During Day
- [ ] Review and approve suggestions
- [ ] Monitor notification channels
- [ ] Respond to team questions

### Evening
- [ ] Review activity log
- [ ] Check integration health
- [ ] Plan any maintenance

## 🎉 Success Criteria

You're ready for production when:
- ✅ All required integrations connected
- ✅ At least one input source working
- ✅ Suggestions being created automatically
- ✅ Approval workflow functioning
- ✅ Notion updates working
- ✅ Team trained on process
- ✅ Monitoring in place
- ✅ Error handling tested

---

**Need more details?** See the full guides!

**Still stuck?** Check troubleshooting sections in each guide.

**Ready to start?** Run `./setup.sh` now! 🚀

