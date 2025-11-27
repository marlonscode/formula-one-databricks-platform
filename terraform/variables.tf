variable "slack_webhook_url" {
  description = "The Slack webhook URL for sending notifications"
  type        = string
  sensitive   = true
}

variable "openweathermap_api_key" {
  description = "API key for OpenWeatherMap"
  type        = string
  sensitive   = true
}

