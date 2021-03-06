﻿using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
using System.Threading.Tasks;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace Ping.Api
{
    public class Program
    {
        public static void Main(string[] args)
        {            
            WebHost.CreateDefaultBuilder(args)
                .UseStartup<Startup>()
                .Build().Run();
        }
    }
}
