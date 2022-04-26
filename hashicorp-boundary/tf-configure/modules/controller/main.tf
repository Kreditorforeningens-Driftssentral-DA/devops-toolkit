/////////////////////////////////////////////////
// Scope: Global (Required)
//
// A scope is a permission boundary modeled as a
// container.
/////////////////////////////////////////////////

resource "boundary_scope" "GLOBAL" {
  global_scope = true
  scope_id     = "global"
}

/////////////////////////////////////////////////
// Scope: Organizations
/////////////////////////////////////////////////

resource "boundary_scope" "ORG" {
  name        = "kreditorforeningen"
  description = "Kreditorforeningen Organization"
  
  auto_create_admin_role = false
  auto_create_default_role = false
  
  scope_id = boundary_scope.GLOBAL.id
}

/////////////////////////////////////////////////
// Scope: Projects
/////////////////////////////////////////////////

resource "boundary_scope" "PROJ_DEVOPS" {
  name                     = "devops"
  description              = "DevOps"
  
  auto_create_admin_role = false
  auto_create_default_role = false
  
  scope_id = boundary_scope.ORG.id
}

resource "boundary_scope" "PROJ_DEVELOPER" {
  name                     = "developer"
  description              = "Developers"
  
  auto_create_admin_role = false
  auto_create_default_role = false
  
  scope_id = boundary_scope.ORG.id
}

resource "boundary_scope" "PROJ_PREDATOR_USER" {
  name                     = "predator-user"
  description              = "Predator users"
  
  auto_create_admin_role = false
  auto_create_default_role = false
  
  scope_id = boundary_scope.ORG.id
}

/////////////////////////////////////////////////
// Authentication methods
//
// An auth method is a resource that provides a 
// mechanism for users to authenticate to
// Boundary. An auth method contains accounts
// which link an individual user to a set of
// credentials and managed groups which groups
// accounts that satisfy criteria and can be used
// as principals in roles. Auth methods can be
// defined at either a Global or Organization
// scope.
/////////////////////////////////////////////////

resource boundary_auth_method_password "ORG" {
  name = "org-auth-password"

  description = "Standard password authentication."
  min_login_name_length = 4
  min_password_length   = 4
  
  scope_id = boundary_scope.ORG.id
}

/////////////////////////////////////////////////
// Roles
//
// A role is a resource that contains a
// collection of permissions which are granted to
// any principal assigned to the role. Users,
// groups, and managed groups are principals
// which allows either to be assigned to a role.
// A role can be defined within any scope. A role
// can be assigned to principals from any scope.
/////////////////////////////////////////////////

/////////////////////////////////////////////////
// Anonymous Roles
// - Required for listing auth-methods and 
//   organizations for unauthenticated users
/////////////////////////////////////////////////

resource "boundary_role" "GLOBAL_ANON_LISTING" {
  name        = "global-anon-listing"
  description = "Anonymous role (global)"

  grant_strings = [
    "id=*;type=*;actions=read,list",
  ]
  principal_ids = [
    "u_anon"
  ]

  scope_id = boundary_scope.GLOBAL.id
}

resource "boundary_role" "ORG_ANON_LISTING" {
  name        = "org-anon-listing"
  description = "Anonymous role (org)"

  grant_strings = [
    "id=*;type=auth-method;actions=read,list,authenticate",
    "type=scope;actions=list",
    "id={{account.id}};actions=read,change-password",
  ]
  principal_ids = [
    "u_anon",
  ]
  
  scope_id = boundary_scope.ORG.id
}

/////////////////////////////////////////////////
// User Roles
//
// A role is a resource that contains a
// collection of permissions which are granted to
// any principal assigned to the role.
/////////////////////////////////////////////////

resource "boundary_role" "ORG_USER" {
  name        = "org-user"
  description = "User role (Read)"
  
  grant_strings  = [
    "id=*;type=*;actions=read,list"
  ]
  principal_ids = concat(
    [ for user in boundary_user.USER : user.id ],
    ["u_auth"],
  )
  
  grant_scope_id = boundary_scope.ORG.id  
  scope_id = boundary_scope.ORG.id
}

resource "boundary_role" "ORG_ADMIN" {
  name        = "org-admin"
  description = "Administrator role"

  grant_strings = [
    "id=*;type=*;actions=*"
  ]
  principal_ids = concat(
    [ boundary_group.ORG_ADMINS.id ],
  )
  
  grant_scope_id = boundary_scope.ORG.id
  scope_id = boundary_scope.ORG.id
}

resource "boundary_role" "PROJ_DEVOPS_ADMIN" {
  name        = "devops-admin"
  description = "DevOps Administrator role"

  grant_strings = [
    "id=*;type=*;actions=*"
  ]
  principal_ids = concat(
    [ boundary_group.ORG_ADMINS.id ],
  )
  
  grant_scope_id = boundary_scope.PROJ_DEVOPS.id
  scope_id = boundary_scope.ORG.id
}


/////////////////////////////////////////////////
// Accounts
//
// An account is a resource that represents a
// unique set of credentials issued from a
// configured auth method which can be used to
// establish the identity of a user. A user can
// have zero or more accounts but an account can
// only belong to a single user. An account can
// only be associated with a user in the same
// scope as the account's auth method.
/////////////////////////////////////////////////

resource "boundary_account_password" "USER" {
  for_each = {
    for user in local.users: user.username => user
    if length(user.password) > 0
  }

  name        = each.key
  description = format("%s (%s)", "Password authentication", each.key)
  login_name  = each.key
  password    = each.value.password
  
  type = boundary_auth_method_password.ORG.type  
  auth_method_id = boundary_auth_method_password.ORG.id
}

/////////////////////////////////////////////////
// Users
//
// A user is a resource that represents an
// individual person or entity for the purposes
// of access control. A user can be associated
// with zero or more accounts. A user
// authenticates to Boundary through an
// associated account and must be associated with
// at least one account before they can access
// Boundary.
/////////////////////////////////////////////////

resource "boundary_user" "USER" {
  for_each = {
    for user in local.users: user.username => user
  }

  name = each.key
  description = format("%s (%s)","Boundary user",each.key)
  account_ids = concat(
    length(each.value.password) > 3 ? [ boundary_account_password.USER[each.key].id ] : [],
  )
  
  scope_id = boundary_scope.ORG.id
}

/////////////////////////////////////////////////
// Groups
//
// A group is a resource that represents a
// collection of users which can be treated
// equally for the purposes of access control.
/////////////////////////////////////////////////

resource "boundary_group" "ORG_ADMINS" {
  name        = "org-admin"
  description = "Org admin group"
  member_ids  = concat(
    [
      for user in local.users: boundary_user.USER[user.username].id
      if user.group == "admins"
    ],
  )

  scope_id = boundary_scope.ORG.id
}

/////////////////////////////////////////////////
// Targets
/////////////////////////////////////////////////

/////////////////////////////////////////////////
// Host catalogs
//
// A host catalog is a resource that contains
//  hosts and host sets. A host catalog can only
//  be defined within a project.
/////////////////////////////////////////////////

resource "boundary_host_catalog_static" "DOCKER_EXAMPLES" {
  name        = "docker-demo"
  description = "Docker demo services"
  
  scope_id = boundary_scope.PROJ_DEVOPS.id
}

/////////////////////////////////////////////////
// Hosts
//
// A host is a resource that represents a
// computing element with a network address
// reachable from Boundary. A host belongs to a
// host catalog.
/////////////////////////////////////////////////

resource "boundary_host_static" "DOCKER_DEMO_WEBSERVER" {
  for_each = toset(["1","2","3"])

  name = format("%s-%s","docker-demo-web",each.key)
  description = format("%s (%s)","Demo webserver",each.key)
  
  // docker dns-name (as seen from boundary worker)
  address = format("%s-%s","demo-web",each.key)

  host_catalog_id = boundary_host_catalog_static.DOCKER_EXAMPLES.id
}

resource "boundary_host_static" "DOCKER_ADMINER" {
  name = "docker-adminer"
  description = "Adminer UI for boundary database"
  
  // docker dns-name (as seen from boundary worker)
  address = "adminer"

  host_catalog_id = boundary_host_catalog_static.DOCKER_EXAMPLES.id
}

/////////////////////////////////////////////////
// Host sets
//
// A host set is a resource that represents a
// collection of hosts which are considered
// equivalent for the purposes of access control.
/////////////////////////////////////////////////

resource "boundary_host_set_static" "DOCKER_DEMO_WEBSERVERS" {
  name = "docker-demo"
  description = "Docker demo webserver(s)"

  host_ids = concat(
    [
      for item in boundary_host_static.DOCKER_DEMO_WEBSERVER: item.id
    ],
  )
  host_catalog_id = boundary_host_catalog_static.DOCKER_EXAMPLES.id
}

resource "boundary_host_set_static" "DOCKER_ADMINER" {
  name = "docker-adminer"
  description = "Docker adminer"

  host_ids = [ boundary_host_static.DOCKER_ADMINER.id ]
  host_catalog_id = boundary_host_catalog_static.DOCKER_EXAMPLES.id
}

/////////////////////////////////////////////////
// Targets
//
// A target is a resource that represents a
// networked service with an associated set of
// permissions a user can connect to and interact
// with through Boundary by way of a session. 
/////////////////////////////////////////////////

resource "boundary_target" "DEMO_WEBSERVERS" {
  name         = "demo-webservers"
  description  = "Demo webserver targets"
  type         = "tcp"
  
  default_port             = 80
  session_connection_limit = -1
  session_max_seconds      = 300
  
  host_source_ids = [
    boundary_host_set_static.DOCKER_DEMO_WEBSERVERS.id,
  ]
  scope_id = boundary_scope.PROJ_DEVOPS.id
}

resource "boundary_target" "DEMO_ADMINER" {
  name         = "demo-adminer"
  description  = "Demo adminer target"
  type         = "tcp"
  
  default_port             = 8080
  session_connection_limit = -1
  session_max_seconds      = 300
  
  host_source_ids = [
    boundary_host_set_static.DOCKER_ADMINER.id,
  ]
  scope_id = boundary_scope.PROJ_DEVOPS.id
}