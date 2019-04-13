using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;

namespace Pomodoro.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PingDtoController : ControllerBase
    {
        // GET api/ping
        [HttpGet]
        public ActionResult<PingDto> Get()
        {
            return new PingDto {
                Value = "Success from Ping Controller"
            };
        }

        // GET api/ping/5
        [HttpGet("{id}")]
        public ActionResult<PingDto> Get(int id)
        {
            return new PingDto {
                Value = "Success: " + id
            };
        }

        // POST api/ping
        [HttpPost]
        public ActionResult<PingDto> Post([FromBody] PingDto ping)
        {            
            return ping;
        }

        // PUT api/values/5
        [HttpPut("{id}")]
        public void Put(int id, [FromBody] string value)
        {
        }

        // DELETE api/values/5
        [HttpDelete("{id}")]
        public void Delete(int id)
        {
        }
    }
    public class PingDto {
        public string Value {get;set;}
    }
}
