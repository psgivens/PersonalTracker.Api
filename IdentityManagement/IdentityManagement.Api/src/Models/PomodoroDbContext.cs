using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace IdentityManagement.Api.Models
{
    public class IdentityManagementDbContext : DbContext
    {
        public IdentityManagementDbContext(DbContextOptions<IdentityManagementDbContext> options)
            : base(options) { }
        public virtual DbSet<PersonEntity> People { get; set; }
        public virtual DbSet<GroupEntity> Groups { get; set; }
    }
}