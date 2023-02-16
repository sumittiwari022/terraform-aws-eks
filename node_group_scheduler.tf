resource "aws_autoscaling_schedule" "ecs_stop" {
  for_each = var.enable_schedule ? toset(module.eks_cluster.self_managed_node_groups_autoscaling_group_names) : []
  count                  = !var.fargate_only && var.enable_schedule ? 1 : 0
  scheduled_action_name  = "self-managed-nodegroup-${var.cluster_name}-stop"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  autoscaling_group_name = each.value
  recurrence             = var.schedule_cron_stop
}

resource "aws_autoscaling_schedule" "ecs_start" {
  for_each = var.enable_schedule ? toset(module.eks_cluster.self_managed_node_groups_autoscaling_group_names) : []
  scheduled_action_name  = "self-managed-nodegroup-${var.cluster_name}-start"
  min_size               = try(each.value.min_size, var.self_managed_node_group_defaults.min_size, 0)
  max_size               = try(each.value.max_size, var.self_managed_node_group_defaults.max_size, 3)
  desired_capacity       = try(each.value.desired_size, var.self_managed_node_group_defaults.desired_size, 1)
  autoscaling_group_name = each.value
  recurrence             = var.schedule_cron_start
}