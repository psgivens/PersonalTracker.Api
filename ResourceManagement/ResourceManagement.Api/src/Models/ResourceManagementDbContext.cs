using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using ResourceManagement.Api.Models;

namespace ResourceManagement.Api.Models
{
    public class ResourceManagementDbContext : DbContext
    {
        public ResourceManagementDbContext(DbContextOptions<ResourceManagementDbContext> options)
            : base(options) { }
        public virtual DbSet<PomodoroEntryModel> PomodoroEntries { get; set; }
    }
}