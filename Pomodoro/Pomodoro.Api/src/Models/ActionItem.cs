using System;
using System.ComponentModel.DataAnnotations;

namespace Pomodoro.Api.Models {
    public class ActionItemModel {
        [Key]
        public virtual long Id {get;set;}
        public virtual string UserId { get; set; }
        public virtual DateTime? DueDate { get; set; }        
        public virtual DateTime Modified {get; set;}
        public virtual DateTime? CompletionDate { get; set; }
        public virtual string Description { get; set; }
        public virtual string Tags { get; set; }
        public virtual ActionItemState State { get; set; }
    }
    public enum ActionItemState {
        NotStarted = 1,
        InProgress = 2,
        Paused = 3,
        Blocked = 4,
        Complete = 5
    }    
}