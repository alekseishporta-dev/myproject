 terraform {
  source = "../../infrastructure-modules"
  }

 inputs = {
    env_name = "prod"
    web_port = 9000
    db_user  = "prod_root"
    db_password = "UltraHardProdPassword777"
}
