# Variables for AWS Provider
variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-west-1"
}

variable "profile" {
  description = "The AWS profile to use"
  type        = string
  default     = "default"
}

# Variables for VPC and Subnets
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_a_cidr" {
  description = "CIDR block for public subnet in AZ A"
  type        = string
  default     = "10.0.0.0/24"
}

variable "public_subnet_b_cidr" {
  description = "CIDR block for public subnet in AZ B"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_wl_subnet_a_cidr" {
  description = "CIDR block for private subnet in AZ A"
  type        = string
  default     = "10.0.4.0/24"
}

variable "private_wl_subnet_b_cidr" {
  description = "CIDR block for private subnet in AZ B"
  type        = string
  default     = "10.0.5.0/24"
}

variable "private_data_subnet_a_cidr" {
  description = "CIDR block for private subnet in AZ A"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_data_subnet_b_cidr" {
  description = "CIDR block for private subnet in AZ B"
  type        = string
  default     = "10.0.3.0/24"
}

variable "certificate_arn" {
  description = "The arn of the certificate to be used when configuring the ALB listener"
  type        = string
}