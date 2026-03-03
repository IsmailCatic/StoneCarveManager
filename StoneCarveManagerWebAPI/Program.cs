using DotNetEnv;
using FluentValidation;
using Mapster;
using MapsterMapper;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.Validators;
using StoneCarveManager.Services.Database.Context;
using StoneCarveManager.Services.Database.Entities;
using StoneCarveManager.Services.IServices;
using StoneCarveManager.Services.Services;
using StoneCarveManagerWebAPI.Extensions;
using StoneCarveManagerWebAPI.Middleware;
using System;

// Load .env file (looks in project root, then solution root)
try
{
    var envPath = Path.Combine(Directory.GetCurrentDirectory(), ".env");
    if (!File.Exists(envPath))
        envPath = Path.Combine(Directory.GetCurrentDirectory(), "..", ".env");

    if (File.Exists(envPath))
    {
        Env.Load(envPath);
        Console.WriteLine($"✅ Loaded .env from {envPath}");
    }
    else
    {
        Console.WriteLine("⚠️ .env file not found, using appsettings.json or environment variables");
    }
}
catch (Exception ex)
{
    Console.WriteLine($"⚠️ Failed to load .env: {ex.Message}");
}

var builder = WebApplication.CreateBuilder(args);

// Map flat .env keys to ASP.NET Core hierarchical config
var envOverrides = new Dictionary<string, string?>();

void MapEnv(string envKey, string configKey)
{
    var value = Environment.GetEnvironmentVariable(envKey);
    if (!string.IsNullOrEmpty(value))
        envOverrides[configKey] = value;
}

MapEnv("DB_CONNECTION_STRING", "ConnectionStrings:MainDB");
MapEnv("JWT_ISSUER", "AuthSettings:Issuer");
MapEnv("JWT_SECRET_KEY", "AuthSettings:SecretKey");
MapEnv("CORS_ALLOWED_ORIGINS", "CORSAllowedOrigins");
MapEnv("AZURE_BLOB_CONNECTION_STRING", "AzureBlobStorage:ConnectionString");
MapEnv("STRIPE_PUBLISHABLE_KEY", "Stripe:PublishableKey");
MapEnv("STRIPE_SECRET_KEY", "Stripe:SecretKey");
MapEnv("FRONTEND_URL", "FrontendUrl");
MapEnv("RABBITMQ_USER", "RabbitMQ:UserName");
MapEnv("RABBITMQ_PASSWORD", "RabbitMQ:Password");

if (envOverrides.Count > 0)
{
    builder.Configuration.AddInMemoryCollection(envOverrides);
    Console.WriteLine($"✅ Mapped {envOverrides.Count} values from .env into configuration");
}

// Add services to the container.

builder.ConfigureApplication();
builder.Services.AddControllers();

builder.Services.AddValidatorsFromAssemblyContaining<UserInsertRequestValidator>();


var app = builder.Build();

// Apply EF Core migrations on startup
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    db.Database.Migrate();
}

// Configure global exception handler for validation errors
app.ConfigureExceptionHandler();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
