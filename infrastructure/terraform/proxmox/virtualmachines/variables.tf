variable "name" {
  type        = string
  description = "VM name"
}
variable "node_name" {
  type        = string
  description = "node name"
}
variable "cpu" {
  type        = string
  description = "number of cpu cores"
}
variable "sockets" {
  type        = string
  description = "number of cpu sockets"
}
variable "memory" {
  type        = string
  description = "memory in megabytes"
  default     = "8196"
}
variable "disk_size" {
  type        = string
  description = "disk size in gigabytes"
  default     = "16"
}
variable "iso_id" {
  type        = string
  description = "iso identifier"
}

variable "vm_id" {
  type        = string
  description = "id"
}
variable "mac_address" {
  type        = string
  description = "mac address for the network interface"
}
variable "tags" {
  type        = list(string)
  description = "vm tags"
}
