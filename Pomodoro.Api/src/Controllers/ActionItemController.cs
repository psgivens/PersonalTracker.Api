using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Pomodoro.Api.Models;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System;

namespace Pomodoro.Api.Controllers
{
    [Route("api/[controller]")]

    public class ActionItemsController : ControllerBase
    {
        private readonly PomodoroDbContext _context;

        public ActionItemsController(PomodoroDbContext context)
        {
            _context = context;

            if (_context.ActionItems.Count() == 0)
            {
                _context.ActionItems.Add(new ActionItemModel
                {
                    UserId = System.Guid.NewGuid().ToString(),
                    // DueDate = System.DateTime.Now,
                    // Modified = System.DateTime.Now,
                    Description = "Sample activity"
                    // Tags = "",
                    // State = ActionItemState.NotStarted
                });

                _context.SaveChanges();
            }
        }

        [HttpGet]
        public List<ActionItemModel> GetAll()
        {
            // return Enumerable
            //     .Empty<ActionItemModel>()
            //     .ToList();// _context.ActionItems.ToList();
            return _context.ActionItems.ToList();
        }

        [HttpGet("{id}", Name = "GetActionItem")]
        public async Task<ActionResult> GetByIdAsync(long id)
        {
            var item = await _context.ActionItems.FindAsync(id);
            if (item == null)
            {
                return NotFound();
            }
            return Ok(item);
        }

        [HttpPost]
        public IActionResult Create([FromBody]ActionItemDto dto)
        {
            DateTime tempdt;
            var entry = new ActionItemModel
            {
                UserId = dto.UserId,
                DueDate = DateTime.TryParse(dto.DueDate, out tempdt) ? (DateTime?)tempdt : null,
                Modified = DateTime.Now,
                Description = dto.Description,
                Tags = dto.Tags ?? "",
                State = dto.State == 0 ? ActionItemState.NotStarted : (ActionItemState)dto.State
            };
            try
            {
                _context.ActionItems.Add(entry);
                _context.SaveChanges();
                return CreatedAtRoute("GetActionItem", new { id = entry.Id }, entry);
            }
            catch
            {
                Console.WriteLine("error");
                throw;
            }
        }

        [HttpPut("{id}", Name = "Update_ActionItem")]
        public async Task<ActionResult> UpdateActionItem(long id, [FromBody]ActionItemDto dto)
        {
            try
            {
                DateTime tempdt;
                var entry = await _context.ActionItems.FindAsync(id);
                entry.Description = dto.Description ?? entry.Description;
                entry.DueDate = DateTime.TryParse(dto.DueDate, out tempdt) ? (DateTime?)tempdt : entry.DueDate;
                entry.Tags = dto.Tags ?? entry.Tags;
                _context.SaveChanges();
                return CreatedAtRoute("GetActionItem", new { id = entry.Id }, entry);
            }
            catch
            {
                Console.WriteLine("error");
                throw;
            }
        }


        [HttpPost("{id}/action", Name = "Update_ActionItemStatus")]
        public async Task<ActionResult> UpdateActionItemStatus(long id, [FromBody]ActionItemCommandDto dto)
        {
            try
            {
                var entry = await _context.ActionItems.FindAsync(id);
                dynamic payload = dto.Payload;
                var action = dto.Action ?? "<null>";
                switch (action.ToLower())
                {
                    case "complete":
                        entry.State = ActionItemState.Complete;
                        break;
                    case "reopen":
                        entry.State = ActionItemState.NotStarted;
                        break;
                    case "start":
                        entry.State = ActionItemState.InProgress;
                        break;
                    case "block":
                        entry.State = ActionItemState.Blocked;
                        break;
                    case "defer":
                        entry.State = ActionItemState.Paused;
                        break;
                    default:
                        throw new InvalidOperationException($"Action {action} is not supported.");
                }
                _context.SaveChanges();

                // https://docs.microsoft.com/en-us/dotnet/api/system.web.mvc.httpstatuscoderesult.-ctor?view=aspnet-mvc-5.2#System_Web_Mvc_HttpStatusCodeResult__ctor_System_Net_HttpStatusCode_
                // https://docs.microsoft.com/en-us/dotnet/api/system.net.httpstatuscode?redirectedfrom=MSDN&view=netframework-4.7.2
                
                // https://docs.microsoft.com/en-us/dotnet/api/microsoft.aspnetcore.mvc.controllerbase.statuscode?view=aspnetcore-2.2
                return StatusCode(201, entry);
            }
            catch
            {
                Console.WriteLine("error");
                throw;
            }
        }
    }

    public class ActionItemDto
    {
        public string UserId { get; set; }
        public string DueDate { get; set; }
        public string Description { get; set; }
        public string Tags { get; set; }
        public long State { get; set; }
    }

    public class ActionItemCommandDto
    {
        public string Action { get; set; }
        public dynamic Payload { get; set; }
    }

}