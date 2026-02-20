using MimeKit;
using RabbitMQ.Client.Events;
using RabbitMQ.Client;
using System.Text.Json;
using System.Text;
using MailKit.Net.Smtp;

namespace StoneCarveManager.EmailService
{
    public class Worker : BackgroundService
    {
        private readonly ILogger<Worker> _logger;
        private readonly IConnection _connection;
        private readonly IModel _channelRegistration;
        private readonly IModel _channelPasswordReset;
        private readonly IConfiguration _configuration;

        public Worker(ILogger<Worker> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;

            var factory = new ConnectionFactory()
            {
                HostName = "localhost",
                Port = 5672,
                UserName = "guest",
                Password = "guest",
                RequestedHeartbeat = TimeSpan.FromSeconds(60),
                AutomaticRecoveryEnabled = true
            };

            int retryCount = 0;
            const int maxRetries = 5;
            while (retryCount < maxRetries)
            {
                try
                {
                    _connection = factory.CreateConnection();
                    
                    // Kanal za user registration
                    _channelRegistration = _connection.CreateModel();
                    _channelRegistration.QueueDeclare(queue: "user-registration",
                                        durable: false,
                                        exclusive: false,
                                        autoDelete: false,
                                        arguments: null);
                    
                    // ? Kanal za password reset
                    _channelPasswordReset = _connection.CreateModel();
                    _channelPasswordReset.QueueDeclare(queue: "password-reset",
                                        durable: false,
                                        exclusive: false,
                                        autoDelete: false,
                                        arguments: null);
                    
                    _logger.LogInformation("? Connected to RabbitMQ successfully at localhost:5672!");
                    break;
                }
                catch (Exception ex)
                {
                    retryCount++;
                    if (retryCount == maxRetries)
                        throw;
                    _logger.LogWarning(ex, "Failed to connect to RabbitMQ. Attempt {RetryCount} of {MaxRetries}. Retrying in 5 seconds...", retryCount, maxRetries);
                    Thread.Sleep(5000);
                }
            }
        }

        protected override Task ExecuteAsync(CancellationToken stoppingToken)
        {
            stoppingToken.ThrowIfCancellationRequested();

            // Consumer za user registration
            var consumerRegistration = new EventingBasicConsumer(_channelRegistration);
            consumerRegistration.Received += (model, ea) =>
            {
                var body = ea.Body.ToArray();
                var message = Encoding.UTF8.GetString(body);
                _logger.LogInformation("?? Received message from RabbitMQ: {Message}", message);
                SendEmailAsync(message).Wait();
            };

            _channelRegistration.BasicConsume(queue: "user-registration",
                                 autoAck: true,
                                 consumer: consumerRegistration);

            // ? Consumer za password reset
            var consumerPasswordReset = new EventingBasicConsumer(_channelPasswordReset);
            consumerPasswordReset.Received += (model, ea) =>
            {
                var body = ea.Body.ToArray();
                var message = Encoding.UTF8.GetString(body);
                _logger.LogInformation("?? Received password reset request from RabbitMQ: {Message}", message);
                SendPasswordResetEmailAsync(message).Wait();
            };

            _channelPasswordReset.BasicConsume(queue: "password-reset",
                                 autoAck: true,
                                 consumer: consumerPasswordReset);

            _logger.LogInformation("?? StoneCarveManager EmailService Worker is running and listening to queues...");
            _logger.LogInformation("   - user-registration");
            _logger.LogInformation("   - password-reset");
            return Task.CompletedTask;
        }

        private async Task SendEmailAsync(string message)
        {
            var user = JsonSerializer.Deserialize<UserRegistrationMessage>(message);
            if (user == null || string.IsNullOrEmpty(user.Email))
            {
                _logger.LogError("? Invalid message format.");
                return;
            }

            var emailMessage = new MimeMessage();
            emailMessage.From.Add(new MailboxAddress("StoneCarve Manager", "noreply@stonecarve.com"));
            emailMessage.To.Add(new MailboxAddress(user.Name, user.Email));

            string subject;
            string body;

            switch (user.Role)
            {
                case 1: // Admin
                    subject = "Dobrodošli, StoneCarve Administrator!";
                    body = $@"
                <html>
                <body>
                    <h2>Pozdrav, Admin {user.Name},</h2>
                    <p>Vaš administratorski ra?un u StoneCarve Manager sistemu je uspješno kreiran.</p>
                    <p>Sada možete upravljati korisnicima, proizvodima i narudžbama.</p>
                    <p><strong>Vaše korisni?ko ime je: {user.KorisnickoIme}</strong></p>
                    <p><strong>Vaša lozinka za prijavu je: {user.Password}</strong></p>
                    <p>Iz sigurnosnih razloga obavezno promijenite lozinku nakon prve prijave.</p>
                    <p><strong>Vaš StoneCarve Manager tim</strong></p>
                </body>
                </html>";
                    break;

                case 2: // Employee
                    subject = "Dobrodošli, StoneCarve Zaposleni!";
                    body = $@"
                <html>
                <body>
                    <h2>Pozdrav, {user.Name},</h2>
                    <p>Vaš ra?un zaposlenika u StoneCarve Manager sistemu je uspješno kreiran.</p>
                    <p>Sada možete upravljati narudžbama i proizvodima.</p>
                    <p><strong>Vaše korisni?ko ime je: {user.KorisnickoIme}</strong></p>
                    <p><strong>Vaša lozinka za prijavu je: {user.Password}</strong></p>
                    <p>Iz sigurnosnih razloga obavezno promijenite lozinku nakon prve prijave.</p>
                    <p><strong>Vaš StoneCarve Manager tim</strong></p>
                </body>
                </html>";
                    break;

                case 3: // Obi?ni korisnik
                    subject = "Dobrodošli u StoneCarve Manager!";
                    body = $@"
                <html>
                <body>
                    <h2>Dobrodošli u StoneCarve Manager, {user.Name}!</h2>
                    <p>Drago nam je što ste se pridružili našoj zajednici.</p>
                    <p>Vaša registracija je uspješna i sada imate pristup našim proizvodima od kamena.</p>
                    <p>Istražite ponudu i po?nite naru?ivati svoje omiljene proizvode!</p>
                    <p>Vidimo se uskoro,</p>
                    <p><strong>Vaš StoneCarve Manager tim</strong></p>
                </body>
                </html>";
                    break;

                default:
                    subject = "StoneCarve Manager Registracija";
                    body = $@"
                <html>
                <body>
                    <h2>Dobrodošli, {user.Name}!</h2>
                    <p>Vaš StoneCarve Manager ra?un je uspješno kreiran.</p>
                    <p><strong>Vaš StoneCarve Manager tim</strong></p>
                </body>
                </html>";
                    break;
            }

            emailMessage.Subject = subject;
            emailMessage.Body = new TextPart("html") { Text = body };

            await SendEmailViaSmtpAsync(emailMessage, user.Email);
        }

        // ? Method for sending password reset email with verification code
        private async Task SendPasswordResetEmailAsync(string message)
        {
            var resetRequest = JsonSerializer.Deserialize<PasswordResetMessage>(message);
            if (resetRequest == null || string.IsNullOrEmpty(resetRequest.Email))
            {
                _logger.LogError("? Invalid password reset message format.");
                return;
            }

            var emailMessage = new MimeMessage();
            emailMessage.From.Add(new MailboxAddress("StoneCarve Manager", "noreply@stonecarve.com"));
            emailMessage.To.Add(new MailboxAddress(resetRequest.Name, resetRequest.Email));
            emailMessage.Subject = "Password Reset - Verification Code";

            _logger.LogInformation("?? Sending verification code: {Code} to {Email}", resetRequest.VerificationCode, resetRequest.Email);

            // Calculate remaining time (1 hour from now)
            var expiresAt = DateTime.UtcNow.AddHours(1);
            var minutesRemaining = (int)(expiresAt - DateTime.UtcNow).TotalMinutes;

            var body = $@"
            <html>
            <body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>
                <div style='max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px;'>
                    <h2 style='color: #2c3e50;'>?? Password Reset</h2>
                    <p>Hello <strong>{resetRequest.Name}</strong>,</p>
                    <p>We received your password reset request.</p>
                    <p>Use the following <strong>6-digit verification code</strong> to reset your password:</p>
                    
                    <div style='text-align: center; margin: 40px 0;'>
                        <div style='background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; border-radius: 12px; display: inline-block; box-shadow: 0 8px 16px rgba(0,0,0,0.2);'>
                            <p style='margin: 0; font-size: 14px; opacity: 0.9;'>Your Verification Code</p>
                            <p style='margin: 10px 0 0 0; font-size: 48px; font-weight: bold; letter-spacing: 8px; font-family: monospace;'>{resetRequest.VerificationCode}</p>
                        </div>
                    </div>
                    
                    <div style='background-color: #fff3cd; border: 1px solid #ffc107; border-radius: 5px; padding: 15px; margin: 20px 0; text-align: center;'>
                        <p style='color: #856404; font-weight: bold; font-size: 16px; margin: 0;'>? Code expires in {minutesRemaining} minutes</p>
                    </div>
                    
                    <div style='background-color: #e3f2fd; border-left: 4px solid #2196f3; padding: 15px; margin: 20px 0;'>
                        <p style='margin: 0; color: #1565c0;'>
                            <strong>?? How to use:</strong><br/>
                            1. Open the password reset page<br/>
                            2. Enter your email address<br/>
                            3. Copy and paste the code above<br/>
                            4. Set your new password
                        </p>
                    </div>
                    
                    <div style='background-color: #ffe6e6; border-left: 4px solid #ff4444; padding: 15px; margin: 20px 0;'>
                        <p style='margin: 0; color: #721c24;'>
                            ?? If you didn't request a password reset, please ignore this email. 
                            Your password remains secure.
                        </p>
                    </div>
                    
                    <hr style='border: none; border-top: 1px solid #e0e0e0; margin: 30px 0;' />
                    
                    <p style='font-size: 14px; color: #666;'>
                        <strong>Need help?</strong> Contact our support team.
                    </p>
                    
                    <p style='margin-top: 30px; text-align: center; color: #7f8c8d; font-size: 12px;'>
                        <strong>Your StoneCarve Manager Team</strong><br/>
                        © 2026 StoneCarve Manager. All rights reserved.
                    </p>
                </div>
            </body>
            </html>";

            emailMessage.Body = new TextPart("html") { Text = body };

            await SendEmailViaSmtpAsync(emailMessage, resetRequest.Email);
        }

        // ? Izdvojena metoda za SMTP slanje (DRY principle)
        private async Task SendEmailViaSmtpAsync(MimeMessage emailMessage, string recipientEmail)
        {
            using (var client = new SmtpClient())
            {
                var smtpServer = Environment.GetEnvironmentVariable("EMAIL_SMTP_SERVER") ?? _configuration["Email:SmtpServer"];
                var smtpPort = int.Parse(Environment.GetEnvironmentVariable("EMAIL_SMTP_PORT") ?? _configuration["Email:SmtpPort"]);
                var emailUsername = Environment.GetEnvironmentVariable("EMAIL_USERNAME") ?? _configuration["Email:Username"];
                var emailPassword = Environment.GetEnvironmentVariable("EMAIL_PASSWORD");

                try
                {
                    await client.ConnectAsync(smtpServer, smtpPort, MailKit.Security.SecureSocketOptions.StartTls);
                    await client.AuthenticateAsync(emailUsername, emailPassword);
                    await client.SendAsync(emailMessage);
                    _logger.LogInformation("? Email uspješno poslan na {Email}.", recipientEmail);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "? Slanje emaila nije uspjelo na {Email}.", recipientEmail);
                }
                finally
                {
                    await client.DisconnectAsync(true);
                }
            }
        }

        public override Task StopAsync(CancellationToken cancellationToken)
        {
            _channelRegistration?.Close();
            _channelPasswordReset?.Close();
            _connection?.Close();
            _logger.LogInformation("?? StoneCarveManager EmailService Worker stopped.");
            return base.StopAsync(cancellationToken);
        }
    }
}
