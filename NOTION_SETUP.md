# Notion Integration Setup Guide

## Overview

The Notion integration is the **output destination** for Current. All approved knowledge updates are synced to your Notion workspace. This is a **required integration** for the application to function.

## What It Does

- ✅ Receives approved knowledge updates from Current
- ✅ Updates existing Notion pages automatically  
- ✅ Creates new pages when needed
- ✅ Maintains your knowledge base structure
- ✅ Preserves formatting and links

## Prerequisites

- **Notion Account**: Free or paid workspace
- **Admin Access**: Ability to install integrations
- **Workspace Setup**: At least one page/database to update

## Setup Methods

Current supports **two authentication methods** for Notion:

### Method 1: Replit Connectors (Recommended for Replit)

If deploying on Replit, use the built-in Connectors:

1. **Open Replit Tools Panel**
   - Click "Tools" at bottom of Replit workspace
   - Or press `Ctrl+Shift+K`

2. **Find Notion Connector**
   - Click "Integrations" or "Connectors"
   - Search for "Notion"
   - Click "Connect"

3. **Authorize Access**
   - Click "Select pages"
   - Choose the pages/databases Current can access
   - Click "Allow access"

4. **Verify Connection**
   - Go to Settings → Integrations in Current
   - Notion should show as "Connected"
   - You'll see your workspace name

### Method 2: OAuth Integration (For Local/Custom Deployments)

For local development or custom deployments:

#### Step 1: Create Notion Integration

1. **Go to Notion Integrations**
   - Visit https://www.notion.com/my-integrations
   - Click "+ New integration"

2. **Configure Integration**
   - **Name**: Current Knowledge Sync
   - **Logo**: (optional) Upload a logo
   - **Associated workspace**: Select your workspace
   - Click "Submit"

3. **Get Credentials**
   - Copy **Integration Token** (starts with `secret_`)
   - This is your `NOTION_TOKEN`
   
4. **Configure Capabilities**
   - ✅ Read content
   - ✅ Update content  
   - ✅ Insert content
   - ✅ Comment (optional)
   - Save changes

#### Step 2: For OAuth (Production)

If you want users to connect their own Notion workspaces:

1. **Enable Public Integration**
   - In integration settings, toggle "Public integration"
   - Fill in required information:
     - **Redirect URIs**: `https://yourdomain.com/api/oauth/notion/callback`
     - **Privacy Policy URL**: Your privacy policy
     - **Terms of Service URL**: Your terms of service

2. **Get OAuth Credentials**
   ```env
   NOTION_CLIENT_ID=your-oauth-client-id
   NOTION_CLIENT_SECRET=your-oauth-client-secret
   ```

3. **Add to Environment**
   - Update `.env` file
   - Restart application

#### Step 3: Share Pages with Integration

**Important**: Notion integrations can only access pages explicitly shared with them.

1. **Open a Notion Page**
   - Navigate to a page you want Current to update

2. **Share with Integration**
   - Click "Share" button (top right)
   - Click "Invite"
   - Find "Current Knowledge Sync" (your integration name)
   - Click "Invite"

3. **Repeat for All Pages**
   - Share every page/database Current should access
   - Child pages inherit access automatically

## Environment Variables

### For Replit (Method 1)
No manual configuration needed! Replit handles this automatically.

### For Local/OAuth (Method 2)

Add to your `.env` file:

```env
# For simple integration token
NOTION_TOKEN=secret_your_integration_token_here

# For OAuth (production)
NOTION_CLIENT_ID=your_oauth_client_id
NOTION_CLIENT_SECRET=your_oauth_client_secret
```

## Testing Your Integration

### Test 1: Connection Status

1. **Go to Settings → Integrations**
2. **Check Notion Status**:
   - ✅ Connected (green dot)
   - Shows workspace name
   - Shows last activity

3. **If Not Connected**:
   - Click "Refresh Status"
   - Check environment variables
   - Verify pages are shared with integration

### Test 2: Create a Test Suggestion

1. **Go to Process Text** (if available)
2. **Enter Test Content**:
   ```
   New company policy: All code reviews must be completed within 24 hours 
   to maintain development velocity.
   ```

3. **Process & Approve**:
   - Select a Notion page to update
   - Click "Process"
   - Should create a suggestion
   - Approve the suggestion

4. **Verify in Notion**:
   - Go to the selected Notion page
   - Check if content was added
   - Verify formatting is preserved

### Test 3: Page Matching

Current automatically matches suggestions to Notion pages by title:

1. **Create Test Pages** in Notion:
   - "Engineering Policies"
   - "Product Guidelines"  
   - "Company Handbook"

2. **Process Knowledge**:
   - Knowledge about "code reviews" → matches "Engineering Policies"
   - Knowledge about "product decisions" → matches "Product Guidelines"

3. **Verify Auto-Matching**:
   - Suggestions should automatically link to relevant pages
   - Check "Target Page" in approval queue

## How It Works

### 1. Knowledge Approval Flow

```
User Approves Suggestion
         ↓
Current validates permission
         ↓
Fetches current page content
         ↓
Merges new knowledge
         ↓
Updates Notion page
         ↓
Records in activity log
```

### 2. Page Matching Algorithm

Current uses several strategies to find the right Notion page:

1. **Exact Title Match**: "Engineering Policies" → "Engineering Policies"
2. **Fuzzy Match**: "Eng Policies" → "Engineering Policies"  
3. **Keyword Match**: Content about "code" → page with "code" in title
4. **User Selection**: Manual page picker in UI

### 3. Content Updates

When updating a page, Current:

1. ✅ Preserves existing content
2. ✅ Adds new knowledge as a new block
3. ✅ Maintains formatting (bold, italic, links)
4. ✅ Includes source attribution
5. ✅ Adds timestamp
6. ✅ Records change in activity log

Example update:

```
[Existing content remains unchanged]

──────────────────────────
Updated by Current - Dec 12, 2024

Code Review Policy
All code reviews must be completed within 24 hours.

Source: Slack #engineering
──────────────────────────
```

## Notion API Limits

Be aware of Notion's rate limits:

- **Rate Limit**: 3 requests per second per integration
- **Burst Limit**: Short bursts of 5 requests/second allowed
- **Daily Limit**: No official limit, but stay reasonable

Current handles this by:
- ✅ Queuing updates
- ✅ Automatic retry with exponential backoff
- ✅ Error logging and notification

## Permissions & Security

### What Current Can Access

- ✅ Only pages explicitly shared with the integration
- ✅ Only content, not workspace settings
- ✅ Only in workspaces where it's installed

### What Current Cannot Access

- ❌ Private pages not shared with integration
- ❌ Other users' private pages
- ❌ Workspace settings or billing
- ❌ User information beyond page access

### Best Practices

1. **Principle of Least Privilege**:
   - Only share necessary pages
   - Create a dedicated "Knowledge Base" section
   - Don't share sensitive pages

2. **Regular Audits**:
   - Review shared pages monthly
   - Remove access from unused pages
   - Check activity logs

3. **Test in Sandbox**:
   - Create a test workspace first
   - Test all features before production
   - Train team on the system

## Troubleshooting

### "Notion not connected"

**Problem**: Settings show "Not connected"

**Solutions**:
1. **For Replit**: 
   - Open Tools → Connectors
   - Reconnect Notion
   - Refresh Current settings page

2. **For Local**:
   - Check `NOTION_TOKEN` in `.env`
   - Verify token starts with `secret_`
   - Token must not have spaces or newlines
   - Restart application

### "Permission denied" when updating page

**Problem**: Error when trying to update a page

**Solutions**:
1. **Share page with integration**:
   - Open page in Notion
   - Click Share
   - Invite "Current Knowledge Sync"

2. **Check integration capabilities**:
   - Visit https://www.notion.com/my-integrations
   - Ensure "Update content" is enabled

3. **Verify page access**:
   - Integration can only access shared pages
   - Child pages inherit parent's access

### "Page not found"

**Problem**: Current can't find the Notion page

**Solutions**:
1. **Page not shared**: Share page with integration
2. **Page deleted**: Restore page or select different page
3. **Wrong workspace**: Verify integration is in correct workspace

### "Rate limit exceeded"

**Problem**: Too many requests to Notion

**Solutions**:
1. **Wait**: Rate limit resets after 1 second
2. **Reduce frequency**: Process fewer suggestions at once
3. **Check logs**: Look for retry messages

### Updates not appearing in Notion

**Problem**: Approved suggestions not showing in Notion

**Solutions**:
1. **Check activity log**: See if update succeeded
2. **Refresh Notion page**: Try Ctrl+R
3. **Check page permissions**: Verify integration has write access
4. **View error logs**: Look for API errors

## Advanced Configuration

### Custom Page Templates

Create templates for different knowledge types:

1. **In Notion**, create template pages:
   - "Policy Template"
   - "Process Template"
   - "Decision Template"

2. **Current will use these** when creating new pages

### Organizing Knowledge

Best practices for structure:

```
📁 Knowledge Base (Root)
├── 📄 Engineering
│   ├── Policies
│   ├── Processes
│   └── Best Practices
├── 📄 Product
│   ├── Guidelines
│   └── Decisions
└── 📄 Company
    ├── Handbook
    └── Policies
```

### Notion Databases

Current works with both pages and databases:

1. **Page Mode**: Updates individual pages
2. **Database Mode**: Creates new database entries
3. **Mixed Mode**: Some pages, some databases

Configure in Settings → Knowledge → Target Type

## Production Checklist

Before going live:

- [ ] Notion integration connected
- [ ] Test pages shared with integration
- [ ] Tested creating suggestions
- [ ] Tested approving suggestions  
- [ ] Verified updates appear in Notion
- [ ] Checked activity logs
- [ ] Trained team on approval process
- [ ] Set up backup/export of Notion data
- [ ] Documented page structure
- [ ] Created templates for knowledge types

## Integration Status Reference

| Status | Meaning | Action Required |
|--------|---------|-----------------|
| 🟢 Connected | Working normally | None |
| 🟡 Warning | Minor issues | Check logs |
| 🔴 Error | Not working | Reconnect integration |
| ⚪ Not Connected | Not set up | Follow setup guide |

## Need Help?

- **Notion API Docs**: https://developers.notion.com
- **Current Logs**: Check Settings → System → Logs
- **Test Endpoint**: POST `/api/test-notion` (if available)
- **Support**: Check application logs for detailed errors

## Next Steps

1. ✅ Complete Notion setup
2. ✅ Share key pages with integration
3. ✅ Test with sample suggestion
4. ✅ Set up other integrations (Slack, etc.)
5. ✅ Train team on approval workflow
6. 📊 Monitor activity logs daily
7. 📈 Review knowledge quality weekly

---

**Congratulations!** Your Notion integration is ready to keep your knowledge base up-to-date automatically! 🎉

