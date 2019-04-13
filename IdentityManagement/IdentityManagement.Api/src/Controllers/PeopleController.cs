using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Linq;
using IdentityManagement.Api.Models;
using System.Threading.Tasks;
using System;

namespace IdentityManagement.Api.Controllers
{
    [Route("api/[controller]")]
    [Authorize]
    public class PeopleController : ControllerBase
    {
        private readonly IdentityManagementDbContext _context;

        public PeopleController(IdentityManagementDbContext context)
        {
            _context = context;

            if (_context.People.Count() == 0)
            {
                _context.People.Add(new PersonEntity
                {
                    FirstName = "Fred",
                    LastName = "Flintstone"
                });

                _context.SaveChanges();
            }
        }

        [HttpGet]
        public List<PersonEntity> GetAll()
        {
            return _context.People.ToList();
        }

        [HttpGet("{id}", Name = "GetPerson")]
        public async Task<ActionResult> GetByIdAsync(long id)
        {
            var item = await _context.People.FindAsync(id);
            if (item == null)
            {
                return NotFound();
            }
            return Ok(item);
        }


        [HttpPost]

        public IActionResult Create([FromBody]PersonDto model)
        {
            var entry = new PersonEntity
            {
                FirstName = model.FirstName,
                LastName = model.LastName
            };
            try
            {
                _context.People.Add(entry);
                _context.SaveChanges();
                return CreatedAtRoute("GetPerson", new { id = entry.Id }, entry);
            }
            catch
            {
                Console.WriteLine("error");
                throw;
            }
        }
    }
    public class PersonDto
    {
        public string FirstName { get; set; }
        public string LastName { get; set; }
    }

}