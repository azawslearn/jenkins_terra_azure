variable "prefix" {
  description = "The prefix for resource names"
  type        = string
  default     = ""
}

variable "region" {
  description = "Region of the deployment"
  type        = string
  default     = ""
}

variable "vm_size" {
  description = "Size of the VM"
  type        = string
  default     = ""
}

variable "admin" {
  description = "Admin of the machine"
  type        = string
  default     = ""
}

variable "admin_password" {
  description = "Password for admin"
  type        = string
  default     = ""
}
