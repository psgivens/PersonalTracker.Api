using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Linq;
using Pomodoro.Api.Models;
using System.Threading.Tasks;
using System;

namespace Pomodoro.Api.Controllers
{
    [Route("api/[controller]")]
    public class GroupsController : ControllerBase
    {
        private readonly PomodoroDbContext _context;

        public GroupsController (PomodoroDbContext context)
        {
            _context = context;

            if (_context.Groups.Count() == 0)
            {
                _context.Groups.Add(new GroupEntity {
                    Name = "Security Council"
                });

                _context.SaveChanges();
            }
        }    

        [HttpGet]
        public List<GroupEntity> GetAll()
        {
            return _context.Groups.ToList();
        }

        [HttpGet("{id}", Name = "GetGroup")]
        public  async Task<ActionResult>  GetByIdAsync(long id)
        {
            var item = await _context.Groups.FindAsync(id);
            if (item == null)
            {
                return NotFound();
            }
            return Ok(item);
        }   


        [HttpPost]
        
        public IActionResult Create([FromBody]GroupDto model)
        {                  
            var entry = new GroupEntity{
                Name = model.Name
            };
            try{      
                _context.Groups.Add(entry);
                _context.SaveChanges();
                return CreatedAtRoute("GetGroup", new { id = entry.Id }, entry);
            } catch {
                Console.WriteLine("error");
                throw;
            }
        }
    }
    public class GroupDto {        
        public string Name { get; set; }
    }

}