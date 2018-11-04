using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using IdentityServer4;

namespace IdServer
{
    public class Startup
    {
        // This method gets called by the runtime. Use this method to add services to the container.
        // For more information on how to configure your application, visit https://go.microsoft.com/fwlink/?LinkID=398940
        public void ConfigureServices(IServiceCollection services)
        {
            // Microsoft.IdentityModel.Logging.IdentityModelEventSource.ShowPII = true; //To show detail of error and see the problem
            services.AddIdentityServer(opt => opt.IssuerUri = "http://pomodoro-idserver")
                .AddDeveloperSigningCredential()
                .AddInMemoryApiResources(Configuration.GetApiResources())
                .AddInMemoryClients(Configuration.GetClients());

            // services.AddAntiforgery(
            //     options =>
            //     {
            //         options.Cookie.Name = "_af";
            //         options.Cookie.HttpOnly = true;
            //         options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
            //         options.HeaderName = "X-XSRF-TOKEN";
            //     }
            // );                
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
