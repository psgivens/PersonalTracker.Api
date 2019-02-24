

using System.Threading.Tasks;
using IdServer.Models;


// https://stackoverflow.com/questions/35304038/identityserver4-register-userservice-and-get-users-from-database-in-asp-net-core
namespace IdServer.Models {
    public interface IUserRepository
    {
        Task<User> FindAsync(string userName);
        Task<User> FindAsync(long userId);
    }
}