using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IdentityManagement.Api.Models
{
    public class EventStream
    {
        [Column(Order = 0), Key]
        public virtual long Id { get; set; }
        public virtual DateTimeOffset Created { get; set; }
    }
    public abstract class EnvelopeEntityBase
    {
        [Column(Order = 0), Key]
        public virtual long StreamId { get; set; }
        public virtual EventStream Stream { get; set; }
        [Column(Order = 1), Key]
        public virtual string UserId { get; set; }
        [Column(Order = 2), Key]
        public virtual Guid Id { get; set; }

        public virtual Guid TransactionId { get; set; }
        public virtual string DeviceId { get; set; }
        public virtual long Version { get; set; }
        public virtual DateTimeOffset TimeStamp { get; set; }
        public virtual string Event { get; set; }
    }
    public class UserEventEnvelopeEntity : EnvelopeEntityBase { }
    public class GroupEventEnvelopeEntity : EnvelopeEntityBase { }
    public class RoleEventEnvelopeEntity : EnvelopeEntityBase { }
}
