# 🚫 Block User Feature - Backend Implementation Guide

## Overview
The frontend now properly handles blocked users at login. You need to implement the backend validation to check the `isBlocked` flag during authentication.

---

## ✅ What the Frontend Now Does

1. **Handles 403 Responses**: AuthProvider catches 403 status codes from login endpoint
2. **Shows User-Friendly Dialog**: Displays a clear "Account Blocked" dialog with icon
3. **Extracts Backend Message**: Reads error message from response body (`message` or `error` field)

---

## 🔧 Backend Changes Required

### 1. Update Login Endpoint (`/auth/login`)

**Location**: `AuthController.cs` (or similar)

**What to Add**: Check if user is blocked BEFORE generating the JWT token

```csharp
[HttpPost("login")]
public async Task<IActionResult> Login([FromBody] LoginRequest request)
{
    // ... existing email/password validation ...
    
    var user = await _userRepository.GetByEmail(request.Email);
    
    if (user == null || !VerifyPassword(request.Password, user.PasswordHash))
    {
        return Unauthorized(new { message = "Invalid email or password" });
    }
    
    // ⭐ ADD THIS: Check if user is blocked
    if (user.IsBlocked == true)
    {
        return StatusCode(403, new 
        { 
            message = "Your account has been blocked. Please contact an administrator for assistance.",
            error = "Account blocked"
        });
    }
    
    // ... continue with token generation ...
    var token = GenerateJwtToken(user);
    return Ok(new { token, userId = user.Id, roles = user.Roles });
}
```

---

### 2. Update Authentication Middleware (Recommended)

**Location**: Create or update middleware that validates JWT tokens

**Purpose**: Force logout blocked users who are already logged in

```csharp
public class BlockedUserMiddleware
{
    private readonly RequestDelegate _next;

    public BlockedUserMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context, IUserRepository userRepository)
    {
        // Skip for public endpoints (login, register, etc.)
        if (context.Request.Path.StartsWithSegments("/auth"))
        {
            await _next(context);
            return;
        }

        // Get user ID from JWT token claims
        var userIdClaim = context.User?.FindFirst("userId")?.Value;
        
        if (!string.IsNullOrEmpty(userIdClaim) && int.TryParse(userIdClaim, out int userId))
        {
            var user = await userRepository.GetById(userId);
            
            if (user?.IsBlocked == true)
            {
                context.Response.StatusCode = 403;
                context.Response.ContentType = "application/json";
                await context.Response.WriteAsJsonAsync(new 
                { 
                    message = "Your account has been blocked. You have been logged out.",
                    error = "Account blocked"
                });
                return;
            }
        }

        await _next(context);
    }
}

// In Program.cs or Startup.cs:
app.UseMiddleware<BlockedUserMiddleware>();
```

---

### 3. Update Block User Endpoint (`/api/User/{id}`)

**Current Implementation**: Already updates `isBlocked` field ✅

**Optional Enhancement**: Invalidate active tokens when blocking a user

```csharp
[HttpPut("{id}")]
public async Task<IActionResult> UpdateUser(int id, [FromBody] UserUpdateRequest request)
{
    var user = await _userRepository.GetById(id);
    if (user == null) return NotFound();
    
    // Update user fields
    user.IsBlocked = request.IsBlocked;
    user.Role = request.Role;
    
    await _userRepository.Update(user);
    
    // ⭐ OPTIONAL: Log the block action for audit trail
    if (request.IsBlocked == true)
    {
        await _auditLogger.LogAsync(new AuditLog
        {
            Action = "USER_BLOCKED",
            UserId = id,
            PerformedBy = GetCurrentUserId(),
            Timestamp = DateTime.UtcNow,
            Details = $"User {user.Email} was blocked"
        });
    }
    
    return Ok(user);
}
```

---

## 🧪 Testing the Implementation

### Test Case 1: Block User at Login
1. Block a user in the Flutter app (Users screen)
2. Log out
3. Try to log in as that user
4. **Expected**: Red dialog showing "Account Blocked" message

### Test Case 2: Backend Response Format
```bash
# Test with curl:
curl -X POST http://localhost:5021/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"blocked@test.com","password":"Test123!"}'

# Expected response (HTTP 403):
{
  "message": "Your account has been blocked. Please contact an administrator for assistance.",
  "error": "Account blocked"
}
```

### Test Case 3: Already Logged In User (if middleware implemented)
1. User is logged in and using the app
2. Admin blocks their account
3. User makes any API request
4. **Expected**: 403 response, gets logged out

---

## 📋 Database Schema Verification

Ensure your `Users` table has the `isBlocked` column:

```sql
-- Check if column exists
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Users' AND COLUMN_NAME = 'isBlocked';

-- If missing, add it:
ALTER TABLE Users 
ADD isBlocked BIT NOT NULL DEFAULT 0;
```

---

## 🎯 Summary Checklist

- [ ] Update `AuthController` login endpoint to check `isBlocked` BEFORE token generation
- [ ] Return 403 status code with proper error message format
- [ ] Test blocked user cannot log in
- [ ] **(Optional)** Add middleware to block active sessions
- [ ] **(Optional)** Add audit logging for block/unblock actions
- [ ] Verify database has `isBlocked` column

---

## 🔄 Response Format Required

The frontend expects this JSON structure for blocked users:

```json
{
  "message": "Your account has been blocked. Please contact an administrator for assistance.",
  "error": "Account blocked"
}
```

The frontend will extract either the `message` or `error` field to display to the user.

---

## 📞 Need Help?

If you have questions about:
- JWT token validation
- Middleware setup in ASP.NET Core
- Entity Framework queries

Just ask and I can provide more detailed code examples!
