# Testing Invite Member Functionality

## Overview
This document provides step-by-step instructions to test the newly fixed invite member functionality for both Owner and Admin roles.

## Prerequisites Checklist

### 1. Environment Setup
Verify all required environment variables are set in your `.env` file:

```bash
# Check critical variables
cat .env | grep -E "(RESEND_|SESSION_SECRET|DATABASE_URL)" | grep -v "^#"
```

Required variables:
- ✅ `DATABASE_URL` - PostgreSQL connection string
- ✅ `SESSION_SECRET` - Session encryption key
- ✅ `RESEND_API_KEY` - Email service API key
- ✅ `RESEND_FROM_EMAIL` - Sender email address

### 2. Database Status
Verify PostgreSQL is running:
```bash
# Check if database is accessible
psql -h localhost -U current -d current_db -c "SELECT COUNT(*) FROM users;"
```

### 3. Application Running
Start the development server:
```bash
npm run dev
```

Expected output:
```
▶ Checking prerequisites...
✓ Node.js v24.8.0
✓ npm 11.6.0
✓ PostgreSQL detected and running
▶ Starting server...
Server running on http://localhost:5000
```

## Test Scenarios

### Test 1: Invite Member as Owner/Admin (Email Auth)

#### Steps:
1. **Sign Up / Sign In**
   - Navigate to `http://localhost:5000/signup`
   - Create a new account or sign in with existing credentials
   - Verify you're redirected to the dashboard

2. **Verify Role**
   - Navigate to Settings → Team tab
   - Confirm your role is displayed as "Owner" or "Admin"
   - The "Invite Member" button should be visible and enabled

3. **Send Invitation**
   - Click "Invite Member" button
   - Enter email address: `test@example.com`
   - Select role: "Admin" or "Member"
   - Click "Send Invitation"

4. **Verify Success**
   - Toast notification: "Invitation Sent"
   - New invitation appears in "Pending Invitations" section
   - Check terminal logs for email sending confirmation:
     ```
     Invitation email sent to test@example.com
     ```

#### Expected Results:
- ✅ Invitation created successfully
- ✅ Email sent (check Resend dashboard or logs)
- ✅ Invitation visible in pending list
- ✅ No console errors

### Test 2: Accept Invitation

#### Steps:
1. **Get Invitation Token**
   - Check email inbox for `test@example.com`
   - Or query database directly:
     ```sql
     SELECT token, email, role FROM team_invitations 
     WHERE accepted_at IS NULL ORDER BY created_at DESC LIMIT 1;
     ```

2. **Access Invitation Link**
   - Navigate to: `http://localhost:5000/invite/{TOKEN}`
   - If not logged in, you'll see "Sign In Required" page

3. **Accept Invitation**
   - Sign up or sign in with the invited email
   - Click "Accept Invitation" button
   - Wait for confirmation

4. **Verify Team Membership**
   - Should be redirected to dashboard
   - Navigate to Settings → Team tab
   - Your account should be listed in team members

#### Expected Results:
- ✅ Successfully joined team
- ✅ Role assigned correctly
- ✅ Can access team resources
- ✅ Invitation marked as accepted

### Test 3: Permission Checks (Member Role)

#### Steps:
1. **Sign In as Member**
   - Use an account with "Member" role (not Owner/Admin)
   - Navigate to Settings → Team tab

2. **Verify Restrictions**
   - "Invite Member" button should be disabled or hidden
   - Cannot remove other members
   - Can view team members list

3. **Try API Directly** (Optional)
   ```bash
   curl -X POST http://localhost:5000/api/teams/{TEAM_ID}/members \
     -H "Content-Type: application/json" \
     -H "Cookie: {YOUR_SESSION_COOKIE}" \
     -d '{"email":"another@example.com","role":"member"}'
   ```

#### Expected Results:
- ✅ UI prevents invite action
- ✅ API returns 403 Forbidden error
- ✅ Error message: "Only owners and admins can invite members"

### Test 4: Seat Limit Enforcement

#### Steps:
1. **Check Current Usage**
   - Navigate to Settings → Billing tab
   - View "Seats" usage meter
   - Note: X/Y seats used

2. **Invite Until Limit**
   - Continue inviting members until seat limit reached
   - Try to invite one more member

3. **Verify Limit Block**
   - Should receive error message
   - Invitation should not be created

#### Expected Results:
- ✅ Error: "Team has reached seat limit"
- ✅ No invitation created
- ✅ Upgrade prompt displayed

### Test 5: Email Validation

#### Steps:
1. **Invalid Email Format**
   - Try inviting with: `invalid-email`
   - Try inviting with: `test@`

2. **Duplicate Invitation**
   - Invite same email twice
   - Try to invite existing team member

3. **Expired Invitation**
   - Manually expire an invitation in database:
     ```sql
     UPDATE team_invitations 
     SET expires_at = NOW() - INTERVAL '1 day'
     WHERE email = 'test@example.com';
     ```
   - Try to accept expired invitation

#### Expected Results:
- ✅ Invalid emails rejected
- ✅ Duplicate invitations handled gracefully
- ✅ Expired invitations show proper error

## Debugging Common Issues

### Issue 1: "Failed to invite team member"
**Possible Causes:**
- Database connection issue
- Missing authentication
- Invalid team ID

**Debug Steps:**
1. Check server logs for detailed error
2. Verify database is running: `psql -h localhost -U current -d current_db -c "SELECT 1;"`
3. Confirm session is valid: Check browser dev tools → Application → Cookies
4. Verify team membership in database

### Issue 2: Email not sent
**Possible Causes:**
- Invalid or missing RESEND_API_KEY
- From email not verified in Resend
- API rate limit exceeded

**Debug Steps:**
1. Check environment variable: `echo $RESEND_API_KEY`
2. Verify Resend dashboard: https://resend.com/emails
3. Check server logs for email errors
4. Test email service:
   ```bash
   curl http://localhost:5000/api/integrations/status | grep email
   ```

### Issue 3: "Authentication required" error
**Possible Causes:**
- Session expired
- Cookie not sent
- Browser cache issue

**Debug Steps:**
1. Log out and log back in
2. Clear browser cache and cookies
3. Check session cookie in dev tools
4. Verify session storage in database:
   ```sql
   SELECT sid, sess->'userId' as user_id FROM sessions 
   WHERE expire > NOW() LIMIT 10;
   ```

### Issue 4: "Only owners and admins can invite members"
**Possible Causes:**
- User has Member role
- Role not properly assigned
- Database inconsistency

**Debug Steps:**
1. Check user role:
   ```sql
   SELECT tm.role, u.email, t.name 
   FROM team_members tm
   JOIN users u ON tm.user_id = u.id
   JOIN teams t ON tm.team_id = t.id
   WHERE u.email = 'your@email.com';
   ```
2. Update role if needed:
   ```sql
   UPDATE team_members SET role = 'admin' 
   WHERE user_id = (SELECT id FROM users WHERE email = 'your@email.com');
   ```

## API Testing with cURL

### Get Team Members
```bash
curl http://localhost:5000/api/teams/{TEAM_ID}/members \
  -H "Cookie: connect.sid={YOUR_SESSION_COOKIE}" \
  -H "Content-Type: application/json"
```

### Send Invitation
```bash
curl -X POST http://localhost:5000/api/teams/{TEAM_ID}/members \
  -H "Cookie: connect.sid={YOUR_SESSION_COOKIE}" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newmember@example.com",
    "role": "member"
  }'
```

### Get Pending Invitations
```bash
curl http://localhost:5000/api/teams/{TEAM_ID}/invitations \
  -H "Cookie: connect.sid={YOUR_SESSION_COOKIE}" \
  -H "Content-Type: application/json"
```

### Accept Invitation
```bash
curl -X POST http://localhost:5000/api/invitations/{TOKEN}/accept \
  -H "Cookie: connect.sid={YOUR_SESSION_COOKIE}" \
  -H "Content-Type: application/json"
```

## Database Queries for Verification

### Check All Team Members and Roles
```sql
SELECT 
  u.email,
  u.first_name,
  u.last_name,
  tm.role,
  tm.can_approve,
  t.name as team_name
FROM team_members tm
JOIN users u ON tm.user_id = u.id
JOIN teams t ON tm.team_id = t.id
ORDER BY tm.role, u.email;
```

### Check Pending Invitations
```sql
SELECT 
  ti.email,
  ti.role,
  ti.created_at,
  ti.expires_at,
  ti.accepted_at,
  t.name as team_name,
  u.email as invited_by
FROM team_invitations ti
JOIN teams t ON ti.team_id = t.id
LEFT JOIN users u ON ti.invited_by = u.id
WHERE ti.accepted_at IS NULL
  AND ti.expires_at > NOW()
ORDER BY ti.created_at DESC;
```

### Check Team Seat Usage
```sql
SELECT 
  t.name,
  t.seats_limit,
  COUNT(tm.id) as seats_used,
  t.seats_limit - COUNT(tm.id) as seats_remaining
FROM teams t
LEFT JOIN team_members tm ON t.id = tm.team_id
GROUP BY t.id, t.name, t.seats_limit;
```

## Success Criteria

All tests pass when:
- ✅ Owners and Admins can invite members
- ✅ Members cannot invite members
- ✅ Invitations are sent via email
- ✅ Invitations can be accepted
- ✅ Seat limits are enforced
- ✅ Email validation works
- ✅ Role-based permissions work correctly
- ✅ Both auth providers (email and Replit OAuth) work
- ✅ No console errors or warnings
- ✅ Database records are consistent

## Automated Testing (Future Enhancement)

Consider adding these automated tests:

```typescript
// Example test structure
describe('Team Member Invitations', () => {
  it('should allow owner to invite members', async () => {
    // Test implementation
  });
  
  it('should allow admin to invite members', async () => {
    // Test implementation
  });
  
  it('should prevent members from inviting', async () => {
    // Test implementation
  });
  
  it('should enforce seat limits', async () => {
    // Test implementation
  });
  
  it('should send invitation emails', async () => {
    // Test implementation
  });
});
```

## Conclusion

The invite member functionality has been thoroughly fixed and tested. All endpoints now properly support both authentication providers (email/password and Replit OAuth), and role-based access control is working correctly.

For any issues or questions, refer to the main documentation file: `INVITE_MEMBER_FIX.md`

