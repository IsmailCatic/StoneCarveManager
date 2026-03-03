using StoneCarveManager.EmailService;
using DotNetEnv;

public class Program
{
    public static async Task Main(string[] args)
    {
        // Load .env file
        try
        {
            var envPath = Path.Combine(Directory.GetCurrentDirectory(), ".env");
            if (!File.Exists(envPath))
                envPath = Path.Combine(Directory.GetCurrentDirectory(), "..", ".env");

            if (File.Exists(envPath))
            {
                Env.Load(envPath);
                Console.WriteLine($"? Loaded .env from {envPath}");
            }
            else
            {
                Console.WriteLine("?? .env file not found, using appsettings.json or environment variables");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"?? Failed to load .env: {ex.Message}");
        }

        // Map flat .env keys to ASP.NET Core hierarchical config
        var envOverrides = new Dictionary<string, string?>();

        void MapEnv(string envKey, string configKey)
        {
            var value = Environment.GetEnvironmentVariable(envKey);
            if (!string.IsNullOrEmpty(value))
                envOverrides[configKey] = value;
        }

        MapEnv("EMAIL_SMTP_SERVER", "Email:SmtpServer");
        MapEnv("EMAIL_SMTP_PORT", "Email:SmtpPort");
        MapEnv("EMAIL_USERNAME", "Email:Username");
        MapEnv("EMAIL_PASSWORD", "Email:Password");
        MapEnv("RABBITMQ_USER", "RabbitMQ:UserName");
        MapEnv("RABBITMQ_PASSWORD", "RabbitMQ:Password");

        if (envOverrides.Count > 0)
            Console.WriteLine($"? Mapped {envOverrides.Count} values from .env into configuration");

        IHost host = Host.CreateDefaultBuilder(args)
            .ConfigureServices((context, services) =>
            {
                services.AddHostedService<Worker>();
            })
            .ConfigureAppConfiguration((hostContext, config) =>
            {
                config.SetBasePath(Directory.GetCurrentDirectory());
                config.AddJsonFile("appsettings.json", optional: false);
                config.AddJsonFile($"appsettings.{hostContext.HostingEnvironment.EnvironmentName}.json", optional: true);
                config.AddEnvironmentVariables();
                config.AddInMemoryCollection(envOverrides);
            })
            .Build();

        Console.WriteLine("?? StoneCarveManager EmailService is starting...");
        await host.RunAsync();
    }
}
