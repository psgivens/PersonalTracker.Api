using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using PrivilegeManagement.Api.Models;

namespace PrivilegeManagement.Api.Models
{
    public class PrivilegeManagementDbContext : DbContext
    {
        public PrivilegeManagementDbContext(DbContextOptions<PrivilegeManagementDbContext> options)
            : base(options) { }
        public virtual DbSet<PrivilegeModel> PrivilegeModels { get; set; }
    }
}