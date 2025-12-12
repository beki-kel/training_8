# Integration Testing Guide

## Overview

This guide provides step-by-step testing procedures for all Current integrations to ensure they're working correctly.

## Pre-Testing Checklist

Before testing integrations:
- [ ] Application running (`npm run dev`)
- [ ] Database connected
- [ ] Environment variables configured
- [ ] User account created and logged in
- [ ] Team created

## Testing Order

Test in this order for best results:

1. **Core Services** (Required)
   - Database connectivity
   - Email service
   - AI service

2. **Notion** (Required - Output destination)

3. **Input Sources** (Choose what you configured)
   - Slack
   - Google Drive
   - Zoom
   - Google Meet

## Core Services Testing

### Test 1: Database Connectivity

```bash
# Check database
psql -h localhost -U current -d current_db -c "SELECT COUNT(*) FROM users;"

# Should show: count > 0
```

**Expected Result**: ✅ Connection successful, shows user count

### Test 2: Email Service (Resend)

**Method 1: Via UI**
1. Settings → Integrations → Email Service
2. Status should show: ✅ Connected

**Method 2: Send Test Invitation**
1. Settings → Team → Invite Member
2. Enter test email
3. Click Send
4. Check Resend dashboard: https://resend.com/emails

**Expected Result**: ✅ Email delivered, shows in Resend dashboard

### Test 3: AI Service (Anthropic)

**Method 1: Check Status**
```bash
# Verify API key is set
cat .env | grep AI_INTEGRATIONS_ANTHROPIC_API_KEY
```

**Method 2: Process Test Content** (if endpoint available)
```bash
curl -X POST http://localhost:5000/api/test-ai \
  -H "Content-Type: application/json" \
  -d '{"text": "New policy: All code must be reviewed."}'
```

**Expected Result**: ✅ API responds with knowledge extraction

## Notion Integration Testing

### Test 1: Connection Status

1. **Go to**: Settings → Integrations
2. **Check Notion status**:
   - Should show: ✅ Connected (green dot)
   - Shows workspace name
   - Last activity timestamp

**Expected Result**: ✅ Connected

**If Failed**:
- For Replit: Tools → Connectors → Reconnect Notion
- For Local: Check NOTION_CLIENT_ID/SECRET in .env
- Restart application

### Test 2: Page Access

1. **In Notion**, create a test page:
   - Title: "Test Knowledge Base"
   - Content: "This is a test page."

2. **Share with Integration**:
   - Click "Share" in Notion
   - Invite "Current" integration
   - Grant access

3. **In Current**, verify access:
   - Go to Approval Queue (should see Notion pages in picker)

**Expected Result**: ✅ Can see and select Notion pages

### Test 3: Content Update

1. **Create test suggestion** in Current:
   - Go to Approval Queue
   - Create manual suggestion (if available)
   - OR wait for real suggestion from input source

2. **Select Notion page**:
   - Choose "Test Knowledge Base" page
   - Approve suggestion

3. **Verify in Notion**:
   - Open "Test Knowledge Base" page
   - Should see new content added
   - Check timestamp and source attribution

**Expected Result**: ✅ Content appears in Notion page within 5 seconds

## Slack Integration Testing

### Test 1: Connection Status

1. **Check Integration**:
   - Settings → Integrations → Slack
   - Should show: ✅ Connected
   - Shows workspace name

2. **Check Server Logs**:
   ```bash
   # Look for:
   [SlackManager] Team xxx connected to Slack
   Connected to Slack via Socket Mode
   ```

**Expected Result**: ✅ Connected with Socket Mode active

**If Failed**:
- Check SLACK_APP_TOKEN and SLACK_BOT_TOKEN
- Verify tokens start with xapp- and xoxb-
- Restart application

### Test 2: Bot Invitation

1. **In Slack**, go to a test channel (e.g., #test)

2. **Invite the bot**:
   ```
   /invite @YourBotName
   ```

3. **Verify**:
   - Bot should join the channel
   - Shows in member list

**Expected Result**: ✅ Bot is now a member of the channel

### Test 3: Message Processing

1. **Post test message** in monitored channel:
   ```
   New engineering policy: All database migrations must be reviewed 
   by at least 2 senior engineers before deployment to prevent data 
   loss. This is effective immediately.
   ```

2. **Check Server Logs**:
   ```bash
   # Should see:
   [Slack] Message received from channel: C12345
   [AI] Analyzing content...
   [AI] Knowledge detected with 85% confidence
   Created suggestion from Slack message
   ```

3. **Check Approval Queue**:
   - Go to Approval Queue page
   - Should see new suggestion
   - Source: Slack
   - Link to original message

**Expected Result**: ✅ Suggestion created within 30 seconds

### Test 4: End-to-End Flow

1. Post knowledge in Slack
2. Wait for suggestion (check queue)
3. Review and approve suggestion
4. Verify update in Notion
5. Check activity log

**Expected Result**: ✅ Complete flow works, Notion updated

## Google Drive Integration Testing

### Test 1: Connection Status

1. **Settings → Integrations → Google Drive**
2. **Check status**:
   - ✅ Connected
   - Shows connected email
   - Shows last sync time

**Expected Result**: ✅ Connected

### Test 2: Folder Monitoring

1. **Create test folder** in Google Drive:
   - Name: "Current Test Docs"
   - Share with team

2. **In Current**:
   - Settings → Integrations → Google Drive
   - Add folder to monitor
   - Select "Current Test Docs"

3. **Verify configuration saved**

**Expected Result**: ✅ Folder added to monitoring list

### Test 3: Document Processing

1. **Create test document** in monitored folder:
   ```
   Title: Engineering Best Practices Update
   
   Content:
   New best practice: Always use TypeScript strict mode for all 
   new projects. This catches type errors at compile time and 
   improves code quality. All new repositories must enable this 
   in tsconfig.json starting Q1 2025.
   ```

2. **Wait for sync** (15 minutes or trigger manual sync)

3. **Check Logs**:
   ```bash
   [GoogleDrive] Syncing folder: Current Test Docs
   [GoogleDrive] Found 1 modified file
   [GoogleDrive] Processing: Engineering Best Practices Update
   [AI] Knowledge detected with 88% confidence
   Created suggestion from Google Drive document
   ```

4. **Check Approval Queue**:
   - New suggestion should appear
   - Source: Google Drive  
   - Link to original doc

**Expected Result**: ✅ Document processed, suggestion created

### Test 4: Content Extraction

Test different file types:

**Google Docs**:
- Create doc with headers, lists, tables
- Verify all text extracted

**Google Sheets**:
- Create sheet with policy info
- Verify text cells extracted

**Google Slides**:
- Create slides with speaker notes
- Verify notes extracted

**Expected Result**: ✅ All formats process correctly

## Zoom Integration Testing

### Test 1: Connection Status

1. **Settings → Integrations → Zoom**
2. **Verify**:
   - Shows connection status
   - Displays account info (if connected)

**Expected Result**: ✅ Status shows correctly

### Test 2: Webhook Setup

1. **In Zoom App Settings**:
   - Event Subscriptions → Enabled
   - Endpoint URL configured
   - Subscribed to: `recording.transcript_completed`

2. **Test Webhook** (if test button available in Zoom)

3. **Check Server Logs**:
   ```bash
   [Zoom] Webhook received
   [Zoom] Signature verified
   ```

**Expected Result**: ✅ Webhook verified

### Test 3: Meeting Recording & Transcript

1. **Start Zoom Meeting**:
   - Enable cloud recording
   - Enable transcript
   - Have meaningful conversation about a policy/decision

2. **End Meeting**

3. **Wait for Processing**:
   - Zoom processes: ~2x meeting duration
   - Webhook sent when complete
   - Current downloads transcript

4. **Check Logs**:
   ```bash
   [Zoom] Webhook: recording.transcript_completed
   [Zoom] Downloading transcript for meeting: xxx
   [AI] Analyzing transcript (length: 1250 words)
   [AI] Knowledge detected with 82% confidence
   Created suggestion from Zoom transcript
   ```

5. **Check Approval Queue**:
   - Suggestion appears
   - Source: Zoom
   - Link to recording

**Expected Result**: ✅ Transcript processed, suggestion created

## Google Meet Integration Testing

### Test 1: Connection Status

1. **Settings → Integrations → Google Meet**
2. **Verify status**

**Expected Result**: ✅ Connected (if configured)

### Test 2: Recording Access

1. **Start Google Meet**:
   - Enable recording
   - Have meeting with knowledge discussion

2. **End meeting**

3. **Recording saves to Drive**:
   - Transcript file created
   - Stored in "Meet Recordings" folder

4. **Current processes**:
   - Detects new transcript
   - Downloads content
   - AI analyzes

5. **Check Queue**:
   - New suggestion from Google Meet
   - Link to recording

**Expected Result**: ✅ Recording processed successfully

## End-to-End Integration Testing

### Scenario 1: Slack → Notion Flow

1. **Post in Slack**:
   ```
   New product guideline: All feature requests must include 
   user research data and usage metrics before prioritization.
   ```

2. **Wait for Processing** (~30 seconds)

3. **Check Approval Queue**:
   - Suggestion appears
   - Review content
   - Select Notion page: "Product Guidelines"

4. **Approve Suggestion**

5. **Verify Notion**:
   - Open "Product Guidelines" page
   - New content added
   - Source attribution included

6. **Check Activity Log**:
   - Shows approval action
   - Links to Notion page
   - Shows who approved

**Expected Result**: ✅ Complete flow works end-to-end

### Scenario 2: Google Drive → Notion Flow

1. **Create Doc** in monitored folder:
   - Add policy content
   - Save document

2. **Wait for Sync** (up to 15 minutes)

3. **Check Queue** → **Approve** → **Verify Notion**

**Expected Result**: ✅ Document content synced to Notion

### Scenario 3: Zoom → Notion Flow

1. **Record Meeting** with decisions
2. **Wait for Transcript** (Zoom processing)
3. **Check Queue** → **Approve** → **Verify Notion**

**Expected Result**: ✅ Meeting knowledge captured in Notion

## Performance Testing

### Test Response Times

Measure and verify:
- **Slack message → Suggestion**: < 30 seconds
- **Approve → Notion update**: < 5 seconds
- **Drive sync cycle**: ~15 minutes
- **Zoom webhook → Suggestion**: < 60 seconds

### Test Load Handling

1. **Multiple Messages**:
   - Post 5 messages in Slack quickly
   - All should process

2. **Large Content**:
   - Process 10-page Google Doc
   - Should handle without timeout

3. **Concurrent Approvals**:
   - Approve multiple suggestions at once
   - All should update Notion

**Expected Results**: ✅ System handles load gracefully

## Error Handling Testing

### Test 1: Invalid Notion Page

1. Delete a Notion page that has pending suggestion
2. Try to approve suggestion
3. Should show clear error

**Expected Result**: ✅ Error message, suggestion stays in queue

### Test 2: Rate Limit

1. Approve many suggestions rapidly
2. May hit Notion's 3 req/sec limit
3. System should queue and retry

**Expected Result**: ✅ Auto-retry, all updates succeed

### Test 3: Expired Tokens

1. Manually expire an OAuth token in database
2. Try to use integration
3. Should auto-refresh token

**Expected Result**: ✅ Token refreshes automatically

### Test 4: Network Issues

1. Disconnect network briefly
2. Try to approve suggestion
3. Should show connection error

**Expected Result**: ✅ Clear error message, retry available

## Security Testing

### Test 1: Webhook Signatures

**Slack**:
```bash
# Send request with invalid signature
curl -X POST http://localhost:5000/api/webhooks/slack \
  -H "X-Slack-Signature: invalid" \
  -H "X-Slack-Request-Timestamp: 1234567890" \
  -d '{"type":"test"}'
```

**Expected Result**: ✅ 401 Unauthorized

**Zoom**:
```bash
# Send request with invalid signature
curl -X POST http://localhost:5000/api/webhooks/zoom \
  -H "x-zm-signature: invalid" \
  -d '{"event":"test"}'
```

**Expected Result**: ✅ 401 Unauthorized

### Test 2: Permission Validation

1. **Remove integration access** in Notion
2. **Try to approve** suggestion
3. **Should show** permission error

**Expected Result**: ✅ Error caught and displayed

### Test 3: Email Validation

1. Try to invite with invalid email
2. Should reject

**Expected Result**: ✅ Validation works

## Monitoring & Logging

### Verify Logging Works

Check these log types appear:

**Integration Logs**:
```
[Slack] Message received
[GoogleDrive] Syncing folder
[Zoom] Webhook received
[Notion] Updating page
```

**AI Logs**:
```
[AI] Analyzing content
[AI] Knowledge detected with 85% confidence
[AI] Creating suggestion
```

**Error Logs**:
```
[Error] Integration failed: ...
[Error] Retrying in 5 seconds...
```

### Activity Log Verification

1. **Go to**: Activity Log page
2. **Verify shows**:
   - All approvals
   - All rejections
   - Source integrations
   - Timestamps
   - User actions

**Expected Result**: ✅ Complete audit trail

## Integration Status Dashboard

### Verify Status Page

1. **Go to**: Settings → Integrations
2. **Check each integration shows**:
   - Connection status (Connected/Not Connected)
   - Last activity timestamp
   - Error messages (if any)
   - Workspace/account name

### Status Indicators

| Indicator | Meaning |
|-----------|---------|
| 🟢 Connected | Working |
| 🟡 Warning | Minor issues |
| 🔴 Error | Not working |
| ⚪ Not Connected | Not set up |

## Common Test Failures & Solutions

### "Notion not updating"

**Debug Steps**:
1. Check integration status
2. Verify page is shared with integration
3. Check API rate limits
4. Review error logs
5. Test with different page

### "Slack not processing messages"

**Debug Steps**:
1. Verify bot is in channel
2. Check Socket Mode connection
3. Review message format
4. Check AI confidence scores
5. Look for filtered messages (bot messages, etc.)

### "Google Drive not syncing"

**Debug Steps**:
1. Verify folder permissions
2. Check last sync time
3. Manually trigger sync (if available)
4. Review OAuth token status
5. Check API quotas

### "No suggestions appearing"

**Debug Steps**:
1. Check all integration statuses
2. Verify AI API key
3. Review confidence thresholds
4. Check content format
5. Look at server logs for processing errors

## Performance Benchmarks

Expected performance metrics:

| Metric | Target | Acceptable |
|--------|--------|------------|
| Slack → Suggestion | < 30s | < 60s |
| Approve → Notion | < 5s | < 10s |
| Drive Sync | ~15min | < 30min |
| Zoom → Suggestion | < 60s | < 120s |
| API Response | < 200ms | < 500ms |

## Comprehensive Test Script

Run this complete test:

```bash
#!/bin/bash

echo "=== Current Integration Testing ==="

# 1. Database
echo "Testing database..."
psql -h localhost -U current -d current_db -c "SELECT 1;" > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "✅ Database connected"
else
  echo "❌ Database failed"
fi

# 2. Server Health
echo "Testing server health..."
curl -s http://localhost:5000/api/health | grep -q "healthy"
if [ $? -eq 0 ]; then
  echo "✅ Server healthy"
else
  echo "❌ Server unhealthy"
fi

# 3. Integration Status
echo "Fetching integration status..."
curl -s http://localhost:5000/api/integrations/status \
  -H "Cookie: connect.sid=YOUR_SESSION" | jq .

echo ""
echo "=== Manual Tests Required ==="
echo "1. Send test message in Slack"
echo "2. Create test doc in Google Drive"
echo "3. Approve a suggestion"
echo "4. Verify Notion update"
```

## Automated Test Suite (Future)

Recommended automated tests to implement:

```typescript
describe('Integrations', () => {
  describe('Notion', () => {
    it('should connect successfully', async () => {});
    it('should list pages', async () => {});
    it('should update page content', async () => {});
    it('should handle rate limits', async () => {});
  });

  describe('Slack', () => {
    it('should connect via Socket Mode', async () => {});
    it('should verify webhook signatures', async () => {});
    it('should process messages', async () => {});
    it('should filter bot messages', async () => {});
  });

  describe('Google Drive', () => {
    it('should connect with OAuth', async () => {});
    it('should list files in folder', async () => {});
    it('should download document content', async () => {});
    it('should detect changes', async () => {});
  });

  describe('End-to-End', () => {
    it('should complete Slack → Notion flow', async () => {});
    it('should complete Drive → Notion flow', async () => {});
    it('should handle errors gracefully', async () => {});
  });
});
```

## Production Readiness Checklist

Before deploying to production:

### Integrations
- [ ] All required integrations connected
- [ ] All webhooks configured and verified
- [ ] OAuth tokens refreshing automatically
- [ ] Rate limits understood and handled
- [ ] Error handling tested

### Security
- [ ] Webhook signatures verified
- [ ] API tokens encrypted
- [ ] Minimal permissions granted
- [ ] Access logs monitored
- [ ] Security audit completed

### Performance
- [ ] Response times acceptable
- [ ] Load testing completed
- [ ] Queue processing working
- [ ] Auto-retry functioning
- [ ] API quotas monitored

### Monitoring
- [ ] Error logging configured
- [ ] Integration status monitored
- [ ] Alerts set up for failures
- [ ] Activity logs reviewed
- [ ] Backup strategy in place

### Documentation
- [ ] All setup guides complete
- [ ] Team trained on workflow
- [ ] Approval process documented
- [ ] Troubleshooting guides ready
- [ ] Support process established

## Success Criteria

All integrations pass when:

- ✅ Core services (DB, Email, AI) working
- ✅ Notion connected and updating pages
- ✅ At least one input source connected
- ✅ Suggestions created automatically
- ✅ Approval flow works end-to-end
- ✅ Activity logged correctly
- ✅ Error handling works
- ✅ Performance meets targets
- ✅ Security measures in place
- ✅ Team can use system independently

## Next Steps After Testing

1. **Document Results**: Record what works and what doesn't
2. **Fix Issues**: Address any failed tests
3. **Train Team**: Show them how to use the system
4. **Monitor**: Watch first week closely
5. **Iterate**: Adjust based on feedback
6. **Scale**: Add more channels/folders gradually

---

**Good luck with testing!** 🧪 Follow this guide step-by-step to ensure all integrations work correctly.

