using System.Collections.Generic;
using IdServer.Models;
using Microsoft.EntityFrameworkCore;


namespace IdServer.Models
{
    public class IdServerDbContext : DbContext
    {
        public IdServerDbContext(DbContextOptions<IdServerDbContext> options)
            : base(options) { }

        protected override void OnModelCreating(ModelBuilder modelBuilder){
            modelBuilder.Entity<User>().HasData(new User {                
                Password = "password123",
                UserId = "123",
                Lastname = "shmoe",
                Firstname = "joe",
                Email = "js@moe",
                Role = "peasant" 
                });
        }

        public bool IsActive { get; internal set; }

        public virtual DbSet<User> Users { get; set; }
    }
}