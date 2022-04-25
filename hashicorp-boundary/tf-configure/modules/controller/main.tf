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
