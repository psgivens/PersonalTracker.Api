using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using Pomodoro.Api.Models;

namespace Pomodoro.Api.Models
{
    public class PomodoroDbContext : DbContext
    {
        public PomodoroDbContext(DbContextOptions<PomodoroDbContext> options)
            : base(options) { }
        public virtual DbSet<PomodoroEntryModel> PomodoroEntries { get; set; }
        public virtual DbSet<PersonEntity> People { get; set; }
        public virtual DbSet<GroupEntity> Groups { get; set; }
        public virtual DbSet<ActionItemModel> ActionItems { get; set; }
    }
}