variable "database_host" {
  description = "The host of the database"
  type        = string
}

variable "database_port" {
  description = "The port of the database"
  type        = string
}

variable "database_user" {
  description = "The database username"
  type        = string
}

variable "database_password" {
  description = "The database password"
  type        = string
}

variable "database_name" {
  description = "The name of the database"
  type        = string
}

variable "mysql_root_password" {
  description = "The root password for MySQL"
  type        = string
}

variable "key_pair_name" {
  description = "The AWS key pair name"
  type        = string
}

variable "iam_user_name" {
  description = "The IAM user name"
  type        = string
}
