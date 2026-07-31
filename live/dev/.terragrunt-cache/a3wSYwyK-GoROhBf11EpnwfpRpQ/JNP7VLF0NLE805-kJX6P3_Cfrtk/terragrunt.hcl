
 terraform {
   source = "../../infrastructure-modules"
}


 inputs = {
   env_name = "dev"
   web_port  = 8080
   db_user = "dev_user"
   db_password = "DevPassword999"

}
