using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using IdentityManagement.Api.Handlers;
using IdentityManagement.Api.Models;
using Newtonsoft.Json;

namespace IdentityManagement.Api.Data {
    public class UsersRepository {
        private readonly IdentityManagementDbContext _context;

        public UsersRepository (IdentityManagementDbContext context) {
            _context = context;
        }

        public User AddUser(UserState state){
            var user = new User {
                FirstName = state.FirstName,
                LastName = state.LastName
            };
            try {
                _context.Users.Add (user);
                _context.SaveChanges ();
                return user;
            } catch {
                Console.WriteLine ("error");
                throw;
            }
        }

        public async Task<User> GetUser(long id){
            return await _context.Users.FindAsync(id);
        }

        public async Task<User> UpdateUser(long id, UserState state) {

            var user = await GetUser(id);

            try
            {
                // Query builder
                user.FirstName = state.FirstName;
                user.LastName = state.LastName;
                // TODO: foreach group add group
                _context.SaveChanges();
                return user;
            }
            catch
            {
                Console.WriteLine("error");
                throw;
            }

        }
    }
}