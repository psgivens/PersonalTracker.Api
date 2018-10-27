using Microsoft.EntityFrameworkCore;
using Pomodoro.Api.Models;

namespace Pomodoro.Api.Models {
    public class PomodoroDbContext : DbContext {
        public PomodoroDbContext(DbContextOptions<PomodoroDbContext> options)
            : base (options) { }
        public virtual DbSet<PomodoroEntryModel> PomodoroEntries { get; set; }
    }
}