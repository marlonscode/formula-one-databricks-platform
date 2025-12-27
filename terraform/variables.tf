variable "is_project_live" {
  description = "Flag to indicate if the project is live"
  type        = bool
  default     = false
}

variable "slack_webhook_url" {
  description = "The Slack webhook URL for sending notifications"
  type        = string
  sensitive   = true
}

variable "kafka_api_key" {
  description = "API key for Kafka authentication"
  type        = string
  sensitive   = true
}

variable "kafka_api_secret" {
  description = "API secret for Kafka authentication"
  type        = string
  sensitive   = true
}

variable "kafka_client_id" {
  description = "Client ID for Kafka"
  type        = string
  sensitive = true
}

variable "kafka_bootstrap_server" {
  description = "Bootstrap server address for Kafka"
  type        = string
  sensitive = true
}

variable "confluent_layer_arn" {
  description = "The version of the Confluent Kafka Lambda layer to use"
  type        = string
}

variable "databricks_host" {
  description = "Databricks workspace host URL"
  type        = string
  sensitive   = true
}

variable "databricks_http_path" {
  description = "Databricks SQL warehouse HTTP path"
  type        = string
  sensitive   = true
}

variable "databricks_token" {
  description = "Databricks personal access token"
  type        = string
  sensitive   = true
}

variable repo_name {
  type = string
}

variable environment {
  type = string
  default = "dev"
}

variable cluster_name {
  type = string
}

variable aws_region {
  type = string
}

variable image_tag {
  type = string
}

variable vpc_id {
  type        = string
  description = "VPC ID where ECS Fargate tasks will run. Leave empty to use default VPC."
  default     = ""
}

variable subnet_ids {
  type        = list(string)
  description = "List of subnet IDs for ECS Fargate tasks. Leave empty to use default VPC subnets."
  default     = []
}



