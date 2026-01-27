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
using System;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.ConfigureApplication();
builder.Services.AddControllers();

builder.Services.AddValidatorsFromAssemblyContaining<UserInsertRequestValidator>();


var app = builder.Build();

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
