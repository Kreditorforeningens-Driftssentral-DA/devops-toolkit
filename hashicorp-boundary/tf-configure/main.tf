locals {
  users = [{
    username = "admin"
    password = "L0g1n"
    group    = "admins"
  },{
    username = "demo"
    password = "demo"
  },{
    username = "hackerboy"
  }]
}

module "boundary-config" {
  source = "./modules/controller"
  users  = local.users
}
