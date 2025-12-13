# Replit Deployment & Testing Guide

## Overview

This guide explains how to deploy and test the HeyCurrent application on Replit, using Replit's built-in connectors for integrations.

---

## 🚀 Deployment Steps

### 1. Push Code to Replit

```bash
# If using Replit Git integration:
git add .
git commit -m "Ready for Replit deployment"
git push origin main

# Or import directly in Replit from GitHub
```

### 2. Set Up Environment Variables in Replit

Go to **Secrets** (🔒 icon) and add:

#### Required Core Variables:
```env
# Database (Replit provides this automatically)
DATABASE_URL=<auto-filled-by-replit>

# Session
SESSION_SECRET=<generate-random-string>

# Anthropic AI (Required)
ANTHROPIC_API_KEY=<your-key>

# Email (Required for invitations)
RESEND_API_KEY=<your-key>
RESEND_FROM_EMAIL=notifications@yourdomain.com
```

#### Optional (if NOT using Replit connectors):
```env
NOTION_CLIENT_ID=<your-oauth-app-id>
NOTION_CLIENT_SECRET=<your-oauth-app-secret>
SLACK_CLIENT_ID=<your-slack-app-id>
SLACK_CLIENT_SECRET=<your-slack-app-secret>
# etc.
```

**Note:** You do NOT need `NOTION_TOKEN` or OAuth credentials if using Replit connectors!

---

## 🔌 Setting Up Replit Connectors

### Method 1: Using Replit UI (Recommended)

1. **Open your Repl**
2. **Click "Tools" in left sidebar** (🔧 icon)
3. **Click "Secrets"**
4. **Scroll down to "Connect to services"**
5. **Click "+ Connect"**
6. **Select "Notion"**
7. **Authorize** → Replit will handle OAuth automatically
8. **Done!** The connector is now available

Replit automatically sets:
- `REPLIT_CONNECTORS_HOSTNAME`
- `REPL_IDENTITY` (or `WEB_REPL_RENEWAL` for deployments)

### Method 2: Via Replit API (Programmatic)

The app automatically detects Replit connectors using environment variables:
- `REPLIT_CONNECTORS_HOSTNAME` - Replit sets this
- `REPL_IDENTITY` - For development Repls
- `WEB_REPL_RENEWAL` - For deployed apps

No manual configuration needed!

---

## 🧪 Testing on Replit

### Phase 1: Verify Deployment

1. **Start the Repl**
   - Replit auto-runs `npm run dev`
   - Check console for startup messages

2. **Open the Web View**
   - Click the URL at the top
   - Should see the login page

3. **Create Account**
   - Use email/password auth
   - Create your first team

### Phase 2: Test Notion Integration

#### Step 1: Connect Notion via Replit
1. Go to **Settings** → **Integrations**
2. Status should show: *"Notion connector available via Replit"*
3. If not connected, follow Replit connector setup above

#### Step 2: Share Notion Pages
1. Open Notion workspace
2. Create or open a page
3. Click **"Share"**
4. Invite your Replit integration
5. Ensure it has **Edit** permissions

#### Step 3: Test Connection
1. Back in HeyCurrent → **Settings** → **Integrations**
2. Should show: **"Notion: Connected ✓"**
3. Should display workspace name

#### Step 4: Generate Demo
1. Go to **Dashboard**
2. Click **"Continue Setup"**
3. Click **"Skip & Try Demo"**
4. If already completed, use console:
   ```javascript
   fetch('/api/integrations/slack/simulate', {
     method: 'POST',
     headers: { 'Content-Type': 'application/json' }
   }).then(r => r.json()).then(console.log)
   ```

#### Step 5: Approve & Verify
1. Go to **Approval Queue**
2. See the demo suggestion
3. Click **"Approve"**
4. Should complete in ~1 second
5. **Check Notion** → Refresh page
6. **Should see update at bottom!** ✅

---

## 🔍 Differences: Local vs Replit

| Feature | Local Development | Replit Deployment |
|---------|------------------|-------------------|
| **Notion Auth** | Internal token or OAuth | Replit connector (OAuth) |
| **Token Storage** | Database or `.env` | Replit manages it |
| **Token Refresh** | Manual | Automatic |
| **Setup Complexity** | Higher (manual OAuth) | Lower (one-click connect) |
| **Multi-user** | Need database tokens | Need OAuth setup |
| **Code Changes** | ✅ **None needed!** | ✅ **Works as-is!** |

---

## ✅ Verification Checklist

Use this to verify everything works on Replit:

### Core Functionality
- [ ] App starts without errors
- [ ] Can create account with email/password
- [ ] Dashboard loads correctly
- [ ] Can create team

### Notion Integration
- [ ] Notion connector shows as available
- [ ] Connection status shows "Connected"
- [ ] Can see workspace name
- [ ] Generate demo creates suggestion
- [ ] Approval updates Notion page
- [ ] Content appears in Notion with timestamp

### User Management
- [ ] Can invite team members
- [ ] Email invitations sent via Resend
- [ ] Accept invitation flow works
- [ ] Team member sees shared suggestions

### Error Handling
- [ ] Graceful error messages
- [ ] No crashes on failed API calls
- [ ] Console logs are helpful

---

## 🐛 Troubleshooting on Replit

### Issue: "Notion connector not available"

**Cause:** Replit connector not set up or environment variables missing

**Fix:**
1. Check Replit Secrets for `REPLIT_CONNECTORS_HOSTNAME`
2. Reconnect Notion via Replit UI
3. Restart the Repl

### Issue: "No matching Notion page found"

**Cause:** Pages not shared with integration

**Fix:**
1. Open Notion page
2. Click "Share" → Invite integration
3. Ensure "Edit" permission
4. Try approval again

### Issue: Updates timeout

**Cause:** Network issues or large page

**Solution:** Already fixed! The code uses append mode (fast)

### Issue: Wrong team's token used

**Cause:** Multi-team scenario without proper database tokens

**Solution:** 
- Each team needs to connect Notion separately
- Or use Replit connector (works for all teams)

---

## 🎯 Production Deployment on Replit

### 1. Use Replit Deployments

```bash
# In Repl, click "Deploy" button
# Select "Autoscale" or "Reserved VM"
# Follow deployment wizard
```

### 2. Environment Variables for Production

**Required:**
```env
NODE_ENV=production
SESSION_SECRET=<strong-random-secret>
DATABASE_URL=<production-postgres-url>
ANTHROPIC_API_KEY=<your-key>
RESEND_API_KEY=<your-key>
```

**Optional (for custom domain):**
```env
REPL_SLUG=heycurrent
REPL_OWNER=yourusername
```

### 3. Custom Domain Setup

1. **In Replit**: Deployments → Custom Domain
2. **Add CNAME**: `app.yourdomain.com` → `<repl-name>.<username>.repl.co`
3. **Wait for DNS** propagation (~10 min)
4. **Test**: Visit `https://app.yourdomain.com`

---

## 📊 Monitoring on Replit

### Check Logs

```bash
# In Replit console:
# Logs are automatically shown
# Or use: replit logs
```

### Performance Monitoring

- **Replit Dashboard** → Your Repl → "Metrics"
- Shows:
  - CPU usage
  - Memory usage  
  - Request count
  - Response times

---

## 🔐 Security Best Practices

1. **Never commit secrets** to Git
   - Use Replit Secrets only
   - Add `.env` to `.gitignore`

2. **Use strong session secret**
   ```bash
   # Generate with:
   node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
   ```

3. **Enable HTTPS** (Replit provides this automatically)

4. **Rate limiting** (already implemented in code)

5. **Regular updates**
   ```bash
   npm audit
   npm update
   ```

---

## 📝 Summary

**Your code is REPLIT-READY!** 🎉

- ✅ All fixes work with Replit connectors
- ✅ Automatic fallback system
- ✅ No code changes needed
- ✅ One-click integration setup
- ✅ Production-ready deployment

**To deploy:**
1. Push code to Replit
2. Set environment variables
3. Connect Notion via Replit UI
4. Test the flow
5. Deploy to production!

---

## 🆘 Support

If you encounter issues on Replit:

1. Check **Replit Status**: https://status.replit.com
2. Review **Replit Docs**: https://docs.replit.com
3. Check app logs in console
4. Verify all environment variables
5. Test locally first if possible

---

**Happy Deploying!** 🚀

