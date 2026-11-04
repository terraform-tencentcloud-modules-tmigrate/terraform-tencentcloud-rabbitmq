################################################################################
# Basic Configuration
################################################################################
variable "cluster_name" {
  description = "Name of the RabbitMQ cluster"
  type        = string
}

variable "cluster_version" {
  description = "Cluster version. Valid values: 3.8.30, 3.11.8, 3.13.7"
  type        = string
  default     = "3.8.30"

  validation {
    condition     = contains(["3.8.30", "3.11.8", "3.13.7"], var.cluster_version)
    error_message = "cluster_version must be one of: 3.8.30, 3.11.8, 3.13.7"
  }
}

################################################################################
# Network Configuration
################################################################################
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zone names (e.g., ap-jakarta-1)"
  type        = list(string)
}

################################################################################
# Node Configuration
################################################################################
variable "node_spec" {
  description = "Node specification. Valid values: rabbit-vip-basic-5(2C4G), rabbit-vip-profession-2c8g(2C8G), rabbit-vip-basic-1(4C8G), rabbit-vip-profession-4c16g(4C16G), rabbit-vip-basic-2(8C16G), rabbit-vip-profession-8c32g(8C32G), rabbit-vip-basic-4(16C32G), rabbit-vip-profession-16c64g(16C64G)"
  type        = string
  default     = "rabbit-vip-basic-1"

  validation {
    condition = contains([
      "rabbit-vip-basic-5",
      "rabbit-vip-profession-2c8g",
      "rabbit-vip-basic-1",
      "rabbit-vip-profession-4c16g",
      "rabbit-vip-basic-2",
      "rabbit-vip-profession-8c32g",
      "rabbit-vip-basic-4",
      "rabbit-vip-profession-16c64g"
    ], var.node_spec)
    error_message = "node_spec must be a valid RabbitMQ node specification"
  }
}

variable "node_num" {
  description = "Number of nodes. Minimum 3 for multi-AZ deployment"
  type        = number
  default     = 1

  validation {
    condition     = var.node_num >= 1
    error_message = "node_num must be at least 1"
  }
}

variable "storage_size" {
  description = "Storage size per node in GB"
  type        = number
  default     = 200

  validation {
    condition     = var.storage_size >= 200
    error_message = "storage_size must be at least 200 GB"
  }
}

################################################################################
# Charge Configuration
################################################################################
variable "pay_mode" {
  description = "Payment mode. 0: postpaid, 1: prepaid"
  type        = number
  default     = 1

  validation {
    condition     = contains([0, 1], var.pay_mode)
    error_message = "pay_mode must be 0 (postpaid) or 1 (prepaid)"
  }
}

variable "time_span" {
  description = "Purchase duration in months (for prepaid)"
  type        = number
  default     = 1
}

variable "auto_renew_flag" {
  description = "Auto renewal flag"
  type        = bool
  default     = true
}

################################################################################
# Instance Configuration
################################################################################
variable "enable_create_default_ha_mirror_queue" {
  description = "Whether to enable HA mirror queue"
  type        = bool
  default     = false
}

################################################################################
# Resource Tags
################################################################################
variable "tags" {
  description = "Instance resource tags. Each key-value pair will be converted into a resource_tags block on the RabbitMQ VIP instance."
  type        = map(string)
  default     = {}
}

################################################################################
# Virtual Host Configuration
################################################################################
variable "virtual_hosts" {
  description = "Map of virtual hosts to create"
  type = map(object({
    description = optional(string, "")
    trace_flag  = optional(bool, false)
  }))
  default = {}
}

################################################################################
# User Configuration
################################################################################
variable "users" {
  description = "Map of users to create"
  type = map(object({
    password        = string
    description     = optional(string, "")
    tags            = optional(list(string), ["management"])
    max_connections = optional(number)
    max_channels    = optional(number)
  }))
  default = {}
}

variable "user_names" {
  description = "List of user names to create (used to avoid sensitive value in for_each)"
  type        = list(string)
  default     = []
}

################################################################################
# User Permission Configuration
################################################################################
variable "user_permissions" {
  description = "List of user permissions to create"
  type = list(object({
    user          = string
    virtual_host  = string
    config_regexp = optional(string, ".*")
    write_regexp  = optional(string, ".*")
    read_regexp   = optional(string, ".*")
  }))
  default = []
}
