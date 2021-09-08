variable "tags" {
  type    = list(any)
  default = ["local-exec", "remote-exec", ]
}

variable "instance_type" {
  type    = list(any)
  default = ["t2.micro", "t2.large", "t2.small"]
}

locals {
  time = formatdate("DD MM YYYY hh:mm: ZZZ", timestamp())
}

output "timestamp" {
  value = local.time
}