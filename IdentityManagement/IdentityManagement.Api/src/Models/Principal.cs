using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace IdentityManagement.Api.Models {
    public class Principal {
        [Key]
        public virtual long Id { get; set; }
        public virtual IList<Group> Groups { get; set; }
    }

    public class User : Principal {
        [Key]
        public virtual string FirstName { get; set; }
        public virtual string LastName { get; set; }
    }

    public class Group : Principal {
        public virtual string Name { get; set; }
        public virtual IList<Principal> Members { get; set; }
    }

    public class Role {
        [Key]
        public virtual long Id { get; set; }
        public virtual string Name { get; set; }
        public virtual IList<Principal> Members { get; set; }
    }
}