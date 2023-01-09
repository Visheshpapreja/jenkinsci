variable "user_names" {
  description = "Create IAM users with these names"
  type        = list(string)
}

variable "environment" {
  description = "The deployment environment"
}

