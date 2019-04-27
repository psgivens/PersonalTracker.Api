using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace PrivilegeManagement.Api.Models {
    public class DataConstraint {
        [Key]
        public virtual long Id { get; set; }
        public virtual string Name { get; set; }

        // Use the URI to describe tenants, locations, etc.
        // TODO: Create system which maps dynamic uri bits with tenatns, locations, etc. 
        public virtual string Rule { get; set; }

        // Use the tenants, locations, etc. to look up the correct groups
        // TODO: Map groups to tenants, locations, etc. 
        public virtual string GroupPath { get; set; }
    }

    public class Endpoint {
        [Key]
        public virtual long Id { get; set; }
        public virtual string Uri { get; set; }
        public virtual string Method { get; set; }
        public virtual IList<Privilege> Privileges { get; set; }
        public virtual IList<DataConstraint> DataConstraints { get; set; }
    }

    public class Privilege {
        [Key]
        public virtual long Id { get; set; }
        public virtual string Name { get; set; }
        public virtual IList<Endpoint> Endpoints { get; set; }
        public virtual IList<Role> Roles { get; set; }
    }

    public class Role {
        [Key]
        public virtual long Id { get; set; }
        public virtual string Name { get; set; }
        public virtual IList<Privilege> Privileges { get; set; }
    }

}