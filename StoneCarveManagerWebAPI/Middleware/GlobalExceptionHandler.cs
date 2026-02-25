using FluentValidation;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using System.Net;

namespace StoneCarveManagerWebAPI.Middleware
{
    public static class GlobalExceptionHandler
    {
        public static void ConfigureExceptionHandler(this IApplicationBuilder app)
        {
            app.UseExceptionHandler(appError =>
            {
                appError.Run(async context =>
                {
                    context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
                    context.Response.ContentType = "application/json";

                    var contextFeature = context.Features.Get<IExceptionHandlerFeature>();
                    if (contextFeature != null)
                    {
                        var exception = contextFeature.Error;

                        // Handle FluentValidation ValidationException
                        if (exception is ValidationException validationException)
                        {
                            context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
                            
                            var errors = validationException.Errors.Select(e => new
                            {
                                field = e.PropertyName,
                                message = e.ErrorMessage
                            });

                            await context.Response.WriteAsJsonAsync(new { errors });
                            return;
                        }

                        // Handle other exceptions
                        await context.Response.WriteAsJsonAsync(new
                        {
                            message = exception.Message,
                            statusCode = context.Response.StatusCode
                        });
                    }
                });
            });
        }
    }
}
