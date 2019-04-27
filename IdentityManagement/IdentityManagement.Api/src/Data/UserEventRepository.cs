using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using IdentityManagement.Api.Handlers;
using IdentityManagement.Api.Models;
using Newtonsoft.Json;

namespace IdentityManagement.Api.Data
{
    public class UsersEventRepository
    {
        private readonly IdentityManagementDbContext _context;

        public UsersEventRepository(IdentityManagementDbContext context)
        {
            _context = context;
        }

        public long CreateStream(string userId, Guid transactionId, UserEvent evt)
        {
            var stream = new EventStream();
            _context.UserEvents.Add(new UserEventEnvelopeEntity
            {
                Id = Guid.NewGuid(),
                Stream = stream,
                UserId = userId,
                TransactionId = transactionId,
                Version = 0,
                TimeStamp = DateTimeOffset.Now,
                Event = JsonConvert.SerializeObject(evt)
            });
            _context.SaveChanges();
            return stream.Id;
        }

        public void AppendEvent(string userId, long streamId, Guid transactionId, long version, UserEvent evt)
        {
            _context.UserEvents.Add(new UserEventEnvelopeEntity
            {
                Id = Guid.NewGuid(),
                StreamId = streamId,
                UserId = userId,
                TransactionId = transactionId,
                Version = version,
                TimeStamp = DateTimeOffset.Now,
                Event = JsonConvert.SerializeObject(evt)
            });
            _context.SaveChanges();
        }

        public IQueryable<Envelope<UserEvent>> GetEvents(long streamId)
        {
            return from @event in _context.UserEvents
                   where @event.StreamId == streamId
                   orderby @event.Version
                   select new Envelope<UserEvent>
                   {
                       Id = @event.Id,
                       UserId = @event.UserId,
                       StreamId = @event.StreamId,
                       TransactionId = @event.TransactionId,
                       Version = @event.Version,
                       Created = @event.TimeStamp,
                       Item = JsonConvert.DeserializeObject<UserEvent>(@event.Event)
                   };
        }
    }
}