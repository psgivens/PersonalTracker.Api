using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace ResourceManagement.Api.Models {
    public class Resource {
        [Key]
        public virtual long Id { get; set; }
        public virtual string Name { get; set; }
        public virtual long ScopeId { get; set; }
        public virtual Scope Scope { get; set; }
    }
    public class Scope {
        [Key]
        public virtual long Id { get; set; }
        public virtual string Name { get; set; }
        public virtual IList<Client> Clients { get; set; }
    }
    public class Client {
        [Key]
        public virtual long Id { get; set; }
        public virtual string Name { get; set; }
        public virtual IList<Scope> Scopes { get; set; }
    }
}