using StoneCarveManager.EmailService;
using DotNetEnv;

public class Program
{
    public static async Task Main(string[] args)
    {
        // ? Load .env file for email credentials (optional)
        try
        {
            Env.Load(@"../.env");
        }
        catch
        {
            Console.WriteLine("?? .env file not found, using appsettings.json or environment variables");
        }

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
            })
            .Build();

        Console.WriteLine("?? StoneCarveManager EmailService is starting...");
        await host.RunAsync();
    }
}
