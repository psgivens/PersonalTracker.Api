using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using IdentityManagement.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace IdentityManagement.Api.Controllers {
    [Route ("api/[controller]")]
    public class GroupsController : ControllerBase {
        private readonly IdentityManagementDbContext _context;

        public GroupsController (IdentityManagementDbContext context) {
            _context = context;

            if (_context.Groups.Count () == 0) {
                _context.Groups.Add (new Group {
                    Name = "Security Council"
                });

                _context.SaveChanges ();
            }
        }

        [HttpGet]
        public List<Group> GetAll () {
            return _context.Groups.ToList ();
        }

        [HttpGet ("{id}", Name = "GetGroup")]
        public async Task<ActionResult> GetByIdAsync (long id) {
            var item = await _context.Groups.FindAsync (id);
            if (item == null) {
                return NotFound ();
            }
            return Ok (item);
        }

        [HttpPost]

        public IActionResult Create ([FromBody] GroupDto model) {
            var entry = new Group {
                Name = model.Name
            };
            try {
                _context.Groups.Add (entry);
                _context.SaveChanges ();
                return CreatedAtRoute ("GetGroup", new { id = entry.Id }, entry);
            } catch {
                Console.WriteLine ("error");
                throw;
            }
        }
    }
    public class GroupDto {
        public string Name { get; set; }
    }

}