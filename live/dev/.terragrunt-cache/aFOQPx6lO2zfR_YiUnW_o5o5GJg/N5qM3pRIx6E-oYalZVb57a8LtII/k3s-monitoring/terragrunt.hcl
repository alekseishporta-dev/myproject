terraform {
  # Указываем путь к нашей новой отдельной папке модуля
  source = "../../infrastructure-modules/k3s-monitoring"
}

inputs = {
  env_name = "dev"
}