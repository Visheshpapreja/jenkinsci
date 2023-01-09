
  module "iam" {
  source = "../modules/iam"

  user_names              = var.user_names
  environment             = var.environment

}
