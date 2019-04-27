using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using ResourceManagement.Api.Models;

namespace ResourceManagement.Api.Models {
    public class ResourceManagementDbContext : DbContext {
        public ResourceManagementDbContext (DbContextOptions<ResourceManagementDbContext> options) : base (options) { }
        public virtual DbSet<Resource> Resources { get; set; }
        public virtual DbSet<Client> Clients { get; set; }
        public virtual DbSet<Scope> Scopes { get; set; }
    }
}