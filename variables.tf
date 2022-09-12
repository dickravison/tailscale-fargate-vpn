variable "project_name" {
  type    = string
  default = "tailscale-fargate-vpn"
}

variable "region" {
  type    = string
}

variable "service_name" {
  type    = string
  default = "tailscale"
}

variable "cidr_range" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnets" {
  type    = list(any)
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}