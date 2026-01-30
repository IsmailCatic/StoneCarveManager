using Mapster;
using MapsterMapper;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.Responses.StoneCarveManager.Model.Responses;
using StoneCarveManager.Services.Database.Context;
using StoneCarveManager.Services.Database.Entities;
using StoneCarveManager.Services.Extensions;
using StoneCarveManager.Services.IServices;
using StoneCarveManager.Services.Services;
using System.IdentityModel.Tokens.Jwt;
using System.Net;
using System.Text;
using static StoneCarveManager.Services.Constants;

namespace StoneCarveManagerWebAPI.Extensions
{
    internal static class ServiceCollectionExtensions
    {
        public static void ConfigureApplication(this WebApplicationBuilder builder)
        {
            builder.Services.RegisterServiceLayerDependencies(builder.Configuration);
            builder.Services.ConfigureSwagger();

            builder.Services.ConfigureCorsPolicy(builder);

            builder.Services.ConfigureIdentity(builder);

            builder.Services.AddHttpContextAccessor();



            // 1. Konfiguracija Mapster-a
            var config = TypeAdapterConfig.GlobalSettings;
            config.RegisterMapsterMappings();



            // 2. Registracija IMapper u DI
            builder.Services.AddSingleton(config);
            builder.Services.AddScoped<IMapper, ServiceMapper>();





        }

        private static void ConfigureCorsPolicy(this IServiceCollection services, WebApplicationBuilder builder)
        {
            services.AddCors(c =>
            {
                var corsAllowedOrigins = builder.Configuration["CORSAllowedOrigins"]?.Split(';', StringSplitOptions.RemoveEmptyEntries)
                    ?? [];

                c.AddPolicy(Policies.DefaultCORSPolicyName, bldr =>
                {
                    bldr.WithOrigins(corsAllowedOrigins)
                        .AllowAnyHeader()
                        .AllowAnyMethod()
                        .AllowCredentials();
                });
            });
        }

        private static void ConfigureIdentity(this IServiceCollection services, WebApplicationBuilder builder)
        {
            builder.Services.AddIdentity<User, Role>(options =>
            {
                // Password settings
                options.Password.RequireDigit = true;
                options.Password.RequireLowercase = true;
                options.Password.RequireNonAlphanumeric = true;
                options.Password.RequireUppercase = true;
                options.Password.RequiredLength = 6;

                // Lockout settings (optional)
                options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(5);
                options.Lockout.MaxFailedAccessAttempts = 5;
                options.Lockout.AllowedForNewUsers = true;

                // User settings
                options.User.RequireUniqueEmail = true;
            })
            .AddEntityFrameworkStores<AppDbContext>()
            .AddDefaultTokenProviders();

            builder.Services
                .AddAuthentication(options =>
                {
                    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
                })
                .AddJwtBearer(options =>
                {
                    options.TokenValidationParameters = new TokenValidationParameters
                    {
                        ValidateIssuer = true,
                        ValidateAudience = false,
                        ValidateLifetime = true,
                        ValidateIssuerSigningKey = true,
                        ValidIssuer = builder.Configuration["AuthSettings:Issuer"],
                        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["AuthSettings:SecretKey"])),
                    };  


                });

            builder.Services.AddAuthorization(options =>
            {
                options.AddPolicy(AuthorizationPolicies.Admin, policy => policy.RequireRole(Roles.Admin));
                options.AddPolicy(AuthorizationPolicies.User, policy => policy.RequireRole(Roles.User));
                options.AddPolicy(AuthorizationPolicies.Employee, policy => policy.RequireRole(Roles.Employee));
            });
        }

        private static void ConfigureSwagger(this IServiceCollection services)
        {
            services.AddSwaggerGen(options =>
            {
                options.AddSecurityDefinition(JwtBearerDefaults.AuthenticationScheme, new OpenApiSecurityScheme
                {
                    Description = "In order to authenticate pass in JWT token value, without Bearer prefix, below:",
                    Name = nameof(HttpRequestHeader.Authorization),
                    In = ParameterLocation.Header,
                    Type = SecuritySchemeType.Http,
                    BearerFormat = JwtConstants.TokenType,
                    Scheme = JwtBearerDefaults.AuthenticationScheme
                });

                options.AddSecurityRequirement(new OpenApiSecurityRequirement
                {
                    {
                        new OpenApiSecurityScheme
                        {
                            Reference = new OpenApiReference
                            {
                                Type = ReferenceType.SecurityScheme,
                                Id = JwtBearerDefaults.AuthenticationScheme
                            }
                        },
                        Array.Empty<string>()
                    }
                });
            });
        }



    }
}
