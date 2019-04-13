using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace PrivilegeManagement.Api.Models
{
    public class PrivilegeModel
    {
        [Key]
        public virtual long Id { get; set; }
        public virtual string FirstName { get; set; }
        public virtual string LastName { get; set; }
        public virtual IList<PersonGroupRelation> GroupRelations { get; set; }
    }

    public class GroupEntity
    {
        [Key]
        public virtual long Id { get; set; }
        public virtual string Name { get; set; }
        public virtual IList<PersonGroupRelation> MemberRelations { get; set; }
    }

    public class PersonGroupRelation
    {
        [Key]
        public virtual long Id { get; set; }
        public virtual long MemberId { get; set; }
        public virtual PrivilegeModel Member { get; set; }
        public virtual long GroupId { get; set; }
        public virtual GroupEntity Group { get; set; }
    }

}