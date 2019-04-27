using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using PrivilegeManagement.Api.Models;

namespace PrivilegeManagement.Api.Models {
    public class PrivilegeManagementDbContext : DbContext {
        public PrivilegeManagementDbContext (DbContextOptions<PrivilegeManagementDbContext> options) : base (options) { }
        public virtual DbSet<Privilege> Privileges { get; set; }
        public virtual DbSet<Endpoint> Endpoints { get; set; }
        public virtual DbSet<Role> Roles { get; set; }
    }
}