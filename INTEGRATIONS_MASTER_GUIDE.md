# Current - Complete Integrations Setup Guide

## Overview

Current connects to your team's tools to automatically keep your knowledge base up-to-date. This guide covers all integrations and how to set them up.

## Integration Architecture

```
Input Sources                 Processing                 Output
─────────────────            ───────────              ─────────
📱 Slack                  →                        → 📓 Notion
📄 Google Drive          →   🤖 AI Analysis      →    (Required)
📹 Zoom                  →   ✅ Human Approval   →
🎥 Google Meet           →                        →
```

## Quick Setup Checklist

### Core Requirements (Must Have)
- [ ] **Notion** - Output destination (required)
- [ ] **Anthropic AI** - Knowledge extraction (required)
- [ ] **Database** - PostgreSQL (required)
- [ ] **Email Service** - Resend for invitations (required)

### Input Sources (Choose One or More)
- [ ] **Slack** - Monitor team conversations
- [ ] **Google Drive** - Process documents
- [ ] **Zoom** - Extract from meeting transcripts
- [ ] **Google Meet** - Process meeting recordings

## Setup Order (Recommended)

1. **Core Setup** (15 minutes)
   - ✅ Database
   - ✅ Email service
   - ✅ Anthropic API

2. **Notion Integration** (10 minutes)
   - ✅ Required for all knowledge updates
   - ✅ Follow: `NOTION_SETUP.md`

3. **Choose Input Sources** (20-30 minutes each)
   - **Slack**: Best for quick decisions/policies
   - **Google Drive**: Best for detailed documentation  
   - **Zoom/Meet**: Best for meeting knowledge

## Integration Comparison

| Integration | Setup Time | Complexity | Best For | Real-time |
|------------|------------|------------|----------|-----------|
| **Notion** | 10 min | Easy | Output destination | N/A |
| **Slack** | 20 min | Medium | Quick decisions | ✅ Yes |
| **Google Drive** | 30 min | Medium | Documentation | ⏱️ 15min delay |
| **Zoom** | 30 min | Hard | Meetings | ⏱️ After meeting |
| **Google Meet** | 30 min | Hard | Meetings | ⏱️ After meeting |

## Detailed Setup Guides

Each integration has its own detailed guide:

- **[NOTION_SETUP.md](./NOTION_SETUP.md)** - Notion integration (Required)
- **[SLACK_SETUP.md](./SLACK_SETUP.md)** - Slack integration
- **[GOOGLE_DRIVE_SETUP.md](./GOOGLE_DRIVE_SETUP.md)** - Google Drive integration  
- **[MEETING_SETUP.md](./MEETING_SETUP.md)** - Zoom & Google Meet

## Environment Variables Reference

### Core Variables
```env
# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/current_db

# Session
SESSION_SECRET=your-random-secret-here

# AI Service
AI_INTEGRATIONS_ANTHROPIC_API_KEY=sk-ant-your-key

# Email Service
RESEND_API_KEY=re_your-key
RESEND_FROM_EMAIL=noreply@yourdomain.com
```

### Notion (Required)
```env
# For Replit: Managed automatically
# For Local/OAuth:
NOTION_CLIENT_ID=your-client-id
NOTION_CLIENT_SECRET=your-client-secret
```

### Slack (Optional)
```env
SLACK_APP_TOKEN=xapp-your-app-token
SLACK_BOT_TOKEN=xoxb-your-bot-token
SLACK_SIGNING_SECRET=your-signing-secret
```

### Google Services (Optional)
```env
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-client-secret
```

### Zoom (Optional)
```env
ZOOM_CLIENT_ID=your-zoom-client-id
ZOOM_CLIENT_SECRET=your-zoom-client-secret
ZOOM_WEBHOOK_SECRET=your-webhook-secret
```

## Testing All Integrations

### 1. Test Notion (Required First)
```bash
# In app: Settings → Integrations → Notion
# Should show: ✅ Connected
```

### 2. Test Input Sources
Choose your test based on what you connected:

**Slack Test**:
```
Post in monitored channel:
"New policy: All PRs require 2 approvals before merge."
```

**Google Drive Test**:
```
Create document in monitored folder with policy content.
```

**Zoom Test**:
```
Record a meeting with cloud recording enabled.
Wait for transcript (takes ~2x meeting length).
```

### 3. Verify End-to-End
1. Input source processes content
2. AI creates suggestion
3. Suggestion appears in queue  
4. Approve suggestion
5. Notion page updates
6. Check activity log

## Common Issues & Solutions

### "No integrations working"

Check core requirements first:
```bash
# Verify environment variables
echo $DATABASE_URL
echo $AI_INTEGRATIONS_ANTHROPIC_API_KEY
echo $RESEND_API_KEY

# Check application logs
tail -f logs/application.log
```

### "Notion not connected"

1. **For Replit**:
   - Tools → Connectors → Reconnect Notion

2. **For Local**:
   - Check `NOTION_CLIENT_ID` and `NOTION_CLIENT_SECRET`
   - Restart application

3. **Share pages**:
   - Open Notion page
   - Share with "Current" integration

### "Suggestions not appearing"

1. **Check source integration**:
   - Settings → Integrations
   - All sources should show "Connected"

2. **Check AI service**:
   - Verify Anthropic API key
   - Check API quota/limits

3. **Check logs**:
   ```bash
   grep "Created suggestion" logs
   grep "confidence" logs
   ```

### "Can't update Notion pages"

1. **Check permissions**:
   - Page must be shared with integration
   - Integration needs "Update content" capability

2. **Check Notion API limits**:
   - 3 requests/second
   - Wait and retry

## Production Deployment Checklist

### Core Setup
- [ ] PostgreSQL database configured
- [ ] Environment variables set
- [ ] Session secret generated (secure random)
- [ ] Application accessible via HTTPS

### Integrations
- [ ] Notion connected and tested
- [ ] At least one input source connected
- [ ] All webhooks configured (if applicable)
- [ ] API keys secured (not in code)
- [ ] Rate limits understood

### Security
- [ ] HTTPS only (no HTTP)
- [ ] Webhook signatures verified
- [ ] API tokens encrypted at rest
- [ ] Minimal permissions granted
- [ ] Regular security audits scheduled

### Monitoring
- [ ] Error logging configured
- [ ] Integration status monitored
- [ ] API quota alerts set up
- [ ] Activity logs reviewed weekly
- [ ] Backup strategy in place

### Team
- [ ] Documentation shared with team
- [ ] Approval process defined
- [ ] Roles and permissions set
- [ ] Training completed
- [ ] Support process established

## Best Practices

### Start Small
1. Connect Notion first
2. Add one input source (Slack recommended)
3. Test with small team
4. Expand gradually

### Monitor Quality
- Review first 20-30 suggestions closely
- Adjust AI confidence thresholds if needed
- Train team on what makes good knowledge
- Iterate on process

### Maintain Security
- Review integration permissions quarterly
- Rotate API keys annually
- Audit access logs monthly
- Remove unused integrations
- Follow principle of least privilege

### Optimize Performance
- Start with narrow focus (one team/channel)
- Add folders/channels incrementally
- Monitor API usage
- Adjust polling intervals
- Use webhooks when possible

## Advanced Configurations

### Multi-Team Setup
Each team can have different integrations:
- Team A: Slack + Notion
- Team B: Google Drive + Notion
- Team C: All integrations

Configure in Settings → Teams

### Custom Knowledge Types
Define categories for your organization:
- Policies
- Processes
- Decisions
- Best Practices
- Guidelines

### Approval Workflows
Set up custom workflows:
- Auto-approve high confidence (>95%)
- Require 2 approvals for policies
- Admin-only for sensitive topics

### Notification Rules
Configure who gets notified:
- New suggestions → Slack channel
- Approvals → Email digest
- Errors → Ops team

## Integration Limits

### API Rate Limits
| Service | Limit | Strategy |
|---------|-------|----------|
| Notion | 3 req/sec | Queue + retry |
| Slack | 1 req/sec | Throttle |
| Google Drive | 10K req/100s | Batch + cache |
| Zoom | 80 req/sec | Well within |

### Content Limits
- **Message length**: 4096 chars (Slack)
- **Document size**: 10MB recommended
- **Transcript length**: Unlimited (chunked)
- **Batch size**: 20 suggestions max

### Storage Limits
- **Database**: Monitor growth monthly
- **Logs**: Rotate after 30 days
- **Backups**: Keep 90 days

## Troubleshooting Decision Tree

```
Issue?
  │
  ├─ Can't connect integration
  │   ├─ Check environment variables
  │   ├─ Verify API keys valid
  │   └─ Check network/firewall
  │
  ├─ Not processing content
  │   ├─ Verify source connected
  │   ├─ Check monitored channels/folders
  │   └─ Review content format
  │
  ├─ Low quality suggestions
  │   ├─ Increase confidence threshold
  │   ├─ Refine source selection
  │   └─ Train team on posting
  │
  └─ Can't update Notion
      ├─ Check page permissions
      ├─ Verify integration access
      └─ Check API rate limits
```

## Getting Help

### Self-Service
1. **Check logs**: Settings → System → Logs
2. **Review guides**: See integration-specific docs
3. **Test endpoints**: Use `/api/test-*` endpoints
4. **Check status**: Settings → Integrations

### Documentation
- **Setup Guides**: Individual integration `.md` files
- **API Docs**: `/docs` endpoint (if available)
- **Troubleshooting**: Each guide has section
- **Examples**: Sample configurations included

### Support Channels
- **Logs**: Check application logs first
- **Status Page**: Monitor service status
- **Community**: Share experiences
- **Updates**: Watch for new features

## Roadmap

### Coming Soon
- [ ] Microsoft Teams integration
- [ ] Confluence integration
- [ ] Linear integration (issues)
- [ ] GitHub integration (discussions)
- [ ] PDF document processing

### Requested Features
- [ ] Real-time sync (webhooks for all)
- [ ] Bulk import from existing docs
- [ ] Multi-language support
- [ ] Custom AI models
- [ ] Advanced analytics

## Success Metrics

Track these to measure success:

### Adoption
- % of team using system
- Suggestions reviewed/approved per week
- Average time to approval
- Active integrations per team

### Quality
- Approval rate (target: >70%)
- False positive rate (target: <15%)
- User satisfaction scores
- Knowledge base completeness

### Efficiency
- Time saved vs manual updates
- Knowledge captured that would be lost
- Reduction in "where is this documented?"
- Onboarding time improvement

## Conclusion

You're now ready to set up all Current integrations! Remember:

1. **Start with Notion** (required)
2. **Add one input source** at a time
3. **Test thoroughly** before expanding
4. **Monitor and adjust** regularly
5. **Train your team** on the process

Each integration has detailed setup instructions in its own guide. Good luck! 🚀

---

**Need Help?** Check the individual integration guides or application logs for detailed troubleshooting.

