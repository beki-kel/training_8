# Google Drive Integration Setup Guide

## Overview

The Google Drive integration allows Current to monitor your team's shared documents and automatically extract knowledge from:
- 📄 Google Docs
- 📊 Google Sheets (with text descriptions)
- 📝 Google Slides (speaker notes and text)
- 📁 Shared folders

## What It Does

- ✅ Monitors specified Drive folders for changes
- ✅ Detects when documents are updated
- ✅ Extracts knowledge from document content
- ✅ Creates suggestions for approval
- ✅ Links to original documents for context

## Prerequisites

- **Google Workspace Account** or personal Google account
- **Admin/Owner access** to Drive folders you want to monitor
- **Anthropic API Key** configured for AI analysis

## Setup Methods

###

 Method 1: Replit Connectors (Recommended for Replit)

1. **Open Replit Tools**
   - Click "Tools" at bottom of workspace
   - Or press `Ctrl+Shift+K`

2. **Connect Google Drive**
   - Click "Integrations" → "Connectors"
   - Find "Google Drive"
   - Click "Connect"

3. **Authorize Access**
   - Sign in with Google
   - Grant permissions:
     - View and download Drive files
     - See Drive file metadata
   - Click "Allow"

4. **Verify Connection**
   - Go to Settings → Integrations in Current
   - Google Drive should show "Connected"

### Method 2: OAuth 2.0 (For Local/Custom Deployments)

#### Step 1: Create Google Cloud Project

1. **Go to Google Cloud Console**
   - Visit https://console.cloud.google.com
   - Create a new project or select existing

2. **Enable APIs**
   - Go to "APIs & Services" → "Library"
   - Search for and enable:
     - **Google Drive API**
     - **Google Docs API** (optional, for better parsing)

3. **Configure OAuth Consent Screen**
   - Go to "APIs & Services" → "OAuth consent screen"
   - Choose "External" (unless Google Workspace)
   - Fill in required fields:
     - App name: "Current Knowledge Sync"
     - User support email: Your email
     - Developer contact: Your email
   - Add scopes:
     - `https://www.googleapis.com/auth/drive.readonly`
     - `https://www.googleapis.com/auth/drive.metadata.readonly`
   - Save

#### Step 2: Create OAuth Credentials

1. **Create Credentials**
   - Go to "APIs & Services" → "Credentials"
   - Click "+ CREATE CREDENTIALS"
   - Select "OAuth 2.0 Client ID"

2. **Configure OAuth Client**
   - Application type: "Web application"
   - Name: "Current - Google Drive"
   - Authorized redirect URIs:
     ```
     http://localhost:5000/api/oauth/google-drive/callback
     https://yourdomain.com/api/oauth/google-drive/callback
     ```

3. **Save Credentials**
   - Copy **Client ID**
   - Copy **Client Secret**

#### Step 3: Add to Environment

Add to `.env`:

```env
GOOGLE_CLIENT_ID=your-client-id-here.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-client-secret-here
```

Restart application.

#### Step 4: Connect Drive Account

1. **In Current App**:
   - Go to Settings → Integrations
   - Click "Connect Google Drive"
   - Sign in with Google
   - Grant permissions

2. **Select Folders** to monitor (in app settings)

## Environment Variables

### For Replit (Method 1)
```env
# Automatically managed by Replit Connectors
# No manual configuration needed
```

### For Local/OAuth (Method 2)
```env
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-client-secret-here

# Token is stored in database per team
# GOOGLE_DRIVE_TOKEN=automatically-managed
```

## Configuration

### Selecting Folders to Monitor

1. **Go to Settings → Integrations → Google Drive**

2. **Add Folders**:
   - Click "Add Folder"
   - Browse your Drive
   - Select folders to monitor
   - Click "Add"

3. **Recommended Folders**:
   - "Engineering Docs"
   - "Product Specs"
   - "Company Policies"
   - "Team Meeting Notes"

4. **Avoid**:
   - Personal folders
   - Large media folders
   - Archived documents

### File Type Filters

Configure which file types to process:

```javascript
// In Settings → Integrations → Google Drive
Enabled file types:
☑️ Google Docs (.gdoc)
☑️ Google Sheets (.gsheet)  
☑️ Google Slides (.gslides)
☐ PDFs (coming soon)
☐ Microsoft Office files (coming soon)
```

## How It Works

### Document Monitoring Flow

```
Drive Folder → Change Detection → Download Content → AI Analysis → Suggestion
```

1. **Polling**: Current checks Drive every 15 minutes
2. **Change Detection**: Looks for modified files
3. **Content Download**: Fetches document text
4. **AI Analysis**: Claude extracts knowledge
5. **Suggestion Creation**: Creates approval queue item
6. **User Approval**: You review and approve
7. **Notion Update**: Updates knowledge base

### What Gets Processed

**✅ Processed:**
- Documents with recent changes (last 24 hours)
- Shared documents in monitored folders
- Documents with substantive content
- Text-based content

**❌ Ignored:**
- Binary files (images, videos)
- Very old documents (>30 days since edit)
- Empty documents
- Duplicates (same content hash)
- Documents in Trash

### Content Extraction

#### Google Docs
- Extracts all text content
- Preserves headings and structure
- Includes tables (as text)
- Ignores images/drawings

#### Google Sheets
- Extracts text from cells
- Includes sheet names
- Focuses on description/notes
- Skips pure numerical data

#### Google Slides
- Extracts speaker notes
- Gets slide text content
- Combines into narrative
- Skips images

## Testing Your Integration

### Test 1: Connection Status

1. **Check Integration Status**:
   - Settings → Integrations → Google Drive
   - Should show "Connected" (green)
   - Shows connected email

2. **View Folder Access**:
   - Should list monitored folders
   - Shows last sync time

### Test 2: Process a Test Document

1. **Create Test Doc** in monitored folder:
   ```
   Title: Engineering Policy Update
   
   New policy: All database queries must use parameterized 
   statements to prevent SQL injection attacks. This applies 
   to all new code effective immediately.
   
   Rationale: Recent security audit identified risks.
   ```

2. **Wait for Processing**:
   - Next sync cycle (up to 15 minutes)
   - Or trigger manual sync (if available)

3. **Check Results**:
   - Go to Approval Queue
   - Should see new suggestion
   - Source: Google Drive
   - Link to original document

### Test 3: Verify Permissions

1. **Test Shared Document**:
   - Create doc in monitored folder
   - Share with team
   - Verify Current can access it

2. **Test Private Document**:
   - Create doc outside monitored folders
   - Should NOT be processed (privacy preserved)

## API Limits & Rate Limits

### Google Drive API Quotas

- **Queries per day**: 1 billion (plenty)
- **Queries per 100 seconds per user**: 1,000
- **Queries per 100 seconds**: 10,000

Current stays well within limits by:
- ✅ Polling every 15 minutes (not constantly)
- ✅ Only downloading changed files
- ✅ Caching file metadata
- ✅ Batch processing

If you hit limits:
- Increase polling interval
- Reduce monitored folders
- Use change notifications (webhook mode)

## Permissions & Security

### What Current Can Access

With `drive.readonly` scope:
- ✅ View and download your files
- ✅ View file metadata (names, dates)
- ✅ View sharing settings

### What Current Cannot Do

- ❌ Edit or delete files
- ❌ Create new files
- ❌ Share files with others
- ❌ Change permissions
- ❌ Access Google Drive settings

### Privacy Best Practices

1. **Monitor Shared Folders Only**:
   - Don't monitor personal folders
   - Use dedicated "Knowledge Docs" folder

2. **Review Processed Content**:
   - All suggestions require approval
   - You see content before it goes to Notion

3. **Token Security**:
   - Access tokens stored encrypted
   - Automatically refreshed
   - Can revoke anytime in Google Account

4. **Revoke Access** (if needed):
   - Go to https://myaccount.google.com/permissions
   - Find "Current Knowledge Sync"
   - Click "Remove access"

## Troubleshooting

### "Google Drive not connected"

**Solutions**:
1. Check environment variables:
   ```bash
   # Verify in .env
   GOOGLE_CLIENT_ID=...
   GOOGLE_CLIENT_SECRET=...
   ```

2. For Replit:
   - Tools → Connectors → Reconnect Google Drive

3. Restart application after changes

### "Permission denied" errors

**Problem**: Can't access certain files

**Solutions**:
1. **Check folder permissions**:
   - Open folder in Google Drive
   - Verify you have access
   - Make sure it's shared with integrated account

2. **Re-authorize**:
   - Settings → Integrations
   - Disconnect Google Drive
   - Reconnect and re-authorize

3. **Scope issues**:
   - Verify OAuth consent screen has correct scopes
   - Re-authorize to grant new scopes

### No documents being processed

**Problem**: Integration connected but no suggestions appearing

**Debugging steps**:
1. **Check monitored folders**:
   - Settings → Integrations → Google Drive
   - Verify folders are selected

2. **Check sync status**:
   - View last sync time
   - Should update every 15 minutes

3. **Check logs**:
   ```bash
   # Look for:
   [GoogleDrive] Syncing folder: Folder Name
   [GoogleDrive] Found 5 modified files
   [GoogleDrive] Processing: Document.gdoc
   ```

4. **Test with new document**:
   - Create obvious policy document
   - Wait 15 minutes
   - Check queue

### Token expired

**Problem**: "Invalid credentials" or "Token expired"

**Solutions**:
1. **Automatic refresh** (usually works):
   - Current refreshes tokens automatically
   - Check logs for "Token refreshed"

2. **Manual reconnect**:
   - Settings → Integrations
   - Disconnect Google Drive
   - Connect again

3. **Check refresh token**:
   - Ensure OAuth is set for "offline" access
   - This provides refresh tokens

## Advanced Configuration

### Webhook Mode (Real-time)

Instead of polling, use webhooks for instant updates:

1. **Enable Drive API Push Notifications**:
   - Requires verified domain
   - See: https://developers.google.com/drive/api/guides/push

2. **Configure in Current**:
   ```javascript
   // In Settings → Advanced
   Drive Sync Mode: Webhook
   Webhook URL: https://yourdomain.com/api/webhooks/google-drive
   ```

3. **Benefits**:
   - Instant notifications (no 15-min delay)
   - Reduced API quota usage
   - Better for large teams

### Custom File Filters

Filter documents by criteria:

```javascript
// In Settings → Google Drive → Advanced
Filters:
- Modified within: Last 7 days
- File size: < 10MB
- Exclude patterns: "draft", "WIP", "scratch"
- Include only shared: ✓
```

### Content Extraction Rules

Customize what gets extracted:

```javascript
// In Settings → Google Drive → Content
Extract from:
☑️ Document body
☑️ Comments (if knowledge-worthy)
☐ Suggested edits
☐ Revision history
```

## Production Checklist

Before going live:

- [ ] Google Drive connected
- [ ] OAuth configured correctly
- [ ] Monitored folders selected
- [ ] File type filters set
- [ ] Tested with sample document
- [ ] Verified suggestions appear
- [ ] Checked permissions are minimal
- [ ] Tested token refresh
- [ ] Set up monitoring/alerts
- [ ] Documented for team
- [ ] Trained users on workflow

## Performance Tips

### For Large Drive Libraries

1. **Be Selective with Folders**:
   - Monitor only active folders
   - Exclude archives
   - Limit to recent documents

2. **Adjust Polling Interval**:
   ```javascript
   // In Settings → Advanced (if available)
   Sync interval: 30 minutes (instead of 15)
   ```

3. **Use Date Filters**:
   - Only process documents modified in last 7 days
   - Ignore old/static documents

4. **Monitor API Usage**:
   - Check Google Cloud Console
   - Watch for quota warnings

## Integration with Other Services

### Combined with Slack

Great workflow:
1. Team discusses in Slack
2. Creates Google Doc with details
3. Current processes both:
   - Slack: Quick decisions
   - Drive: Detailed documentation

### With Notion

Documents flow:
1. Knowledge in Google Doc
2. Current extracts key points
3. Updates structured Notion pages

### Meeting Notes

Process meeting notes:
1. Take notes in Google Doc during meeting
2. Current extracts action items/decisions
3. Auto-updates team wiki

## Need Help?

- **Google Drive API**: https://developers.google.com/drive/api
- **OAuth 2.0 Guide**: https://developers.google.com/identity/protocols/oauth2
- **Current Logs**: Check Settings → System
- **Test Endpoint**: POST `/api/test-google-drive` (if available)

## Next Steps

1. ✅ Complete Google Drive setup
2. ✅ Select folders to monitor
3. ✅ Test with sample document
4. ✅ Configure file type filters
5. ✅ Set up Notion integration (output)
6. 📊 Monitor approval queue daily
7. 📈 Review processed documents weekly
8. 🔧 Adjust filters based on quality

---

**Congratulations!** Your Google Drive integration is ready to automatically extract knowledge from your documents! 📄

