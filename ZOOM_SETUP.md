# Zoom Integration Setup Guide

## Overview

The Zoom integration allows Current to automatically extract knowledge from your team's meeting transcripts. When meetings are recorded with transcription enabled, Current analyzes the content and creates suggestions for your knowledge base.

## What It Does

- ✅ Monitors Zoom meetings with cloud recording
- ✅ Processes meeting transcripts automatically
- ✅ Extracts decisions, action items, and policies
- ✅ Creates suggestions for approval
- ✅ Links to original recordings
- ✅ Maintains speaker attribution

## Prerequisites

### Zoom Account Requirements
- **Account Type**: Pro, Business, or Enterprise
  - Basic/Free accounts don't support cloud recording
  - Check at: https://zoom.us/account/setting
- **Cloud Recording**: Must be enabled
- **Audio Transcript**: Must be enabled (disabled by default)
- **Admin Access**: To create and configure Zoom apps

### Application Requirements
- Current application running
- Anthropic API key configured (for transcript analysis)
- Notion integration set up (output destination)
- Public HTTPS URL (for webhook endpoint)

## Setup Time

- **Initial Setup**: 30-40 minutes
- **Testing**: 15-20 minutes (need to record a test meeting)
- **Total**: ~1 hour

## Step-by-Step Setup

### Step 1: Enable Cloud Recording & Transcription

1. **Go to Zoom Settings**
   - Visit https://zoom.us/profile/setting
   - Or: Sign in → Settings → Recording

2. **Enable Cloud Recording**
   - Toggle "Cloud recording" to ON
   - Make it available for all meetings (recommended)

3. **Enable Audio Transcript**
   - Scroll to "Advanced cloud recording settings"
   - Toggle "Audio transcript" to ON
   - This is **critical** - without it, no transcript is generated

4. **Optional Settings**:
   - "Record active speaker with shared screen": ON
   - "Record gallery view with shared screen": ON
   - "Record separate audio file for each participant": Optional

5. **Save Changes**

### Step 2: Create a Zoom Server-to-Server OAuth App

This is the recommended method for production use.

1. **Go to Zoom App Marketplace**
   - Visit https://marketplace.zoom.us/
   - Click "Develop" → "Build App"

2. **Choose App Type**
   - Select **"Server-to-Server OAuth"**
   - Click "Create"

3. **App Information**
   - **App Name**: `Current Knowledge Sync`
   - **Short Description**: `Automatically extracts knowledge from meeting transcripts`
   - **Company Name**: Your organization name
   - **Developer Contact**: Your email
   - Click "Continue"

4. **App Credentials**
   - You'll see:
     - **Account ID**
     - **Client ID**
     - **Client Secret**
   - **Copy all three** - you'll need them

5. **Add Scopes**
   - Click "Add Scopes"
   - Add the following:
     - `recording:read:admin` - Read recording files
     - `recording:read:meeting_recording:admin` - Access meeting recordings
     - `meeting:read:admin` - Read meeting details (optional but helpful)
     - `user:read:admin` - Read user information (for attribution)
   
6. **Activate App**
   - Toggle "Activation" to ON
   - App is now ready to use

### Step 3: Configure Environment Variables

Add to your `.env` file:

```env
# Zoom OAuth Credentials
ZOOM_CLIENT_ID=your_zoom_client_id_here
ZOOM_CLIENT_SECRET=your_zoom_client_secret_here
ZOOM_ACCOUNT_ID=your_zoom_account_id_here

# Webhook Secret (we'll set this up next)
ZOOM_WEBHOOK_SECRET=your_webhook_secret_here
```

### Step 4: Set Up Webhook for Transcript Notifications

1. **In Your Zoom App Settings**
   - Go to "Features" tab
   - Click "Event Subscriptions"

2. **Enable Event Subscriptions**
   - Toggle "Enable Event Subscriptions" to ON

3. **Add Event Subscription**
   - Click "+ Add Event Subscription"
   - **Subscription Name**: `Recording Transcripts`
   - **Event notification endpoint URL**:
     ```
     https://yourdomain.com/api/webhooks/zoom
     ```
     Replace `yourdomain.com` with your actual domain
   
4. **Verify Endpoint**
   - Zoom will send a verification request
   - Current automatically handles this
   - Wait for green checkmark ✓ "Verified"

5. **Subscribe to Events**
   - Click "Add Events"
   - Select these events:
     - ✅ `recording.transcript_completed` (Primary - when transcript is ready)
     - ✅ `recording.completed` (Fallback - when recording is ready)
   - Click "Done"

6. **Generate Webhook Secret Token**
   - Zoom shows a "Secret Token"
   - Copy this token
   - Add to `.env`:
     ```env
     ZOOM_WEBHOOK_SECRET=the_secret_token_from_zoom
     ```

7. **Save Changes**

### Step 5: Restart Application

After updating `.env`:

```bash
# Stop the application (Ctrl+C)
# Then restart
npm run dev
```

Check logs for:
```
✓ Zoom webhook endpoint ready at /api/webhooks/zoom
✓ Zoom integration configured
```

### Step 6: Test the Integration

#### Test 1: Connection Verification

1. **In Current Application**
   - Go to Settings → Integrations
   - Find "Zoom" section
   - Should show: ✅ Connected
   - Displays account information

2. **Check Server Logs**
   ```bash
   # Should see:
   [Zoom] Integration configured
   [Zoom] Webhook endpoint ready
   ```

#### Test 2: Record a Test Meeting

1. **Start a Zoom Meeting**
   - Schedule or start an instant meeting
   - **Enable Cloud Recording** (click "Record" → "Record to Cloud")
   - Enable transcript if prompted

2. **Have a Meaningful Conversation**
   - Discuss a policy, decision, or process
   - Example script:
     ```
     "Let's discuss our new code review policy. Going forward, 
     all pull requests must be reviewed by at least two engineers 
     before merging to main. This will improve code quality and 
     reduce bugs. The policy is effective starting next Monday."
     ```
   - Speak clearly for 2-3 minutes

3. **End the Meeting**
   - Click "End Meeting for All"
   - Recording will process

4. **Wait for Processing**
   - Zoom takes ~2x meeting duration to process
   - For a 5-minute meeting, wait ~10 minutes
   - For a 30-minute meeting, wait ~60 minutes
   - You'll receive email when ready

5. **Check for Webhook**
   - Watch server logs:
     ```bash
     [Zoom] Webhook received: recording.transcript_completed
     [Zoom] Meeting ID: 123456789
     [Zoom] Downloading transcript...
     [Zoom] Transcript downloaded (1,250 words)
     [AI] Analyzing transcript...
     [AI] Knowledge detected with 85% confidence
     [Suggestion] Created from Zoom transcript
     ```

6. **Verify in Current**
   - Go to Approval Queue
   - Should see new suggestion
   - Source: Zoom
   - Link to recording
   - Extracted content shows decisions/policies

7. **Approve and Test Notion Update**
   - Review the suggestion
   - Select target Notion page
   - Approve
   - Verify content appears in Notion

## How It Works

### Complete Flow

```
Meeting with Recording
         ↓
Recording processes (2x duration)
         ↓
Transcript generated
         ↓
Zoom sends webhook → Current
         ↓
Current downloads transcript
         ↓
AI analyzes transcript
         ↓
Knowledge extracted
         ↓
Suggestion created
         ↓
User approves
         ↓
Notion updated
```

### What Gets Extracted

**✅ Extracted:**
- Policies and decisions
- Action items and commitments
- Process descriptions
- Best practices discussed
- Important agreements
- Strategic directions

**❌ Ignored:**
- Casual conversation
- Social chat
- Scheduling discussions
- Technical difficulties talk
- Off-topic discussions

### AI Analysis Process

1. **Download**: Gets transcript from Zoom
2. **Parse**: Breaks into speaker segments
3. **Analyze**: Claude AI identifies knowledge
4. **Validate**: Checks confidence score (>70%)
5. **Format**: Creates structured suggestion
6. **Link**: Maintains link to original recording

## Configuration Options

### Automatic Recording

Enable auto-recording for all meetings:

1. **Zoom Settings** → Recording
2. **Automatic recording**: ON
3. **Record meetings automatically as they start**: ON
4. **Recording layout**: Select preferred layout

### Selective Processing

Process only specific meetings:

1. **In Meeting Settings**:
   - Enable recording only for important meetings
   - Add keyword triggers in meeting title
   - Example: Meetings with "Policy" or "Decision" in title

2. **In Current** (if available):
   - Settings → Integrations → Zoom
   - Configure filters:
     - Min meeting duration: 10 minutes
     - Required participants: Specific users
     - Topic keywords: "policy", "decision", "planning"

### Speaker Attribution

Current preserves who said what:

```
Speaker: John Smith (Engineering Manager)
"We're implementing a new deployment process..."

Speaker: Sarah Johnson (Tech Lead)
"I agree, and we should add automated testing..."
```

This helps with:
- Understanding context
- Accountability
- Follow-up questions

## Zoom API Limits

### Rate Limits

- **API Requests**: 80 requests/second per app
- **Daily Limit**: No official limit (stays within reasonable use)
- **Concurrent Downloads**: 5 simultaneous transcript downloads

Current handles limits by:
- ✅ Queuing webhook processing
- ✅ Throttling transcript downloads
- ✅ Automatic retry with backoff
- ✅ Error logging and alerts

### Storage Limits

- **Cloud Recording Storage**: Based on your Zoom plan
  - Pro: 1GB per license
  - Business: 1GB per license
  - Enterprise: Unlimited
- **Retention**: Configurable (default: forever)

## Token Management

### Automatic Token Refresh

Server-to-Server OAuth tokens expire after **1 hour**.

Current automatically:
1. ✅ Detects token expiration
2. ✅ Requests new token
3. ✅ Updates internal cache
4. ✅ Retries failed requests

### Manual Token Refresh (if needed)

```bash
# Get new access token
curl -X POST "https://zoom.us/oauth/token?grant_type=account_credentials&account_id=YOUR_ACCOUNT_ID" \
  -H "Authorization: Basic BASE64(CLIENT_ID:CLIENT_SECRET)"

# Update in .env
ZOOM_ACCESS_TOKEN=new_token_here

# Restart application
```

## Troubleshooting

### "Webhook verification failed"

**Problem**: Zoom shows "Unable to verify endpoint"

**Solutions**:

1. **Check URL is public**:
   ```bash
   curl https://yourdomain.com/api/webhooks/zoom
   # Should return: {"status":"ok"}
   ```

2. **Check application is running**:
   ```bash
   ps aux | grep node
   ```

3. **Check firewall**:
   - Ensure port 443 (HTTPS) is open
   - Zoom IPs are allowed

4. **Check logs**:
   ```bash
   grep "Zoom webhook" logs/application.log
   ```

5. **Restart application** and try again

### "No transcripts being processed"

**Problem**: Meetings recorded but no suggestions appear

**Debug Steps**:

1. **Verify recording settings**:
   - Cloud recording enabled?
   - Audio transcript enabled?
   - Check: https://zoom.us/recording

2. **Check webhook subscription**:
   - Go to Zoom App → Event Subscriptions
   - Verify subscribed to `recording.transcript_completed`
   - Status should be "Enabled"

3. **Check logs for webhooks**:
   ```bash
   grep "recording.transcript_completed" logs/application.log
   ```

4. **Manually check recording**:
   - Go to https://zoom.us/recording
   - Find recent meeting
   - Check if transcript file exists
   - If no transcript file, transcription might be disabled

5. **Test with short meeting**:
   - Record 2-minute meeting
   - Wait 5 minutes
   - Check logs

### "Transcript downloaded but no suggestion created"

**Problem**: Logs show transcript downloaded but no suggestion appears

**Possible Causes**:

1. **Low confidence score**:
   ```bash
   grep "confidence" logs/application.log
   # Look for: "confidence: 65%" (below 70% threshold)
   ```
   - Meeting content was too casual
   - No clear policies/decisions discussed

2. **Anthropic API key missing**:
   ```bash
   cat .env | grep ANTHROPIC
   # Should show: AI_INTEGRATIONS_ANTHROPIC_API_KEY=sk-ant-...
   ```

3. **Notion not connected**:
   - Check Settings → Integrations → Notion
   - Must be connected for suggestions to appear

4. **Processing error**:
   ```bash
   grep "ERROR" logs/application.log | grep -i zoom
   ```

### "Invalid signature" errors

**Problem**: Logs show "Invalid Zoom webhook signature"

**Solutions**:

1. **Check webhook secret**:
   ```bash
   cat .env | grep ZOOM_WEBHOOK_SECRET
   ```

2. **Regenerate secret** in Zoom:
   - Zoom App → Event Subscriptions
   - Click "Regenerate Secret Token"
   - Update `.env`
   - Restart application

3. **Check for spaces** in `.env`:
   ```bash
   # Bad (has space):
   ZOOM_WEBHOOK_SECRET= your_secret
   
   # Good:
   ZOOM_WEBHOOK_SECRET=your_secret
   ```

### "Token expired" errors

**Problem**: "Invalid access token" or "Token has expired"

**Solutions**:

1. **Check automatic refresh**:
   ```bash
   grep "Token refresh" logs/application.log
   ```

2. **Verify credentials** in `.env`:
   ```bash
   cat .env | grep ZOOM_CLIENT_ID
   cat .env | grep ZOOM_CLIENT_SECRET
   cat .env | grep ZOOM_ACCOUNT_ID
   ```

3. **Manually refresh** (see Token Management section above)

4. **Restart application** to force refresh

### "Rate limit exceeded"

**Problem**: "Too many requests" error

**Solutions**:

1. **Wait 60 seconds** - rate limit resets
2. **Check for loops** in code (shouldn't happen)
3. **Review recent activity**:
   ```bash
   grep "Zoom API" logs/application.log | tail -50
   ```

## Security Best Practices

### 1. Webhook Security

- ✅ Always verify webhook signatures
- ✅ Use HTTPS only (never HTTP)
- ✅ Validate webhook payload structure
- ✅ Rate limit webhook endpoint
- ✅ Log all webhook attempts

### 2. Token Security

- ✅ Store tokens encrypted at rest
- ✅ Never commit tokens to git
- ✅ Use environment variables
- ✅ Rotate tokens periodically
- ✅ Monitor for unauthorized access

### 3. Recording Access

- ✅ Request minimal scopes (recording:read only)
- ✅ Download transcripts only (not video)
- ✅ Delete local copies after processing
- ✅ Respect retention policies
- ✅ Log all access

### 4. Privacy Considerations

- ✅ Inform participants about recording
- ✅ Get consent for transcript analysis
- ✅ Redact sensitive information if needed
- ✅ Comply with data regulations (GDPR, etc.)
- ✅ Provide opt-out mechanism

## Advanced Configuration

### Custom Transcript Processing

Filter meetings by criteria:

```javascript
// In Settings → Zoom → Advanced (if available)
Process recordings:
- Min duration: 10 minutes
- Max duration: 180 minutes
- Required attendees: 3+
- Title keywords: "policy", "decision", "planning"
- Exclude keywords: "social", "casual", "chat"
```

### Multi-Language Support

Zoom transcripts support multiple languages:

1. **Meeting Settings** → Language
2. **Select language** for transcription
3. Current will process any language transcript
4. Anthropic AI supports 95+ languages

### Custom Confidence Threshold

Adjust AI sensitivity:

```javascript
// In server/services/zoom.ts (if modifying)
const MIN_CONFIDENCE = 80; // Stricter (default: 70)
```

Higher = fewer but higher quality suggestions
Lower = more suggestions but may include less relevant content

## Production Checklist

Before going live:

- [ ] Zoom Server-to-Server OAuth app created
- [ ] All required scopes granted
- [ ] Environment variables configured
- [ ] Webhook endpoint verified
- [ ] Application has public HTTPS URL
- [ ] Cloud recording enabled account-wide
- [ ] Audio transcript enabled
- [ ] Test meeting recorded and processed
- [ ] Suggestion created successfully
- [ ] Notion update working
- [ ] Webhook signature verification working
- [ ] Token refresh mechanism tested
- [ ] Error logging configured
- [ ] Team trained on recording meetings
- [ ] Privacy policy updated
- [ ] Participant consent obtained

## Performance Expectations

| Metric | Expected | Notes |
|--------|----------|-------|
| Meeting → Transcript | 2x duration | Zoom processing time |
| Transcript → Webhook | < 5 minutes | Usually immediate |
| Download → Analysis | < 60 seconds | Depends on transcript length |
| Analysis → Suggestion | < 30 seconds | AI processing time |
| **Total (10min meeting)** | **~25-30 minutes** | From meeting end to suggestion |
| **Total (60min meeting)** | **~2-3 hours** | Mostly Zoom processing |

## Integration with Other Services

### With Slack

Notify team when meeting processed:

1. Meeting recorded
2. Current creates suggestion
3. Slack notification: "New knowledge from meeting XYZ"
4. Team reviews and approves

### With Google Calendar

Sync meeting metadata:

1. Meeting scheduled in Google Calendar
2. Zoom meeting auto-created
3. After meeting, Current processes
4. Updates calendar event with notes

### With Notion

Structured knowledge capture:

1. Meeting transcript analyzed
2. Decisions → "Decisions" Notion page
3. Action items → "Action Items" database
4. Policies → "Policies" page

## Cost Considerations

### Zoom Costs

- **Pro Plan**: $149.90/year (required for cloud recording)
- **Storage**: 1GB/license (additional storage available)
- **API Access**: Free (included in all plans)

### Current Processing Costs

- **Anthropic AI**: ~$0.01-0.05 per meeting transcript
- **Storage**: Minimal (transcripts are text)
- **Bandwidth**: ~1MB per meeting download

## Frequently Asked Questions

### Q: Can I process existing recordings?

**A**: Yes, if you have webhook events. New recordings after setup are automatic. For historical recordings, you may need to manually trigger processing (contact support).

### Q: Does this work with Zoom Phone?

**A**: Currently, this integration is for Zoom Meetings only. Zoom Phone transcripts may be supported in future versions.

### Q: Can I exclude certain meetings?

**A**: Yes, simply don't enable cloud recording for those meetings. Or configure filters in Current settings.

### Q: What about breakout rooms?

**A**: Breakout room audio is included in the main transcript, but speaker attribution may be limited.

### Q: How accurate are the transcripts?

**A**: Zoom transcripts are 85-95% accurate with clear audio. Accuracy depends on:
- Audio quality
- Speaker clarity
- Background noise
- Accents

### Q: Can I edit transcripts before processing?

**A**: Currently, no. Transcripts are processed as-is from Zoom. Manual editing would require exporting, editing, and re-importing.

## Support Resources

- **Zoom API Docs**: https://marketplace.zoom.us/docs/api-reference/introduction
- **Server-to-Server OAuth**: https://marketplace.zoom.us/docs/guides/build/server-to-server-oauth-app
- **Webhook Events**: https://marketplace.zoom.us/docs/api-reference/webhook-reference
- **Current Logs**: Check Settings → System → Logs
- **Test Endpoint**: POST `/api/test-zoom` (if available)

## Next Steps

1. ✅ Complete Zoom setup following this guide
2. ✅ Record a test meeting with knowledge discussion
3. ✅ Verify transcript processes correctly
4. ✅ Test approval and Notion update
5. ✅ Train team on using cloud recording
6. ✅ Set recording best practices
7. 📊 Monitor usage and quality
8. 📈 Iterate based on results

---

**Congratulations!** Your Zoom integration is ready to automatically capture knowledge from your team's meetings! 🎥🎉

