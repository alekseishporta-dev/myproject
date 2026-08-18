terraform {
  source = "../../../infrastructure-modules/k3s-vault"
}

inputs = {
  env_name = "dev"
}