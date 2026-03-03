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
        private readonly IConfiguration _configuration;
        private IConnection? _connection;
        private IChannel? _channelRegistration;
        private IChannel? _channelPasswordReset;
        private IChannel? _channelOrderStatusChanged;

        public Worker(ILogger<Worker> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;
        }

        public override async Task StartAsync(CancellationToken cancellationToken)
        {
            var factory = new ConnectionFactory()
            {
                HostName = _configuration["RabbitMQ:HostName"] ?? "localhost",
                UserName = _configuration["RabbitMQ:UserName"] ?? "guest",
                Password = _configuration["RabbitMQ:Password"] ?? "guest",
                RequestedHeartbeat = TimeSpan.FromSeconds(60),
                AutomaticRecoveryEnabled = true
            };

            int retryCount = 0;
            const int maxRetries = 5;
            while (retryCount < maxRetries)
            {
                try
                {
                    _connection = await factory.CreateConnectionAsync(cancellationToken);

                    _channelRegistration = await _connection.CreateChannelAsync(cancellationToken: cancellationToken);
                    await _channelRegistration.QueueDeclareAsync(queue: "user-registration",
                        durable: false, exclusive: false, autoDelete: false, arguments: null, cancellationToken: cancellationToken);

                    _channelPasswordReset = await _connection.CreateChannelAsync(cancellationToken: cancellationToken);
                    await _channelPasswordReset.QueueDeclareAsync(queue: "password-reset",
                        durable: false, exclusive: false, autoDelete: false, arguments: null, cancellationToken: cancellationToken);

                    _channelOrderStatusChanged = await _connection.CreateChannelAsync(cancellationToken: cancellationToken);
                    await _channelOrderStatusChanged.QueueDeclareAsync(queue: "order-status-changed",
                        durable: false, exclusive: false, autoDelete: false, arguments: null, cancellationToken: cancellationToken);

                    _logger.LogInformation("Connected to RabbitMQ successfully at localhost:5672!");
                    break;
                }
                catch (Exception ex)
                {
                    retryCount++;
                    if (retryCount == maxRetries)
                        throw;
                    _logger.LogWarning(ex, "Failed to connect to RabbitMQ. Attempt {RetryCount} of {MaxRetries}. Retrying in 5 seconds...", retryCount, maxRetries);
                    await Task.Delay(5000, cancellationToken);
                }
            }

            await base.StartAsync(cancellationToken);
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            var consumerRegistration = new AsyncEventingBasicConsumer(_channelRegistration!);
            consumerRegistration.ReceivedAsync += async (model, ea) =>
            {
                var body = ea.Body.ToArray();
                var message = Encoding.UTF8.GetString(body);
                _logger.LogInformation("Received message from RabbitMQ: {Message}", message);
                try { await SendEmailAsync(message); }
                catch (Exception ex) { _logger.LogError(ex, "Unhandled error processing user-registration message."); }
            };
            await _channelRegistration!.BasicConsumeAsync(queue: "user-registration",
                autoAck: true, consumer: consumerRegistration, cancellationToken: stoppingToken);

            var consumerPasswordReset = new AsyncEventingBasicConsumer(_channelPasswordReset!);
            consumerPasswordReset.ReceivedAsync += async (model, ea) =>
            {
                var body = ea.Body.ToArray();
                var message = Encoding.UTF8.GetString(body);
                _logger.LogInformation("Received password reset request from RabbitMQ: {Message}", message);
                try { await SendPasswordResetEmailAsync(message); }
                catch (Exception ex) { _logger.LogError(ex, "Unhandled error processing password-reset message."); }
            };
            await _channelPasswordReset!.BasicConsumeAsync(queue: "password-reset",
                autoAck: true, consumer: consumerPasswordReset, cancellationToken: stoppingToken);

            var consumerOrderStatusChanged = new AsyncEventingBasicConsumer(_channelOrderStatusChanged!);
            consumerOrderStatusChanged.ReceivedAsync += async (model, ea) =>
            {
                var body = ea.Body.ToArray();
                var message = Encoding.UTF8.GetString(body);
                _logger.LogInformation("Received order status change notification from RabbitMQ: {Message}", message);
                try { await SendOrderStatusChangedEmailAsync(message); }
                catch (Exception ex) { _logger.LogError(ex, "Unhandled error processing order-status-changed message."); }
            };
            await _channelOrderStatusChanged!.BasicConsumeAsync(queue: "order-status-changed",
                autoAck: true, consumer: consumerOrderStatusChanged, cancellationToken: stoppingToken);

            _logger.LogInformation("StoneCarveManager EmailService Worker is running and listening to queues...");
            _logger.LogInformation("   - user-registration");
            _logger.LogInformation("   - password-reset");
            _logger.LogInformation("   - order-status-changed");

            // Keep alive until cancellation
            await Task.Delay(Timeout.Infinite, stoppingToken);
        }

        private async Task SendEmailAsync(string message)
        {
            var user = JsonSerializer.Deserialize<UserRegistrationMessage>(message, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
            if (user == null || string.IsNullOrEmpty(user.Email))
            {
                _logger.LogError("Invalid message format.");
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
                    subject = "Welcome, StoneCarve Administrator!";
                    body = $@"
                <html>
                <body>
                    <h2>Hello, Admin {user.Name},</h2>
                    <p>Your administrator account in the StoneCarve Manager system has been successfully created.</p>
                    <p>You can now manage users, products and orders.</p>
                    <p><strong>Your username is: {user.Username}</strong></p>
                    <p><strong>Your login password is: {user.Password}</strong></p>
                    <p>For security reasons, please change your password after your first login.</p>
                    <p><strong>Your StoneCarve Manager Team</strong></p>
                </body>
                </html>";
                    break;

                case 2: // Employee
                    subject = "Welcome, StoneCarve Employee!";
                    body = $@"
                <html>
                <body>
                    <h2>Hello, {user.Name},</h2>
                    <p>Your employee account in the StoneCarve Manager system has been successfully created.</p>
                    <p>You can now manage orders and products.</p>
                    <p><strong>Your username is: {user.Username}</strong></p>
                    <p><strong>Your login password is: {user.Password}</strong></p>
                    <p>For security reasons, please change your password after your first login.</p>
                    <p><strong>Your StoneCarve Manager Team</strong></p>
                </body>
                </html>";
                    break;

                case 3: // Regular user
                    subject = "Welcome to StoneCarve Manager!";
                    body = $@"
                <html>
                <body>
                    <h2>Welcome to StoneCarve Manager, {user.Name}!</h2>
                    <p>We're glad you joined our community.</p>
                    <p>Your registration was successful and you now have access to our stone products.</p>
                    <p>Explore our offer and start ordering your favourite products!</p>
                    <p>See you soon,</p>
                    <p><strong>Your StoneCarve Manager Team</strong></p>
                </body>
                </html>";
                    break;

                default:
                    subject = "StoneCarve Manager Registration";
                    body = $@"
                <html>
                <body>
                    <h2>Welcome, {user.Name}!</h2>
                    <p>Your StoneCarve Manager account has been successfully created.</p>
                    <p><strong>Your StoneCarve Manager Team</strong></p>
                </body>
                </html>";
                    break;
            }

            emailMessage.Subject = subject;
            emailMessage.Body = new TextPart("html") { Text = body };

            await SendEmailViaSmtpAsync(emailMessage, user.Email);
        }

        // Method for sending password reset email with verification code
        private async Task SendPasswordResetEmailAsync(string message)
        {
            var resetRequest = JsonSerializer.Deserialize<PasswordResetMessage>(message, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
            if (resetRequest == null || string.IsNullOrEmpty(resetRequest.Email))
            {
                _logger.LogError("Invalid password reset message format.");
                return;
            }

            var emailMessage = new MimeMessage();
            emailMessage.From.Add(new MailboxAddress("StoneCarve Manager", "noreply@stonecarve.com"));
            emailMessage.To.Add(new MailboxAddress(resetRequest.Name, resetRequest.Email));
            emailMessage.Subject = "Password Reset - Verification Code";

            _logger.LogInformation("Sending verification code: {Code} to {Email}", resetRequest.VerificationCode, resetRequest.Email);

            // Calculate remaining time (1 hour from now)
            var expiresAt = DateTime.UtcNow.AddHours(1);
            var minutesRemaining = (int)(expiresAt - DateTime.UtcNow).TotalMinutes;

            var body = $@"
            <html>
            <body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>
                <div style='max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px;'>
                    <h2 style='color: #2c3e50;'>Password Reset</h2>
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
                        <p style='color: #856404; font-weight: bold; font-size: 16px; margin: 0;'>Code expires in {minutesRemaining} minutes</p>
                    </div>
                    
                    <div style='background-color: #e3f2fd; border-left: 4px solid #2196f3; padding: 15px; margin: 20px 0;'>
                        <p style='margin: 0; color: #1565c0;'>
                            <strong>How to use:</strong><br/>
                            1. Open the password reset page<br/>
                            2. Enter your email address<br/>
                            3. Copy and paste the code above<br/>
                            4. Set your new password
                        </p>
                    </div>
                    
                    <div style='background-color: #ffe6e6; border-left: 4px solid #ff4444; padding: 15px; margin: 20px 0;'>
                        <p style='margin: 0; color: #721c24;'>
                            If you didn't request a password reset, please ignore this email. 
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

        private async Task SendOrderStatusChangedEmailAsync(string message)
        {
            var notification = JsonSerializer.Deserialize<OrderStatusChangedMessage>(message, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
            if (notification == null || string.IsNullOrEmpty(notification.ClientEmail))
            {
                _logger.LogError("Invalid order status changed message format.");
                return;
            }

            var emailMessage = new MimeMessage();
            emailMessage.From.Add(new MailboxAddress("StoneCarve Manager", "noreply@stonecarve.com"));
            emailMessage.To.Add(new MailboxAddress(notification.ClientName, notification.ClientEmail));
            emailMessage.Subject = $"Order Update – {notification.OrderNumber}";

            var commentSection = string.IsNullOrWhiteSpace(notification.Comment)
                ? string.Empty
                : $@"
                    <div style='background-color: #e8f5e9; border-left: 4px solid #4caf50; padding: 15px; margin: 20px 0;'>
                        <p style='margin: 0; color: #1b5e20;'><strong>Message from our team:</strong><br/>{notification.Comment}</p>
                    </div>";

            var body = $@"
            <html>
            <body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>
                <div style='max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px;'>
                    <h2 style='color: #2c3e50;'>Order Status Update</h2>
                    <p>Hello <strong>{notification.ClientName}</strong>,</p>
                    <p>Your order <strong>{notification.OrderNumber}</strong> has been updated.</p>

                    <div style='text-align: center; margin: 30px 0;'>
                        <table style='width: 100%; border-collapse: collapse;'>
                            <tr>
                                <td style='text-align: center; padding: 15px; background-color: #f5f5f5; border-radius: 8px 0 0 8px;'>
                                    <p style='margin: 0; font-size: 12px; color: #777;'>Previous Status</p>
                                    <p style='margin: 5px 0 0 0; font-size: 18px; font-weight: bold; color: #888;'>{notification.OldStatus}</p>
                                </td>
                                <td style='text-align: center; padding: 15px; font-size: 24px; color: #4caf50;'>?</td>
                                <td style='text-align: center; padding: 15px; background-color: #e8f5e9; border-radius: 0 8px 8px 0;'>
                                    <p style='margin: 0; font-size: 12px; color: #777;'>New Status</p>
                                    <p style='margin: 5px 0 0 0; font-size: 18px; font-weight: bold; color: #2e7d32;'>{notification.NewStatus}</p>
                                </td>
                            </tr>
                        </table>
                    </div>

                    {commentSection}

                    <p style='color: #666; font-size: 14px;'>Updated on: {notification.ChangedAt:dd MMM yyyy, HH:mm} UTC</p>

                    <hr style='border: none; border-top: 1px solid #e0e0e0; margin: 30px 0;' />
                    <p style='margin-top: 30px; text-align: center; color: #7f8c8d; font-size: 12px;'>
                        <strong>Your StoneCarve Manager Team</strong><br/>
                        © 2026 StoneCarve Manager. All rights reserved.
                    </p>
                </div>
            </body>
            </html>";

            emailMessage.Body = new TextPart("html") { Text = body };

            await SendEmailViaSmtpAsync(emailMessage, notification.ClientEmail);
        }

        // Extracted method for SMTP sending (DRY principle)
        private async Task SendEmailViaSmtpAsync(MimeMessage emailMessage, string recipientEmail)
        {
            using var client = new SmtpClient();

            var smtpServer = _configuration["Email:SmtpServer"];
            var smtpPortStr = _configuration["Email:SmtpPort"];
            var emailUsername = _configuration["Email:Username"];
            var emailPassword = _configuration["Email:Password"];

            if (string.IsNullOrWhiteSpace(smtpServer) || string.IsNullOrWhiteSpace(smtpPortStr)
                || string.IsNullOrWhiteSpace(emailUsername))
            {
                _logger.LogError("SMTP configuration is missing. Email to {Email} was not sent.", recipientEmail);
                return;
            }

            if (!int.TryParse(smtpPortStr, out var smtpPort))
            {
                _logger.LogError("Invalid SMTP port value '{Port}'. Email to {Email} was not sent.", smtpPortStr, recipientEmail);
                return;
            }

            try
            {
                await client.ConnectAsync(smtpServer, smtpPort, MailKit.Security.SecureSocketOptions.StartTls);
                await client.AuthenticateAsync(emailUsername, emailPassword);
                await client.SendAsync(emailMessage);
                _logger.LogInformation("Email successfully sent to {Email}.", recipientEmail);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send email to {Email}.", recipientEmail);
            }
            finally
            {
                await client.DisconnectAsync(true);
            }
        }

        public override async Task StopAsync(CancellationToken cancellationToken)
        {
            if (_channelRegistration != null) await _channelRegistration.CloseAsync();
            if (_channelPasswordReset != null) await _channelPasswordReset.CloseAsync();
            if (_channelOrderStatusChanged != null) await _channelOrderStatusChanged.CloseAsync();
            if (_connection != null) await _connection.CloseAsync();
            _logger.LogInformation("StoneCarveManager EmailService Worker stopped.");
            await base.StopAsync(cancellationToken);
        }
    }
}
