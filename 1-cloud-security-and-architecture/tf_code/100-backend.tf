# we are using a local state to keep the solution lean
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}