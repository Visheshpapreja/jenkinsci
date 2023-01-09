variable "project" {
  description = "The name of the project"
}

variable "environment" {
  description = "The deployment environment"
  default     = "production"
}

variable "region" {
  description = "The AWS Region"
}


variable "user_names" {
  description = "Create IAM users with these names"
  type        = list(string)
  #default     = ["bogo_user_1", "bogo_user_2", "bogo_user_3"]
}
