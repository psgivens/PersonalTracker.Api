using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.HttpsPolicy;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace Ping.Api
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            TlsHack.Hack();
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            var config = new ConfigurationBuilder()
                .SetBasePath(System.IO.Directory.GetCurrentDirectory())
                .AddEnvironmentVariables()
                .AddJsonFile("config/idServerSettings.json", optional: true, reloadOnChange: true)
                .AddJsonFile($"idServerSettings.{Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT")}.json", optional: true, reloadOnChange: true)
                .Build();

            var idServerSettings = config.GetSection("idServerSettings");
            string issuerUri = idServerSettings.GetValue<string>("IssuerUri");
            string idServerAuthority = idServerSettings.GetValue<string>("Authority");

            services.AddSingleton<IConfiguration>(Configuration);

            services.AddCors();

            services.AddMvc().SetCompatibilityVersion(CompatibilityVersion.Version_2_1);

            var connectionString = Configuration["PingDbContextSettings:ConnectionString"];
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseHsts();
            }

            app.UseHttpsRedirection();

            app.UseCors(builder
                => builder
                    .AllowAnyHeader()
                    .AllowAnyMethod()
                    .WithOrigins("https://localhost,https://localhost:2001"));

            app.UseMvc();
        }
    }
}
