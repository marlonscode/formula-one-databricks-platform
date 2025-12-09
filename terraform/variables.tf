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



