using System;

namespace IdentityManagement.Api.Handlers {
    public class Envelope<T> {
        public Guid Id { get; set; }
        public string UserId { get; set; }
        public long StreamId { get; set; }
        public Guid TransactionId { get; set; }
        public long Version { get; set; }
        public DateTimeOffset Created { get; set; }
        public T Item { get; set; }
    }
}
