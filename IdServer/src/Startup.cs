using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using IdentityServer4;
using IdServer.Models;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace IdServer
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            // TlsHack.Hack();
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        [System.Diagnostics.Conditional("DEBUG")]
        private static void WaitForDebugger(){
            System.Console.WriteLine("Waiting for debugger to attach.");
            while(!System.Diagnostics.Debugger.IsAttached) {
                System.Console.Write(".");
                System.Threading.Thread.Sleep(TimeSpan.FromSeconds(3));                
            }
            System.Console.WriteLine("\nDebugger attached!");
            System.Diagnostics.Debugger.Break();
        }

        // This method gets called by the runtime. Use this method to add services to the container.
        // For more information on how to configure your application, visit https://go.microsoft.com/fwlink/?LinkID=398940
        public void ConfigureServices(IServiceCollection services)
        {
            // WaitForDebugger ();
            
            services.AddScoped<IUserRepository, UserRepository>();
            var idServerSettings = Configuration.GetSection("idServerSettings");
            string issuerUri = idServerSettings.GetValue<string>("IssuerUri");

            // Microsoft.IdentityModel.Logging.IdentityModelEventSource.ShowPII = true; //To show detail of error and see the problem
            services.AddIdentityServer(opt => opt.IssuerUri = issuerUri)
                .AddDeveloperSigningCredential()
                .AddInMemoryApiResources(IdServer.Configuration.GetApiResources())
                .AddInMemoryClients(IdServer.Configuration.GetClients())
                .AddProfileService<ProfileService>()
                .AddResourceOwnerValidator<ResourceOwnerPasswordValidator>()
                ;


            // services.AddAntiforgery(
            //     options =>
            //     {
            //         options.Cookie.Name = "_af";
            //         options.Cookie.HttpOnly = true;
            //         options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
            //         options.HeaderName = "X-XSRF-TOKEN";
            //     }
            // );                

            var dbContextSettings = Configuration.GetSection("IdServerDbContextSettings");
            string connectionString = dbContextSettings.GetValue<string>("ConnectionString");
            services.AddDbContext<IdServerDbContext>(
                opts => opts.UseNpgsql(connectionString)
            );

        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            app.UseIdentityServer();
            app.UseCors(builder 
                => builder
                    .AllowAnyOrigin()
                    .AllowAnyHeader()
                    .AllowAnyMethod()
                    .AllowCredentials());

            app.Run(async (context) =>
            {
                await context.Response.WriteAsync("Hello World!");
            });
        }
    }
}
