################################################################################
# Availability Zone Data Source
################################################################################
data "tencentcloud_availability_zones_by_product" "zones" {
  product = "cvm"
}

locals {
  # Build a map of zone name to zone id
  zone_id_map = { for z in data.tencentcloud_availability_zones_by_product.zones.zones : z.name => z.id }
  # Convert zone names to zone ids
  zone_ids = [for name in var.availability_zones : local.zone_id_map[name]]
}

################################################################################
# RabbitMQ VIP Instance
################################################################################
resource "tencentcloud_tdmq_rabbitmq_vip_instance" "instance" {
  cluster_name                          = var.cluster_name
  cluster_version                       = var.cluster_version
  vpc_id                                = var.vpc_id
  subnet_id                             = var.subnet_id
  zone_ids                              = local.zone_ids
  node_spec                             = var.node_spec
  node_num                              = var.node_num
  storage_size                          = var.storage_size
  pay_mode                              = var.pay_mode
  time_span                             = var.time_span
  auto_renew_flag                       = var.auto_renew_flag
  enable_create_default_ha_mirror_queue = var.enable_create_default_ha_mirror_queue

  dynamic "resource_tags" {
    for_each = [for k in reverse(sort(keys(var.tags))) : { key = k, value = var.tags[k] }]
    content {
      tag_key   = resource_tags.value.key
      tag_value = resource_tags.value.value
    }
  }
}

################################################################################
# Virtual Hosts
################################################################################
resource "tencentcloud_tdmq_rabbitmq_virtual_host" "vhost" {
  for_each = var.virtual_hosts

  instance_id  = tencentcloud_tdmq_rabbitmq_vip_instance.instance.id
  virtual_host = each.key
  description  = each.value.description
  trace_flag   = each.value.trace_flag
}

################################################################################
# Users
################################################################################
locals {
  # Use user_names if provided, otherwise derive from users keys
  user_keys = length(var.user_names) > 0 ? var.user_names : keys(var.users)
}

resource "tencentcloud_tdmq_rabbitmq_user" "user" {
  for_each = toset(local.user_keys)

  instance_id     = tencentcloud_tdmq_rabbitmq_vip_instance.instance.id
  user            = each.key
  password        = var.users[each.key].password
  description     = var.users[each.key].description
  tags            = var.users[each.key].tags
  max_connections = var.users[each.key].max_connections
  max_channels    = var.users[each.key].max_channels
}

################################################################################
# User Permissions
################################################################################
resource "tencentcloud_tdmq_rabbitmq_user_permission" "permission" {
  for_each = { for perm in var.user_permissions : "${perm.user}#${perm.virtual_host}" => perm }

  instance_id   = tencentcloud_tdmq_rabbitmq_vip_instance.instance.id
  user          = each.value.user
  virtual_host  = each.value.virtual_host
  config_regexp = each.value.config_regexp
  write_regexp  = each.value.write_regexp
  read_regexp   = each.value.read_regexp

  depends_on = [
    tencentcloud_tdmq_rabbitmq_user.user,
    tencentcloud_tdmq_rabbitmq_virtual_host.vhost
  ]
}
