# Google Meet Integration Setup Guide

## Overview

The Google Meet integration allows Current to automatically extract knowledge from your team's meeting recordings and transcripts. When Google Meet meetings are recorded, Current analyzes the transcripts and creates suggestions for your knowledge base.

## What It Does

- ✅ Monitors Google Meet recordings in Google Drive
- ✅ Processes meeting transcripts automatically
- ✅ Extracts decisions, action items, and policies
- ✅ Creates suggestions for approval
- ✅ Links to original recordings and transcripts
- ✅ Maintains meeting metadata

## Prerequisites

### Google Workspace Requirements
- **Account Type**: Google Workspace (Business, Enterprise, Education)
  - Personal Gmail accounts don't support Meet recording
  - Check at: https://admin.google.com
- **Recording Permission**: Must have permission to record meetings
- **Storage**: Sufficient Google Drive storage for recordings

### Application Requirements
- Current application running
- Anthropic API key configured (for transcript analysis)
- Notion integration set up (output destination)
- Google Drive integration configured (Meet uses Drive for storage)

## Setup Time

- **Initial Setup**: 30-40 minutes (includes Google Cloud setup)
- **Testing**: 15-20 minutes (need to record a test meeting)
- **Total**: ~1 hour

## Step-by-Step Setup

### Step 1: Enable Google Meet Recording

1. **Google Admin Console** (requires admin access)
   - Go to https://admin.google.com
   - Navigate to: Apps → Google Workspace → Google Meet

2. **Enable Recording**
   - Click "Recording"
   - Check "Let people record their meetings"
   - Select who can record:
     - ☑️ Meeting organizers
     - ☑️ Co-hosts (optional)
   - Click "Save"

3. **Verify Settings**
   - Recordings save to: Google Drive → "Meet Recordings" folder
   - Transcripts included: Yes (enable if not)

### Step 2: Set Up Google Cloud Project

Google Meet uses the same OAuth credentials as Google Drive.

1. **Go to Google Cloud Console**
   - Visit https://console.cloud.google.com
   - Select your project or create new one
   - Project name: "Current Knowledge Sync"

2. **Enable Required APIs**
   - Go to "APIs & Services" → "Library"
   - Search and enable:
     - ✅ **Google Drive API** (required - recordings stored here)
     - ✅ **Google Calendar API** (optional - for meeting metadata)
     - ✅ **Google Docs API** (optional - for transcript parsing)

3. **Configure OAuth Consent Screen**
   - Go to "APIs & Services" → "OAuth consent screen"
   - Choose:
     - **Internal** (if Google Workspace) - recommended
     - **External** (if not) - requires verification
   
   - Fill in:
     - **App name**: Current Knowledge Sync
     - **User support email**: Your email
     - **App logo**: (optional) Upload logo
     - **Application home page**: https://yourdomain.com
     - **Privacy Policy**: https://yourdomain.com/privacy
     - **Terms of Service**: https://yourdomain.com/terms

4. **Add Scopes**
   - Click "Add or Remove Scopes"
   - Add these scopes:
     ```
     https://www.googleapis.com/auth/drive.readonly
     https://www.googleapis.com/auth/drive.metadata.readonly
     https://www.googleapis.com/auth/calendar.readonly (optional)
     ```
   - Click "Update" → "Save and Continue"

5. **Add Test Users** (if External)
   - Add email addresses of users who will connect
   - They can test before app verification

6. **Save Configuration**

### Step 3: Create OAuth 2.0 Credentials

1. **Create Credentials**
   - Go to "APIs & Services" → "Credentials"
   - Click "+ CREATE CREDENTIALS"
   - Select "OAuth 2.0 Client ID"

2. **Configure Client**
   - **Application type**: Web application
   - **Name**: Current - Google Meet/Drive
   - **Authorized JavaScript origins**:
     ```
     http://localhost:5000
     https://yourdomain.com
     ```
   - **Authorized redirect URIs**:
     ```
     http://localhost:5000/api/oauth/google/callback
     https://yourdomain.com/api/oauth/google/callback
     ```

3. **Save and Download**
   - Click "Create"
   - Copy **Client ID**
   - Copy **Client Secret**
   - (Optionally) Download JSON file

### Step 4: Configure Environment Variables

Add to your `.env` file:

```env
# Google OAuth Credentials (shared with Drive)
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-client-secret-here

# These tokens are managed automatically per team
# GOOGLE_MEET_TOKEN=auto-managed-in-database
# GOOGLE_DRIVE_TOKEN=auto-managed-in-database
```

### Step 5: Connect Google Account in Current

1. **Restart Application** (if .env was just updated)
   ```bash
   # Ctrl+C to stop, then:
   npm run dev
   ```

2. **In Current Application**
   - Go to Settings → Integrations
   - Find "Google Meet" section
   - Click "Connect Google Account"

3. **Authorize Access**
   - Sign in with your Google Workspace account
   - Review permissions:
     - View and download Drive files
     - View Drive metadata
     - View calendar events (if enabled)
   - Click "Allow"

4. **Verify Connection**
   - Should redirect back to Current
   - Status shows: ✅ Connected
   - Displays connected email

### Step 6: Configure Meet Recordings Folder

1. **In Current**: Settings → Integrations → Google Meet

2. **Select Folder to Monitor**
   - Default: "Meet Recordings" (automatic)
   - Or: Browse and select custom folder

3. **Sync Interval**
   - Default: 15 minutes
   - Adjust if needed (5-60 minutes)

4. **File Type Filters**
   - ☑️ Transcript files (.vtt, .srt)
   - ☑️ Document transcripts (.gdoc)
   - ☐ Video files (optional - not analyzed)

5. **Save Configuration**

### Step 7: Test the Integration

#### Test 1: Connection Verification

1. **Check Status**
   - Settings → Integrations → Google Meet
   - Should show: ✅ Connected
   - Last sync time displayed

2. **Check Logs**
   ```bash
   [GoogleMeet] Integration configured
   [GoogleMeet] Monitoring folder: Meet Recordings
   [GoogleMeet] Sync interval: 15 minutes
   ```

#### Test 2: Record a Test Meeting

1. **Start a Google Meet**
   - Go to https://meet.google.com
   - Click "New meeting" → "Start an instant meeting"
   - Or: Schedule meeting in Google Calendar

2. **Enable Recording**
   - In meeting, click ⋮ (three dots)
   - Click "Record meeting"
   - Confirm recording start
   - Recording indicator appears

3. **Have Meaningful Discussion**
   - Discuss a policy, decision, or process
   - Example script:
     ```
     "Let's establish our new meeting policy. Going forward, 
     all team meetings must have an agenda shared 24 hours in 
     advance. This will make meetings more productive and 
     respectful of everyone's time. Action items must be 
     documented in the meeting notes within 2 hours of the 
     meeting ending."
     ```
   - Speak clearly for 2-3 minutes

4. **Stop Recording and End Meeting**
   - Click ⋮ → "Stop recording"
   - Confirm stop
   - End meeting for all

5. **Wait for Processing**
   - Recording saves to Google Drive automatically
   - Usually appears within 5-10 minutes
   - Transcript generation: additional 5-10 minutes
   - Total wait: 10-20 minutes

6. **Check Google Drive**
   - Go to Google Drive → "Meet Recordings"
   - Should see new folder with:
     - Video file (.mp4)
     - Transcript file (.srt or .vtt)
     - Document transcript (.gdoc) - sometimes

7. **Wait for Current to Process**
   - Next sync cycle (up to 15 minutes)
   - Or trigger manual sync (if available)
   - Watch logs:
     ```bash
     [GoogleMeet] Syncing folder: Meet Recordings
     [GoogleMeet] Found 1 new transcript
     [GoogleMeet] Downloading: Meeting_transcript.vtt
     [GoogleMeet] Parsing transcript (850 words)
     [AI] Analyzing content...
     [AI] Knowledge detected with 88% confidence
     [Suggestion] Created from Google Meet transcript
     ```

8. **Verify in Current**
   - Go to Approval Queue
   - Should see new suggestion
   - Source: Google Meet
   - Meeting title displayed
   - Link to recording in Drive

9. **Approve and Test Notion Update**
   - Review the suggestion
   - Select target Notion page
   - Approve
   - Verify content appears in Notion

## How It Works

### Complete Flow

```
Google Meet Recording
         ↓
Recording saves to Drive (5-10 min)
         ↓
Transcript generated (5-10 min)
         ↓
Current syncs Drive folder (15 min cycle)
         ↓
Detects new transcript
         ↓
Downloads transcript content
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
- Strategic discussions
- Important agreements
- Team decisions

**❌ Ignored:**
- Casual small talk
- Technical difficulties
- Meeting logistics ("Can you hear me?")
- Scheduling discussions
- Off-topic conversations

### Transcript Formats

Google Meet provides transcripts in multiple formats:

1. **VTT Format** (.vtt) - WebVTT with timestamps
   ```
   00:00:15.000 --> 00:00:18.000
   John: Let's discuss the new policy.
   ```

2. **SRT Format** (.srt) - SubRip with timestamps
   ```
   1
   00:00:15,000 --> 00:00:18,000
   John: Let's discuss the new policy.
   ```

3. **Google Doc** (.gdoc) - Formatted document
   ```
   Meeting Transcript
   John Smith: Let's discuss the new policy.
   Sarah Johnson: I agree, we should implement it.
   ```

Current can parse all three formats automatically.

## Configuration Options

### Automatic Recording

Enable auto-recording for scheduled meetings:

1. **Google Calendar Settings**
   - Open Calendar event
   - Add Google Meet
   - In Meet settings: Enable "Record meeting automatically"

2. **Admin-Level** (Google Workspace Admin):
   - Admin Console → Google Meet → Recording
   - Set default recording policy
   - Apply to organizational units

### Selective Processing

Process only specific meetings:

1. **Folder Organization**:
   - Create subfolders in "Meet Recordings"
   - Example: "Meet Recordings/Team Meetings"
   - Only monitor specific subfolder in Current

2. **Title Filters** (in Current settings):
   - Only process meetings with keywords
   - Example: "Policy", "Decision", "All Hands"
   - Exclude: "Social", "Casual", "1:1"

3. **Duration Filters**:
   - Min duration: 10 minutes (skip short calls)
   - Max duration: 180 minutes (skip all-day events)

### Speaker Attribution

Google Meet transcripts include speaker names:

```
John Smith (10:15 AM): "We need to update our deployment process..."
Sarah Johnson (10:16 AM): "I agree, let's document the new steps..."
```

Current preserves this attribution in suggestions.

## Google Drive Integration

Google Meet relies on Google Drive integration since recordings are stored there.

### Shared Configuration

- Same OAuth credentials as Google Drive
- Same permission scopes
- Integrated status monitoring
- Unified token management

### Benefits

- Single authentication for both
- Consistent sync schedule
- Shared folder monitoring
- Combined activity logs

## API Limits & Quotas

### Google Drive API

- **Queries per day**: 1 billion (plenty)
- **Queries per 100 seconds**: 1,000 per user
- **File downloads**: 10,000 per day

Current stays within limits by:
- ✅ Polling every 15 minutes (not constantly)
- ✅ Only downloading new/changed files
- ✅ Caching metadata
- ✅ Batch processing

### Google Calendar API (if used)

- **Queries per day**: 1,000,000
- **Queries per 100 seconds**: 100 per user

## Token Management

### Automatic Refresh

Google OAuth tokens:
- **Access Token**: Expires after 1 hour
- **Refresh Token**: Long-lived (no expiration)

Current automatically:
1. ✅ Detects token expiration
2. ✅ Uses refresh token to get new access token
3. ✅ Updates database
4. ✅ Retries failed requests

### Manual Reconnection (if needed)

If automatic refresh fails:

1. Settings → Integrations → Google Meet
2. Click "Disconnect"
3. Click "Connect" again
4. Re-authorize access

## Troubleshooting

### "Google Meet not connected"

**Problem**: Status shows "Not connected"

**Solutions**:

1. **Check environment variables**:
   ```bash
   cat .env | grep GOOGLE_CLIENT_ID
   cat .env | grep GOOGLE_CLIENT_SECRET
   ```
   Should show your credentials

2. **Restart application**:
   ```bash
   # Ctrl+C then
   npm run dev
   ```

3. **Reconnect account**:
   - Settings → Integrations → Google Meet
   - Click "Connect"
   - Authorize again

### "No transcripts being processed"

**Problem**: Meetings recorded but no suggestions appear

**Debug Steps**:

1. **Check recording saved to Drive**:
   - Open Google Drive
   - Go to "Meet Recordings" folder
   - Verify recording and transcript exist

2. **Check transcript file exists**:
   - Look for .vtt, .srt, or .gdoc files
   - If only video exists, transcription might be disabled

3. **Verify folder monitoring**:
   - Settings → Integrations → Google Meet
   - Check "Monitored Folder" is correct
   - Default: "Meet Recordings"

4. **Check sync status**:
   - View "Last Sync" time
   - Should update every 15 minutes
   - If stale, check logs for errors

5. **Manually trigger sync** (if available):
   - Settings → Integrations → Google Meet
   - Click "Sync Now"
   - Watch logs for activity

6. **Check logs**:
   ```bash
   grep "GoogleMeet" logs/application.log | tail -20
   ```

### "Permission denied" accessing recordings

**Problem**: "403 Forbidden" or "Access denied"

**Solutions**:

1. **Check OAuth scopes**:
   - Must include `drive.readonly`
   - Reconnect if missing

2. **Check file permissions**:
   - Recordings must be accessible by connected account
   - If using service account, share folder with it

3. **Check workspace policy**:
   - Admin might restrict external access
   - Contact Google Workspace admin

### "Transcript file not found"

**Problem**: Recording exists but transcript missing

**Solutions**:

1. **Enable transcription**:
   - Google Admin Console → Meet → Recording
   - Enable "Save transcripts"

2. **Wait longer**:
   - Transcripts can take 10-30 minutes after meeting
   - Be patient

3. **Check meeting language**:
   - Transcripts only for supported languages
   - English, Spanish, French, German, Portuguese, etc.

4. **Recording too short**:
   - Very short meetings (<2 min) might not get transcripts

### "Token expired" errors

**Problem**: "Invalid credentials" or "Token expired"

**Solutions**:

1. **Check automatic refresh**:
   ```bash
   grep "Token refresh" logs/application.log
   ```

2. **Reconnect account**:
   - Settings → Integrations → Google Meet
   - Disconnect and Connect again

3. **Verify refresh token**:
   - Check database for refresh_token
   - If missing, full re-authorization needed

### "Sync taking too long"

**Problem**: Transcripts not appearing in queue quickly

**Explanation**: Expected behavior due to multiple delays:
- Recording save: 5-10 minutes
- Transcript generation: 5-10 minutes
- Sync cycle: up to 15 minutes
- **Total**: 20-35 minutes

**Improvements**:

1. **Reduce sync interval** (in code):
   ```javascript
   // From 15 minutes to 5 minutes
   syncInterval: 5 * 60 * 1000
   ```

2. **Use webhooks** (advanced):
   - Set up Google Drive push notifications
   - Instant notification on new files
   - Requires verified domain

## Security Best Practices

### 1. OAuth Security

- ✅ Use HTTPS only
- ✅ Store tokens encrypted
- ✅ Never commit credentials to git
- ✅ Use environment variables
- ✅ Rotate secrets periodically

### 2. Recording Access

- ✅ Request minimal scopes (readonly)
- ✅ Download transcripts only (not video)
- ✅ Delete local copies after processing
- ✅ Log all access
- ✅ Monitor for unusual activity

### 3. Privacy Considerations

- ✅ Inform meeting participants about recording
- ✅ Get consent before enabling
- ✅ Comply with recording laws
- ✅ Follow data regulations (GDPR, CCPA)
- ✅ Provide data access/deletion options
- ✅ Secure storage of recordings

### 4. Google Workspace Policies

- ✅ Follow organization's recording policy
- ✅ Respect data retention requirements
- ✅ Honor DLP (Data Loss Prevention) settings
- ✅ Maintain audit logs

## Advanced Configuration

### Multi-Language Support

Google Meet transcripts support 70+ languages:

1. **Meeting Language Detection**: Automatic
2. **Transcript Language**: Matches spoken language
3. **Current Processing**: AI supports 95+ languages
4. **Notion Output**: Preserves original language

### Custom Processing Rules

Filter by meeting attributes:

```javascript
// In Settings → Google Meet → Advanced (if available)
Process recordings:
- Meeting duration: 10-180 minutes
- Attendee count: 3+ participants
- Organizer: Specific users
- Title contains: "policy", "decision", "all-hands"
- Exclude title: "social", "casual", "1:1"
```

### Transcript Quality Enhancement

Improve accuracy:

1. **Use good audio equipment**: Clear microphone
2. **Minimize background noise**: Quiet environment
3. **Speak clearly**: Enunciate words
4. **Avoid crosstalk**: One person speaks at a time
5. **Use proper names**: Full names for attribution

### Integration with Google Calendar

Link meeting metadata:

1. Current detects transcript in Drive
2. Extracts meeting ID from filename
3. Looks up Calendar event
4. Adds metadata to suggestion:
   - Meeting title
   - Attendees
   - Scheduled time
   - Calendar description

## Production Checklist

Before going live:

- [ ] Google Cloud project created
- [ ] Google Drive API enabled
- [ ] OAuth consent screen configured
- [ ] OAuth 2.0 credentials created
- [ ] Environment variables set in .env
- [ ] Google account connected in Current
- [ ] Meet Recordings folder monitored
- [ ] Recording permission enabled in Workspace
- [ ] Transcription enabled
- [ ] Test meeting recorded and processed
- [ ] Transcript detected and downloaded
- [ ] Suggestion created successfully
- [ ] Notion update working
- [ ] Token refresh tested
- [ ] Error logging configured
- [ ] Team trained on recording meetings
- [ ] Privacy policy updated
- [ ] Participant consent process established

## Performance Expectations

| Metric | Expected | Notes |
|--------|----------|-------|
| Recording → Drive | 5-10 min | Google processing |
| Transcript → Drive | 5-10 min | Additional Google processing |
| Drive → Current Sync | 15 min | Sync interval |
| Download → Analysis | < 30 sec | Current processing |
| **Total (10min meeting)** | **25-35 min** | From meeting end to suggestion |
| **Total (60min meeting)** | **25-35 min** | Same delay regardless of length |

## Integration with Other Services

### With Slack

Notify team:
1. Meeting recorded
2. Transcript processed
3. Slack notification: "Knowledge from [Meeting Title]"
4. Team reviews and approves

### With Notion

Structured capture:
1. Meeting decisions → "Decisions" database
2. Action items → "Action Items" page
3. Policies → "Policies" page
4. All linked to original recording

### With Zoom

Compare meeting platforms:

| Feature | Google Meet | Zoom |
|---------|-------------|------|
| Setup Complexity | Medium | Medium |
| Transcript Quality | Good | Excellent |
| Processing Time | 25-35 min | 2x meeting duration |
| Storage | Google Drive | Zoom Cloud |
| Speaker Attribution | Yes | Yes |
| Real-time Processing | No | No |

## Cost Considerations

### Google Workspace Costs

- **Basic**: $6/user/month (recording included)
- **Business**: $12/user/month (recording included)
- **Enterprise**: $18/user/month (recording included)
- **Storage**: 30GB-5TB depending on plan

### Current Processing Costs

- **Anthropic AI**: ~$0.01-0.03 per transcript
- **Google Drive API**: Free (within quotas)
- **Storage**: Minimal (transcripts are text files)

## Frequently Asked Questions

### Q: Can I process existing recordings?

**A**: Yes! Current will process any transcripts in the monitored folder. Move old recordings there and wait for next sync.

### Q: Does this work with personal Gmail?

**A**: No, recording requires Google Workspace. Personal Gmail doesn't support Meet recording.

### Q: Can I exclude certain meetings?

**A**: Yes, don't record them, or organize recordings in unmonitored subfolders.

### Q: What about breakout rooms?

**A**: Breakout rooms create separate recordings. Each is processed individually.

### Q: How accurate are Google transcripts?

**A**: 80-90% accurate with clear audio. Accuracy depends on:
- Audio quality
- Speaker accents
- Background noise
- Meeting language

### Q: Can I edit transcripts before processing?

**A**: Not automatically. You can download, edit, and re-upload as a new transcript file.

### Q: Do I need Google Drive integration?

**A**: Yes! Google Meet relies on Google Drive for storage. Set up Drive integration first.

## Support Resources

- **Google Meet Help**: https://support.google.com/meet
- **Google Drive API**: https://developers.google.com/drive/api
- **Google Calendar API**: https://developers.google.com/calendar
- **OAuth 2.0 Guide**: https://developers.google.com/identity/protocols/oauth2
- **Current Logs**: Check Settings → System → Logs
- **Test Endpoint**: POST `/api/test-google-meet` (if available)

## Next Steps

1. ✅ Complete Google Cloud setup
2. ✅ Connect Google account in Current
3. ✅ Enable recording in Google Workspace
4. ✅ Record a test meeting
5. ✅ Verify transcript processes
6. ✅ Test approval and Notion update
7. ✅ Train team on recording meetings
8. 📊 Monitor usage and quality
9. 📈 Iterate based on feedback

---

**Congratulations!** Your Google Meet integration is ready to automatically capture knowledge from your team's meetings! 🎥🎉

