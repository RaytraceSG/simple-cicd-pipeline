variable "ecs_cluster_name" {
  description = "ECS Cluster Name"
  type        = string
  default     = "azmi1ECSCluster"
}

variable "ecs_task_def_family" {
  description = "ECS Task Definition Family Name"
  type        = string
  default     = "azmi1TaskDefinitionTest"
}

variable "sg_name" {
  description = "Security Group Name"
  type        = string
  default     = "azmi1-tf-sg-allow-ssh-http-https"
}