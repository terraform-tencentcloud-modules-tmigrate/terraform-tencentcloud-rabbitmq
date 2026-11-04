################################################################################
# RabbitMQ Instance Outputs
################################################################################
output "instance_id" {
  description = "The ID of the RabbitMQ instance"
  value       = tencentcloud_tdmq_rabbitmq_vip_instance.instance.id
}

output "cluster_name" {
  description = "The name of the RabbitMQ cluster"
  value       = tencentcloud_tdmq_rabbitmq_vip_instance.instance.cluster_name
}

output "public_access_endpoint" {
  description = "Public network access endpoint"
  value       = tencentcloud_tdmq_rabbitmq_vip_instance.instance.public_access_endpoint
}

output "vpcs" {
  description = "VPC access endpoint information"
  value       = tencentcloud_tdmq_rabbitmq_vip_instance.instance.vpcs
}

output "instance" {
  description = "The full RabbitMQ instance object"
  value       = tencentcloud_tdmq_rabbitmq_vip_instance.instance
  sensitive   = true
}

################################################################################
# Virtual Host Outputs
################################################################################
output "virtual_host_ids" {
  description = "Map of virtual host IDs"
  value = {
    for k, v in tencentcloud_tdmq_rabbitmq_virtual_host.vhost : k => v.id
  }
}

output "virtual_hosts" {
  description = "Map of all virtual hosts"
  value       = tencentcloud_tdmq_rabbitmq_virtual_host.vhost
}

################################################################################
# User Outputs
################################################################################
output "user_ids" {
  description = "Map of user IDs"
  value = {
    for k, v in tencentcloud_tdmq_rabbitmq_user.user : k => v.id
  }
}

output "users" {
  description = "Map of all users"
  value       = tencentcloud_tdmq_rabbitmq_user.user
  sensitive   = true
}

################################################################################
# User Permission Outputs
################################################################################
output "user_permission_ids" {
  description = "Map of user permission IDs"
  value = {
    for k, v in tencentcloud_tdmq_rabbitmq_user_permission.permission : k => v.id
  }
}

output "user_permissions" {
  description = "Map of all user permissions"
  value       = tencentcloud_tdmq_rabbitmq_user_permission.permission
}
