using System;
using System.ComponentModel.DataAnnotations;

namespace ResourceManagement.Api.Models {
    public class PomodoroEntryModel {
        [Key]
        public virtual long Id {get;set;}
        public virtual string UserId { get; set; }
        public virtual DateTime StartTime { get; set; }        
        public virtual DateTime Modified {get; set;}
        public virtual string Planned { get; set; }
        public virtual string Actual {get; set;}
        public virtual int Elapsed { get; set; }
        public virtual string Tags { get; set; }
        public virtual PomodoroState State { get; set; }
    }
    public enum PomodoroState {
        NotStarted = 1,
        Running = 2,
        Distracted = 3,
        Interrupted = 4,
        Complete = 5
    }
    
}