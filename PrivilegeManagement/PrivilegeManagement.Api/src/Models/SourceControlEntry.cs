using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace PrivilegeManagement.Api.Models {
    public class SourceControlEntry {
        [Key]
        public virtual long Id { get; set; }
        public virtual string Repository { get; set; }
        public virtual string Path { get; set; }
        public virtual string Hash { get; set; }
        public virtual DateTime Modified { get; set; }
        public virtual string Text { get; set; }
        public virtual bool IsValid { get; set; }
    }
}