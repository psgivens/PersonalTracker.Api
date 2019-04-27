using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using IdentityManagement.Api.Data;
using IdentityManagement.Api.Handlers;
using IdentityManagement.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace IdentityManagement.Api.Controllers
{
    [Route("api/[controller]")]
    [Authorize]
    public class UsersController : ControllerBase
    {
        private readonly IdentityManagementDbContext _context;
        private readonly UserHandler _handler;
        private readonly UsersRepository _repository;
        private readonly UsersEventRepository _events;

        public UsersController(IdentityManagementDbContext context)
        {
            _context = context;
            _handler = new UserHandler(_context);
            _repository = new UsersRepository(_context);
            _events = new UsersEventRepository(_context);

            if (_context.Users.Count() == 0)
            {
                _context.Users.Add(new User
                {
                    FirstName = "Fred",
                    LastName = "Flintstone"
                });

                _context.SaveChanges();
            }
        }

        [HttpGet]
        public List<User> GetAll()
        {
            return _context.Users.ToList();
        }

        [HttpGet("{id}", Name = "GetUser")]
        public async Task<ActionResult> GetByIdAsync(long id)
        {
            var item = await _repository.GetUser(id);
            if (item == null)
            {
                return NotFound();
            }
            return Ok(item);
        }

        [HttpPost]
        public IActionResult Create([FromBody] UserDto model)
        {
            var cmd = new CreateUserCommand { User = model };
            var events = _handler.Handle(null, cmd);
            var streamId = _events.CreateStream("sample_user_123", Guid.NewGuid(), events.Single().Item2);
            var (_, state) = _handler.GetUser(streamId);
            var user = _repository.AddUser(state);
            return CreatedAtRoute("GetUser", new { id = user.Id }, user);
        }

        [HttpPut("{id}", Name = "UpdateUser")]
        public async Task<ActionResult> Update(long id, [FromBody] UserDto model)
        {
            var user = await _repository.GetUser(id);
            if (user == null)
            {
                return NotFound();
            }

            try
            {
                var events = _handler.Handle(user.Id, new UpdateUserCommand { User = model });
                foreach (var (ver, evt) in events)
                {
                    _events.AppendEvent("sample_user_123", id, Guid.NewGuid(), ver, evt);
                }
                var (_, state) = _handler.GetUser(id);

                user = await _repository.UpdateUser(id, state);
                return CreatedAtRoute("GetUser", new { id = user.Id }, user);
            }
            catch
            {
                Console.WriteLine("error");
                throw;
            }
        }

    }
    public class UserDto
    {
        public string FirstName { get; set; }
        public string LastName { get; set; }
    }

}