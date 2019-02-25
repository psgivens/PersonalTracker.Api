using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Security.Cryptography.X509Certificates;
using System.Threading.Tasks;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace IdServer
{
    public class Program
    {
        
        [System.Diagnostics.Conditional("DEBUG")]
        private static void WaitForDebugger(){
            System.Console.WriteLine("Waiting for debugger to attach.");
            while(!System.Diagnostics.Debugger.IsAttached) {
                System.Console.Write(".");
                System.Threading.Thread.Sleep(TimeSpan.FromSeconds(3));                
            }
            System.Console.WriteLine("\nDebugger attached!");
        }

        public static void Main (string[] args){            
            // WaitForDebugger();
            RunWeb(args);
        }

        public static void RunWeb(string[] args)
        {
            // CreateWebHostBuilder(args).Build().Run();

            var host = BuildWebHost(args);

            host.Run();
        }            
        public static IWebHost BuildWebHost(string[] args) {
            var config = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddEnvironmentVariables()
                .AddJsonFile("secrets/certificate.json", optional: true, reloadOnChange: true)
                // .AddJsonFile($"certificate.{Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT")}.json", optional: true, reloadOnChange: true)
                .AddJsonFile("config/idServerSettings.json", optional: true, reloadOnChange: true)
                .AddJsonFile("config/dbContextSettings.json", optional: false, reloadOnChange: false)
                .AddJsonFile($"idServerSettings.{Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT")}.json", optional: true, reloadOnChange: true)
                .Build();

            /* Begin ** Not used yet. Do not delete until we know if we will.  */
            var certificateSettings = config.GetSection("certificateSettings");
            string certificateFileName = certificateSettings.GetValue<string>("filename");
            string certificatePassword = certificateSettings.GetValue<string>("password");

            var certificate = new X509Certificate2(certificateFileName, certificatePassword);

            /* End ** Not used yet. Do not delete until we know if we will.  */

            return WebHost.CreateDefaultBuilder(args)
                .UseKestrel(
                    options =>
                    {
                        options.AddServerHeader = false;
                        options.Listen(IPAddress.Any, 80, listenOptions =>
                        {
                            // listenOptions.UseHttps(certificate);
                        });
                        options.Listen(IPAddress.Any, 443, listenOptions =>
                        {
                            listenOptions.UseHttps(certificate);
                        });
                    }
                )
                .UseConfiguration(config)
                // .UseContentRoot(Directory.GetCurrentDirectory())
                .UseStartup<Startup>()
                //https://stackoverflow.com/questions/46621788/how-to-use-https-ssl-with-kestrel-in-asp-net-core-2-x
                .UseUrls("http://localhost;https://localhost;http://pomodoro-idserver;https://pomodoro-idserver")
                .Build();
        }

    }
}
