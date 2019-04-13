using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace IdentityManagement.Api.Models
{
    public class PersonEntity
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
        public virtual PersonEntity Member { get; set; }
        public virtual long GroupId { get; set; }
        public virtual GroupEntity Group { get; set; }
    }

}