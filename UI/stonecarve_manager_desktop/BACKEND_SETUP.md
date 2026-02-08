# 🚀 Backend Setup Guide

## Quick Start

### 1. Open Backend Solution
```bash
# Navigate to your backend project
cd "c:\Users\Ismail\Desktop\StoneCarveManagerApp\StoneCarveManager"

# Open in Visual Studio
start StoneCarveManager.sln
```

### 2. Run Backend in Visual Studio
1. Open **StoneCarveManager.sln** in Visual Studio
2. Right-click on the **StoneCarveManager** project
3. Select **"Set as Startup Project"**
4. Press **F5** or click **"Run"** button
5. Backend should start on **http://localhost:5021**

### 3. Verify Backend is Running
- Open browser and go to: `http://localhost:5021/swagger/index.html`
- You should see the Swagger API documentation
- Check these endpoints are available:
  - `GET /api/Product` - Should return products list
  - `POST /auth/login` - Authentication endpoint
  - `GET /api/Material` - Materials endpoint
  - `GET /api/Category` - Categories endpoint

## Troubleshooting

### If Backend Won't Start:
1. **Check Dependencies**:
   ```bash
   dotnet restore
   dotnet build
   ```

2. **Database Issues**:
   - Check connection string in `appsettings.json`
   - Run database migrations:
   ```bash
   dotnet ef database update
   ```

3. **Port Conflicts**:
   - Change port in `launchSettings.json` if 5021 is busy
   - Update Flutter app base URL to match new port

### If CORS Errors Occur:
Ensure `Program.cs` or `Startup.cs` has CORS configured:
```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutter",
        builder =>
        {
            builder
                .AllowAnyOrigin()
                .AllowAnyMethod()
                .AllowAnyHeader();
        });
});

// After app is built:
app.UseCors("AllowFlutter");
```

### Test Connection from Flutter:
1. Open Flutter app
2. Go to Login screen
3. Click **"🔧 Test Backend Connection"**
4. Click **"🔍 Full Test"** to run comprehensive check

## Expected Backend Structure

Your backend should have these controllers:
- **AuthController** - Handles login/register at `/auth/`
- **ProductController** - CRUD operations at `/api/Product`
- **MaterialController** - CRUD operations at `/api/Material`
- **CategoryController** - CRUD operations at `/api/Category`

## Default Test Credentials

If you have seed data, try:
- **Email**: `admin@stonecarve.com`
- **Password**: `Admin123!`

Or create a new user through the register endpoint first.

## Common Issues

### 1. "Connection Refused"
- Backend is not running
- Wrong port number
- Firewall blocking connection

### 2. "404 Not Found"
- Endpoint URL is incorrect
- Controller routing is misconfigured
- Project not built properly

### 3. "401 Unauthorized"
- Valid response! Endpoint is working
- Just need correct credentials
- Check if authentication is required

### 4. CORS Policy Error
- Browser is blocking cross-origin requests
- Add CORS policy in backend
- Ensure preflight requests are handled

## Quick Commands

Start backend:
```bash
cd StoneCarveManager
dotnet run
```

Check if backend is responding:
```bash
curl http://localhost:5021/api/Product
```

View database:
```bash
dotnet ef dbcontext info
```

## 📱 Next Steps

Once backend is running:
1. Test connection using Flutter test screen
2. Try login with real credentials
3. Navigate through product management screens
4. Test CRUD operations

Need help? Check the debug output in Flutter connection test screen!