variable "name" {
  type = string
}

variable "cidr" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "enable_nat_gateway" {
  type = bool
}

variable "single_nat_gateway" {
  type = bool
}

variable "enable_dns_hostnames" {
  type = bool
}

variable "public_subnet_tags" {
  type = map(any)
}

variable "private_subnet_tags" {
  type = map(any)
}

variable "availability_zones" {
  type = list(string)
}