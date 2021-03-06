﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.HttpsPolicy;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Pomodoro.Api.Models;
using IdentityServer4;
using IdentityServer4.AccessTokenValidation;

namespace Pomodoro.Api
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
                .AddJsonFile($"config/idServerSettings.{Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT")}.json", optional: true, reloadOnChange: true)
                .Build();

            var idServerSettings = config.GetSection("idServerSettings");
            string issuerUri = idServerSettings.GetValue<string>("IssuerUri");
            string idServerAuthority = idServerSettings.GetValue<string>("Authority");

            services.AddSingleton<IConfiguration>(Configuration);

            // Microsoft.IdentityModel.Logging.IdentityModelEventSource.ShowPII = true; //To show detail of error and see the problem
            services.AddIdentityServer(opt => opt.IssuerUri = issuerUri);

            services.AddAuthentication(opt =>
                {
                    opt.DefaultScheme = IdentityServerAuthenticationDefaults.AuthenticationScheme;
                    opt.DefaultAuthenticateScheme = IdentityServerAuthenticationDefaults.AuthenticationScheme;
                })
                .AddIdentityServerAuthentication(opt =>
                {
                    opt.Authority = idServerAuthority;
                    opt.RequireHttpsMetadata = false;
                    opt.ApiName = "api1";
                });

            services.AddCors();

            services.AddMvc().SetCompatibilityVersion(CompatibilityVersion.Version_2_1);

            var connectionString = Configuration["PomodoroDbContextSettings:ConnectionString"];
            services.AddDbContext<PomodoroDbContext>(
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
            else
            {
                app.UseHsts();
            }

            app.UseHttpsRedirection();

            app.UseAuthentication();

            app.UseCors(builder
                => builder
                    .AllowAnyHeader()
                    .AllowAnyMethod()
                    .WithOrigins("https://localhost,https://localhost:2001,https://localhost:2001"));

            app.UseMvc();
        }
    }
}
