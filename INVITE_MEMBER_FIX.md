# Invite Member Functionality - Fix Documentation

## Problem Summary
Users with Owner or Admin roles were unable to invite new team members. The invite functionality was not working correctly for users authenticated via email/password authentication.

## Root Cause
The invite member endpoint (POST `/api/teams/:teamId/members`) and related endpoints were using `user.claims.sub` directly to extract the user ID, which only works with Replit OAuth authentication. This approach failed for users authenticated via email/password, as their user ID is stored in `session.userId` instead.

## Solution Implemented

### 1. Fixed Authentication User ID Extraction
Modified the following endpoints to use the `getUserIdFromRequest()` helper function, which correctly handles both authentication providers:

#### Endpoints Fixed:
- `POST /api/teams/:teamId/members` - Invite member endpoint
- `GET /api/teams/:teamId` - Get team details
- `GET /api/teams/:teamId/members` - Get team members list
- `GET /api/teams/:teamId/quotas` - Get team quotas
- `POST /api/invitations/:token/accept` - Accept invitation

#### Changes Made:
**Before:**
```typescript
const user = req.user as any;
const userId = user.claims.sub;
```

**After:**
```typescript
const userId = getUserIdFromRequest(req);
if (!userId) {
  return res.status(401).json({ error: "Authentication required" });
}
```

### 2. Enhanced Invitation Acceptance
Updated the invitation acceptance endpoint to:
- Fetch the current user from the database to get their email
- Compare invitation email with the user's actual email from the database
- Support both authentication providers seamlessly

## getUserIdFromRequest Function
This helper function properly extracts the user ID from both authentication providers:

```typescript
function getUserIdFromRequest(req: Request): string | null {
  // Check Replit OAuth user
  const user = req.user as any;
  if (user?.claims?.sub) {
    return user.claims.sub;
  }
  // Check email-based auth session
  const session = req.session as any;
  if (session?.userId) {
    return session.userId;
  }
  return null;
}
```

## Testing the Fix

### Prerequisites
1. Ensure PostgreSQL database is running
2. Set up environment variables (especially `RESEND_API_KEY` for email sending)
3. Have at least one team with Owner or Admin role

### Test Scenario 1: Invite Member (Email Auth)
1. Log in using email/password authentication
2. Navigate to Settings → Team tab
3. Click "Invite Member" button
4. Enter email address and select role
5. Click "Send Invitation"
6. **Expected Result:** Invitation should be sent successfully, email delivered

### Test Scenario 2: Accept Invitation (Email Auth)
1. Receive invitation email
2. Click the invitation link
3. Sign in with your email/password
4. **Expected Result:** Successfully join the team, redirected to dashboard

### Test Scenario 3: Check Permissions
1. Log in as a regular Member (not Owner/Admin)
2. Navigate to Settings → Team tab
3. **Expected Result:** "Invite Member" button should be disabled or not visible

### Test Scenario 4: Seat Limit Check
1. Log in as Owner/Admin
2. Add members until seat limit is reached
3. Try to invite another member
4. **Expected Result:** Error message about reaching seat limit

## Authentication Compatibility

The application now supports two authentication providers seamlessly:

### 1. Email/Password Authentication
- Used for local development and non-Replit deployments
- User ID stored in `session.userId`
- Routes: `/login`, `/signup`, `/verify-email`, etc.

### 2. Replit OAuth Authentication
- Used when deployed on Replit platform
- User ID available in `user.claims.sub`
- Routes: `/api/login`, `/api/callback`, `/api/logout`

Both authentication methods work interchangeably with all endpoints.

## Files Modified
1. `/server/routes.ts` - Fixed 5 endpoints to use `getUserIdFromRequest()`
2. All changes maintain backward compatibility with existing code

## Environment Variables Required

### For Email Invitations to Work:
```env
# Required for sending invitation emails
RESEND_API_KEY=your_resend_api_key
RESEND_FROM_EMAIL=noreply@yourdomain.com

# Required for email links
BASE_URL=http://localhost:5000  # or your production URL
```

### Get Resend API Key:
1. Visit https://resend.com
2. Sign up for a free account
3. Create an API key
4. Add it to your `.env` file

## Verification Checklist

- [x] Fixed invite member endpoint authentication
- [x] Fixed team member listing endpoint authentication
- [x] Fixed team details endpoint authentication
- [x] Fixed team quotas endpoint authentication
- [x] Fixed invitation acceptance endpoint authentication
- [x] All endpoints support both auth providers
- [x] Proper error handling for missing authentication
- [x] No linter errors introduced

## Additional Improvements

### Role-Based Access Control
The fix maintains proper RBAC:
- Only Owners and Admins can invite members
- Only Owners and Admins can remove members
- Owners cannot be removed
- Members can view team but cannot manage it

### Seat Limit Enforcement
The fix maintains proper seat limit checks:
- Checks current member count before inviting
- Respects plan-based seat limits
- Provides clear error messages when limit reached

## Troubleshooting

### Issue: "Only owners and admins can invite members" error
- **Cause:** User doesn't have Owner or Admin role
- **Solution:** Contact team owner to upgrade your role

### Issue: "Invitation email not sent"
- **Cause:** Missing or invalid `RESEND_API_KEY`
- **Solution:** Set up Resend API key in environment variables

### Issue: "Authentication required" error
- **Cause:** Session expired or not authenticated
- **Solution:** Log out and log back in

### Issue: "Team has reached seat limit"
- **Cause:** Current plan's seat limit reached
- **Solution:** Upgrade plan or remove inactive members

## Summary
The invite member functionality is now fully operational for both Owner and Admin roles, supporting both email/password and Replit OAuth authentication seamlessly. All related endpoints have been updated to use consistent authentication handling.

