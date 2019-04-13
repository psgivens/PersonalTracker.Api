# Title Domains

### Premises

V1 
* Roles are per principal, but global (i.e. tied to a tenant)
* Scopes grant access from one service to another
* Scopes do not consider principal identity 

V2
* Roles are per tenant, per principal

### Master-detail Items

Identity Manager (expect where marked)
* person profile (IM)
  * add/remove role (IM)
  * principal-role (IM)
* roles (IM)
  * add/remove privilege (RM)
  * list privilege (RM)
  * add/remove principal (IM)
  * list principals (IM)

Resource Manager 
* resources (RM)
  * choose scope for resource (RM)
  * show scope for resource (RM)
* client (RM)
  * add/remove scopes from client (RM)
  * list scopes for client (RM)

Privilege Manager  
* endpoint (RM)
  * add/remove privilege from endpoint (RM)
  * list privileges (RM)
* privilege (RM)
  * add/remove endpoints from privilege (RM)
  * list endpoints (RM)
  * add/remove roles for privilege (RM)
  * list roles (RM)
* scope (RM)
  * add/remove resources for scopes (RM)
  * list resources (RM)
  * add/remove clients from scope (RM)
  * list clients (RM)

bonus
* group (IM)
  * person-group
  * group-group

---

## Identity Management

**Purpose** Describe the organization of users

**Protected by:** User-access-control

**Storage:** Event Sourcing

**Data:**
* person-profile #Editable
* person-group mapping #Editable
* group-group mapping #Editable
* role-principle mapping #Editable
* tenant-principle mapping #Editable
* ou-principle mapping #Editable

**Methods**
* UpdateUserInfo()
* UpdateGroupInfo()
* GrantPrivileges()

---

## Resource Management

**Purpose** Which systems can talk to which systems

**Protected by:** User-access-control

**Storage:** CRUD

**Data:**
* resource-scope mappings #Editable/Queryable
* scope-client mappings #Editable/Queryable
* endpoint-privilege mappings #Editable/Queryable
* privilege-role mappings #Editable/Queryable

---

## Tenant Management

**Purpose** Describe the customers that you serve

**Protected by:** User-access-control

**Storage:** Event Sourcing

**Data:**
* tenant-profile #Editable
* tenant-privilege mapping #Editable

---

## Identity Provider

**Purpose** Exchange credentials for access token

**Protected by:**
* write: public-private key encryption
* write: AWS IAM
* read: public

**Storage:** CRUD

**Data:**
* Identity #Internal
* Roles #Internal
* Tenants #Internal

**Methods**
* Authenticate (user-creds):token

---

## Access Control

**Purpose** <Fill this out>

**Protected by:**
* write: public-private key encryption
* write: AWS IAM
* read: public

**Storage:** CRUD

**Data:**
* Roles #Internal
* Resources #Internal
* Privileges #Internal
* Tenants #Internal

**Methods**
* ValidateAuthorization (token,resource)
