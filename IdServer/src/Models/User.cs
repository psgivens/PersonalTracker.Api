using System.Security.Claims;

namespace IdServer.Models
{
    public class User
    {
        public string Password { get; internal set; }
        public string UserId { get; internal set; }
        public string Lastname { get; internal set; }
        public string Firstname { get; internal set; }
        public string Email { get; internal set; }
        public string Role { get; internal set; }
        public bool IsActive { get; internal set; }
    }
}