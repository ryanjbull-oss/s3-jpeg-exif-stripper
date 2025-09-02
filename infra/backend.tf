terraform {
  backend "local" {
    path = "../tf_state/terraform.tfstate"
  }
}