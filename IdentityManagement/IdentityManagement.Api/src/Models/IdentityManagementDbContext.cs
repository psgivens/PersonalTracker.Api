using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace IdentityManagement.Api.Models {
    public class IdentityManagementDbContext : DbContext {
        public IdentityManagementDbContext (DbContextOptions<IdentityManagementDbContext> options) : base (options) { }
    
        public virtual DbSet<UserEventEnvelopeEntity> UserEvents { get; set; }
        public virtual DbSet<GroupEventEnvelopeEntity> GroupEvents { get; set; }
        public virtual DbSet<RoleEventEnvelopeEntity> RoleEvents { get; set; }

        public virtual DbSet<User> Users { get; set; }
        public virtual DbSet<Principal> Principals { get; set; }
        public virtual DbSet<Group> Groups { get; set; }
        public virtual DbSet<Role> Roles { get; set; }
    }
}