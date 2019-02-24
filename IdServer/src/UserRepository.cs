

using System.Threading.Tasks;
using IdServer.Models;
using System.Linq;
using Microsoft.EntityFrameworkCore;

namespace IdServer {
    public class UserRepository : IUserRepository
    {
        private readonly IdServerDbContext _dbContext;

        public UserRepository(IdServerDbContext dbContext){
            this._dbContext = dbContext;
        }

        public async Task<User> FindAsync(string userName)
        {
            return await _dbContext.Users.FirstAsync();
        }

        public async Task<User> FindAsync(long userId)
        {
            return await _dbContext.Users.FirstAsync();
        }
    }
}