using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using IdentityManagement.Api.Controllers;
using IdentityManagement.Api.Data;
using IdentityManagement.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace IdentityManagement.Api.Handlers
{
    #region Commands
    public class UserCommand { }
    public class UpdateUserCommand : UserCommand
    {
        public UserDto User { get; set; }
    }
    public class CreateUserCommand : UserCommand
    {
        public UserDto User { get; set; }
    }
    public class AssignUserCommand : UserCommand
    {
        public long UserId { get; set; }
        public string GroupName { get; set; }
    }
    public class UnassignUserCommand : UserCommand
    {
        public long UserId { get; set; }
        public string GroupName { get; set; }
    }
    #endregion

    #region Events
    public class UserEvent { }
    public class UserUpdatedEvent : UserEvent
    {
        public UserDto User { get; set; }
    }
    public class UserCreatedEvent : UserEvent
    {
        public UserDto User { get; set; }
    }
    public class UserAssignedEvent : UserEvent
    {
        public long GroupId { get; set; }
        public string GroupName { get; set; }
    }
    public class UserUnassignedEvent : UserEvent
    {
        public long GroupId { get; set; }
        public string GroupName { get; set; }
    }
    #endregion

    #region State
    public class GroupState
    {
        public long Id { get; set; }
        public string Name { get; set; }
    }

    public class UserState
    {
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public List<GroupState> Groups { get; } = new List<GroupState>();
    }
    #endregion

    public class UserHandler
    {
        private readonly IdentityManagementDbContext _context;
        private readonly UsersEventRepository _repository;

        public UserHandler(IdentityManagementDbContext context)
        {
            _context = context;
            _repository = new UsersEventRepository(_context);
        }

        // TODO: Separate handle form database calls
        public IEnumerable<(long, UserEvent)> Handle(long? id, UserCommand command)
        {
            if (!id.HasValue)
            {
                if (command is CreateUserCommand)
                {
                    var cmd = command as CreateUserCommand;
                    var evt = new UserCreatedEvent
                    {
                        User = cmd.User
                    };
                    Evolve(null, evt);
                    yield return (1, evt);
                }
                else
                {
                    throw new InvalidOperationException("Cannot perform commands on non-existant user");
                }
            }
            else
            {
                var streamId = id.Value;
                var (ver, user) = GetUser(streamId);

                if (command is UpdateUserCommand)
                {
                    var cmd = command as UpdateUserCommand;

                    var evt = new UserUpdatedEvent
                    {
                        User = cmd.User
                    };

                    Evolve(user, evt);
                    yield return (ver + 1, evt);
                }
                else if (command is AssignUserCommand)
                {
                    var cmd = command as AssignUserCommand;
                    var group = _context.Groups.First(g => g.Name == cmd.GroupName);

                    var evt = new UserAssignedEvent
                    {
                        GroupId = group.Id,
                        GroupName = cmd.GroupName
                    };

                    Evolve(user, evt);
                    yield return (ver +1, evt);
                }
                else
                {
                    throw new InvalidOperationException("Cannot perform commands on non-existant user");
                }
            }
        }

        public (long, UserState) GetUser(long id)
        {
            UserState user = null;
            var envelopes = _repository.GetEvents(id);
            foreach (var env in envelopes)
            {
                user = Evolve(user, env.Item);
            }
            return (envelopes.Count(), user);
        }

        private UserState Evolve(UserState user, UserEvent @event)
        {
            if (user == null)
            {
                if (@event is UserCreatedEvent)
                {
                    var evt = @event as UserCreatedEvent;
                    try
                    {
                        return new UserState
                        {
                            FirstName = evt.User.FirstName,
                            LastName = evt.User.LastName
                        };
                    }
                    catch
                    {
                        Console.WriteLine("error");
                        throw;
                    }
                }
                else
                {
                    throw new InvalidOperationException("Cannot perform commands on non-existant user");
                }
            }
            else
            {
                if (@event is UserUpdatedEvent)
                {
                    var evt = @event as UserUpdatedEvent;
                    user.FirstName = evt.User.FirstName;
                    user.LastName = evt.User.LastName;
                    return user;
                }
                else if (@event is UserAssignedEvent)
                {
                    var evt = @event as UserAssignedEvent;
                    user.Groups.Add(new GroupState
                    {
                        Id = evt.GroupId,
                        Name = evt.GroupName
                    });
                    return user;
                }
                else if (@event is UserUnassignedEvent)
                {
                    var evt = @event as UserUnassignedEvent;
                    user.Groups.Add(new GroupState
                    {
                        Id = evt.GroupId,
                        Name = evt.GroupName
                    });
                    return user;
                }
            }
            return null;
        }
    }
}