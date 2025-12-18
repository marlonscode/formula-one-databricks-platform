####################################
## Provider                        ##
####################################

provider "aws" {
  region = "ap-southeast-2"
}

####################################
## S3                             ##
####################################

resource "aws_s3_bucket" "iot_bucket" {
  bucket = "databricks-platform-iot"
}

resource "aws_s3_bucket" "iot_notifications_bucket" {
  bucket = "databricks-platform-iot-notifications"
}

resource "aws_s3_bucket_public_access_block" "iot_bucket_block" {
  bucket = aws_s3_bucket.iot_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

####################################
## Lambdas                        ##
####################################

data "archive_file" "python_layer" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_layer"
  output_path = "${path.module}/lambda_layer/python.zip"
}

resource "aws_lambda_layer_version" "python_layer" {
  filename            = data.archive_file.python_layer.output_path
  layer_name          = "python_layer"
  compatible_runtimes = ["python3.9"]
  description         = "Python libraries for Lambda"

  source_code_hash = data.archive_file.python_layer.output_base64sha256
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "sns_publish" {
  statement {
    effect = "Allow"

    actions = [
      "sns:Publish"
    ]

    resources = [
      aws_sns_topic.iot_notifications.arn
    ]
  }
}

data "aws_iam_policy_document" "s3_put" {
  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::databricks-platform-iot-*",
      "arn:aws:s3:::databricks-platform-iot-*/*"
    ]
  }
}

resource "aws_iam_role" "iot_lambda_role" {
  name               = "databricks-platform-iot-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "iot_basic_execution" {
  role       = aws_iam_role.iot_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_sns_publish" {
  role = aws_iam_role.iot_lambda_role.name    
  policy = data.aws_iam_policy_document.sns_publish.json
}

resource "aws_iam_role_policy" "lambda_iot_s3_put" {
  role = aws_iam_role.iot_lambda_role.name    
  policy = data.aws_iam_policy_document.s3_put.json
}

resource "aws_cloudwatch_event_rule" "every_minute" {
    name = "every-minute"
    description = "Fires every minute"
    schedule_expression = "rate(1 minute)"
    state = var.is_project_live ? "ENABLED" : "DISABLED"
}

# Lambda: iot air temp
data "archive_file" "iot_air_temp" {
  type        = "zip"
  source_dir = "${path.module}/lambdas/iot_air_temp"
  output_path = "${path.module}/lambdas/iot_air_temp/iot_air_temp.zip"
}

resource "aws_lambda_function" "iot_air_temp" {
  filename         = data.archive_file.iot_air_temp.output_path
  function_name    = "iot-air-temp"
  role             = aws_iam_role.iot_lambda_role.arn
  handler          = "iot_air_temp.handler"
  source_code_hash = data.archive_file.iot_air_temp.output_base64sha256
  runtime = "python3.9"
  timeout = 60

  layers = [
    aws_lambda_layer_version.python_layer.arn,
    var.confluent_layer_arn
    ]

  environment {
    variables = {
      SNS_TOPIC_ARN         = aws_sns_topic.iot_notifications.arn
      KAFKA_API_KEY         = var.kafka_api_key
      KAFKA_API_SECRET      = var.kafka_api_secret
      KAFKA_CLIENT_ID       = var.kafka_client_id
      KAFKA_BOOTSTRAP_SERVER = var.kafka_bootstrap_server
    }
  }
}

resource "aws_cloudwatch_event_target" "iot_air_temp" {
    rule = aws_cloudwatch_event_rule.every_minute.name
    target_id = "iot-air-temp"
    arn = aws_lambda_function.iot_air_temp.arn
}

resource "aws_lambda_permission" "eventbridge_invoke_iot_air_temp" {
    statement_id = "AllowExecutionFromEventbridge"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.iot_air_temp.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.every_minute.arn
}

# Lambda: iot track temp
data "archive_file" "iot_track_temp" {
  type        = "zip"
  source_dir = "${path.module}/lambdas/iot_track_temp"
  output_path = "${path.module}/lambdas/iot_track_temp/iot_track_temp.zip"
}

resource "aws_lambda_function" "iot_track_temp" {
  filename         = data.archive_file.iot_track_temp.output_path
  function_name    = "iot-track-temp"
  role             = aws_iam_role.iot_lambda_role.arn
  handler          = "iot_track_temp.handler"
  source_code_hash = data.archive_file.iot_track_temp.output_base64sha256
  runtime = "python3.9"
  timeout = 60

  layers = [
    aws_lambda_layer_version.python_layer.arn,
    var.confluent_layer_arn
    ]

  environment {
    variables = {
      SNS_TOPIC_ARN         = aws_sns_topic.iot_notifications.arn
      KAFKA_API_KEY         = var.kafka_api_key
      KAFKA_API_SECRET      = var.kafka_api_secret
      KAFKA_CLIENT_ID       = var.kafka_client_id
      KAFKA_BOOTSTRAP_SERVER = var.kafka_bootstrap_server
    }
  }
}

resource "aws_cloudwatch_event_target" "iot_track_temp" {
    rule = aws_cloudwatch_event_rule.every_minute.name
    target_id = "iot-track-temp"
    arn = aws_lambda_function.iot_track_temp.arn
}

resource "aws_lambda_permission" "eventbridge_invoke_iot_track_temp" {
    statement_id = "AllowExecutionFromEventbridge"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.iot_track_temp.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.every_minute.arn
}

# Lambda: iot humidity
data "archive_file" "iot_humidity" {
  type        = "zip"
  source_dir = "${path.module}/lambdas/iot_humidity"
  output_path = "${path.module}/lambdas/iot_humidity/iot_humidity.zip"
}

resource "aws_lambda_function" "iot_humidity" {
  filename         = data.archive_file.iot_humidity.output_path
  function_name    = "iot-humidity"
  role             = aws_iam_role.iot_lambda_role.arn
  handler          = "iot_humidity.handler"
  source_code_hash = data.archive_file.iot_humidity.output_base64sha256
  runtime = "python3.9"
  timeout = 60

  layers = [
    aws_lambda_layer_version.python_layer.arn,
    var.confluent_layer_arn
    ]

  environment {
    variables = {
      SNS_TOPIC_ARN         = aws_sns_topic.iot_notifications.arn
      KAFKA_API_KEY         = var.kafka_api_key
      KAFKA_API_SECRET      = var.kafka_api_secret
      KAFKA_CLIENT_ID       = var.kafka_client_id
      KAFKA_BOOTSTRAP_SERVER = var.kafka_bootstrap_server
    }
  }
}

resource "aws_cloudwatch_event_target" "iot_humidity" {
    rule = aws_cloudwatch_event_rule.every_minute.name
    target_id = "iot-humidity"
    arn = aws_lambda_function.iot_humidity.arn
}

resource "aws_lambda_permission" "eventbridge_invoke_iot_humidity" {
    statement_id = "AllowExecutionFromEventbridge"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.iot_humidity.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.every_minute.arn
}

# Lambda: iot air pressure
data "archive_file" "iot_air_pressure" {
  type        = "zip"
  source_dir = "${path.module}/lambdas/iot_air_pressure"
  output_path = "${path.module}/lambdas/iot_air_pressure/iot_air_pressure.zip"
}

resource "aws_lambda_function" "iot_air_pressure" {
  filename         = data.archive_file.iot_air_pressure.output_path
  function_name    = "iot-air-pressure"
  role             = aws_iam_role.iot_lambda_role.arn
  handler          = "iot_air_pressure.handler"
  source_code_hash = data.archive_file.iot_air_pressure.output_base64sha256
  runtime = "python3.9"
  timeout = 60

  layers = [
    aws_lambda_layer_version.python_layer.arn,
    var.confluent_layer_arn
    ]

  environment {
    variables = {
      SNS_TOPIC_ARN         = aws_sns_topic.iot_notifications.arn
      KAFKA_API_KEY         = var.kafka_api_key
      KAFKA_API_SECRET      = var.kafka_api_secret
      KAFKA_CLIENT_ID       = var.kafka_client_id
      KAFKA_BOOTSTRAP_SERVER = var.kafka_bootstrap_server
    }
  }
}

resource "aws_cloudwatch_event_target" "iot_air_pressure" {
    rule = aws_cloudwatch_event_rule.every_minute.name
    target_id = "iot-air-pressure"
    arn = aws_lambda_function.iot_air_pressure.arn
}

resource "aws_lambda_permission" "eventbridge_invoke_iot_air_pressure" {
    statement_id = "AllowExecutionFromEventbridge"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.iot_air_pressure.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.every_minute.arn
}

# Lambda: iot notifications to s3
data "aws_iam_policy_document" "sqs_access_s3" {
  statement {
    effect = "Allow"

    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]

    resources = [
      aws_sqs_queue.iot_notifications_s3.arn
    ]
  }
}

resource "aws_iam_role" "iot_notifications_s3_role" {
  name               = "databricks-platform-iot-notifications-s3-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "iot_notifications_s3_basic_execution" {
  role       = aws_iam_role.iot_notifications_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_sqs" {
  role = aws_iam_role.iot_notifications_s3_role.name
  policy = data.aws_iam_policy_document.sqs_access_s3.json
}

resource "aws_iam_role_policy" "lambda_s3" {
  role = aws_iam_role.iot_notifications_s3_role.name
  policy = data.aws_iam_policy_document.s3_put.json
}

data "archive_file" "iot_notifications_s3" {
  type        = "zip"
  source_dir = "${path.module}/lambdas/iot_notifications_s3"
  output_path = "${path.module}/lambdas/iot_notifications_s3/iot_notifications_s3.zip"
}

resource "aws_lambda_function" "iot_notifications_s3" {
  filename         = data.archive_file.iot_notifications_s3.output_path
  function_name    = "iot-notifications-s3"
  role             = aws_iam_role.iot_notifications_s3_role.arn
  handler          = "iot_notifications_s3.handler"
  source_code_hash = data.archive_file.iot_notifications_s3.output_base64sha256
  runtime = "python3.9"

    environment {
        variables = {
        QUEUE_NAME = aws_sqs_queue.iot_notifications_s3.name
        BUCKET_NAME = aws_s3_bucket.iot_notifications_bucket.bucket
        }
    }
}

resource "aws_lambda_event_source_mapping" "iot_notifications_sqs_lambda" {
  event_source_arn = aws_sqs_queue.iot_notifications_s3.arn
  function_name    = aws_lambda_function.iot_notifications_s3.arn
  batch_size       = 10
  enabled          = true
}

# Lambda: iot notifications to slack
data "aws_iam_policy_document" "sqs_access_slack" {
  statement {
    effect = "Allow"

    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]

    resources = [
      aws_sqs_queue.iot_notifications_slack.arn
    ]
  }
}

resource "aws_iam_role" "iot_notifications_slack_role" {
  name               = "databricks-platform-iot-notifications-slack-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "iot_notifications_lambda_basic_execution" {
  role       = aws_iam_role.iot_notifications_slack_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_sqs_slack" {
  role = aws_iam_role.iot_notifications_slack_role.name 
  policy = data.aws_iam_policy_document.sqs_access_slack.json
}

data "archive_file" "iot_notifications_slack" {
  type        = "zip"
  source_dir = "${path.module}/lambdas/iot_notifications_slack"
  output_path = "${path.module}/lambdas/iot_notifications_slack/iot_notifications_slack.zip"
}

resource "aws_lambda_function" "iot_notifications_slack" {
  filename         = data.archive_file.iot_notifications_slack.output_path
  function_name    = "iot-notifications-slack"
  role             = aws_iam_role.iot_notifications_slack_role.arn
  handler          = "iot_notifications_slack.handler"
  source_code_hash = data.archive_file.iot_notifications_slack.output_base64sha256
  runtime = "python3.9"

  layers = [aws_lambda_layer_version.python_layer.arn]

    environment {
        variables = {
        SLACK_WEBHOOK_URL = var.slack_webhook_url
        }
    }
}

resource "aws_lambda_event_source_mapping" "iot_notifications_sqs_slack" {
  event_source_arn = aws_sqs_queue.iot_notifications_slack.arn
  function_name    = aws_lambda_function.iot_notifications_slack.arn
  batch_size       = 10
  enabled          = true
}

####################################
## SNS                            ##
####################################

resource "aws_sns_topic" "iot_notifications" {
  name = "iot-notifications-topic"
}

####################################
## SQS                            ##
####################################

data "aws_iam_policy_document" "sns_sqs" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    actions = [
      "sqs:SendMessage"
    ]

    resources = [
      aws_sqs_queue.iot_notifications_s3.arn,
      aws_sqs_queue.iot_notifications_slack.arn
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.iot_notifications.arn]
    }
  }
}

# Queue 1: notifications into S3
resource "aws_sqs_queue" "iot_notifications_s3" {
  name = "iot-notifications-s3-queue"
}

resource "aws_sqs_queue_policy" "sns_sqs_s3" {
  queue_url = aws_sqs_queue.iot_notifications_s3.id
  policy    = data.aws_iam_policy_document.sns_sqs.json
}

resource "aws_sns_topic_subscription" "iot_notifications_s3" {
  topic_arn = aws_sns_topic.iot_notifications.arn
  endpoint  = aws_sqs_queue.iot_notifications_s3.arn
  protocol  = "sqs"
}

# Queue 2: notifications into Slack
resource "aws_sqs_queue" "iot_notifications_slack" {
  name = "iot-notifications-slack-queue"
}

resource "aws_sqs_queue_policy" "sns_sqs_slack" {
  queue_url = aws_sqs_queue.iot_notifications_slack.id
  policy    = data.aws_iam_policy_document.sns_sqs.json
}

resource "aws_sns_topic_subscription" "iot_notifications_slack" {
  topic_arn = aws_sns_topic.iot_notifications.arn
  endpoint  = aws_sqs_queue.iot_notifications_slack.arn
  protocol  = "sqs"
}

####################################
## ECR Repository                 ##
####################################

resource "aws_ecr_repository" "repository" {
  name                 = "${var.environment}-${var.repo_name}"
  image_tag_mutability = "MUTABLE"
  force_delete = true
}

# Use default VPC if no VPC ID is provided
data "aws_vpc" "default" {
  default = var.vpc_id == "" ? true : false
  id      = var.vpc_id != "" ? var.vpc_id : null
}

# Use default subnets if no subnet IDs are provided
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

locals {
  vpc_id     = var.vpc_id != "" ? var.vpc_id : data.aws_vpc.default.id
  subnet_ids = length(var.subnet_ids) > 0 ? var.subnet_ids : data.aws_subnets.default.ids
}


####################################
## Security Group for ECS Fargate ##
####################################

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.environment}-${var.cluster_name}-ecs-tasks-sg"
  description = "Security group for ECS Fargate tasks"
  vpc_id      = local.vpc_id

  # Allow all outbound traffic (for pulling images, accessing external services)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name        = "${var.environment}-${var.cluster_name}-ecs-tasks-sg"
    environment = var.environment
  }
}

####################################
## ECS Cluster                    ##
####################################

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name = "${var.environment}-${var.cluster_name}"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.environment}-${var.cluster_name}"

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"

      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.ecs_log_group.name
      }
    }
  }

  # Enable Container Insights for better monitoring
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Fargate capacity provider for the cluster
resource "aws_ecs_cluster_capacity_providers" "fargate" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

####################################
## ECS Task Definition            ##
####################################

resource "aws_iam_role" "execution_role" {
  // IAM role that lets ECS pull images from ECR and write to CloudWatch logs
  name = "${var.environment}-${var.cluster_name}-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "execution_role_policy" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task_role" {
  // IAM role assumed by the running container (for accessing AWS services)
  name = "${var.environment}-${var.cluster_name}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "task_policy" {
  name = "${var.environment}-${var.cluster_name}-task-policy"
  role = aws_iam_role.task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:Create*",
          "logs:Put*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_cloudwatch_log_group" "task_log_group" {
  name              = "/ecs/${var.environment}-${var.cluster_name}-task"
  retention_in_days = 30
}

resource "aws_ecs_task_definition" "task_definition" {
  family = "${var.environment}-dbt-task-definition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"  # 0.25 vCPU
  memory                   = "512"  # 512 MiB

  # IAM roles
  execution_role_arn = aws_iam_role.execution_role.arn
  task_role_arn      = aws_iam_role.task_role.arn

  container_definitions = jsonencode([
    {
      name = "dbt-container"
      image     = "${aws_ecr_repository.repository.repository_url}:${var.image_tag}"
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.task_log_group.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

####################################
## Scheduled Task                 ##
####################################

# IAM role for CloudWatch to run ECS tasks
resource "aws_iam_role" "cloudwatch_role" {
  name = "${var.environment}-${var.cluster_name}-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "cloudwatch_policy" {
  name = "${var.environment}-${var.cluster_name}-cloudwatch-policy"
  role = aws_iam_role.cloudwatch_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "ecs:RunTask"
        Effect   = "Allow"
        Resource = aws_ecs_task_definition.task_definition.arn
      },
      {
        Action   = "iam:PassRole"
        Effect   = "Allow"
        Resource = [
          aws_iam_role.execution_role.arn,
          aws_iam_role.task_role.arn
        ]
      },
    ]
  })
}

# EventBridge rule with cron schedule (daily at midnight UTC)
resource "aws_cloudwatch_event_rule" "ecs_scheduled_task" {
  name                = "${var.environment}-${var.cluster_name}-scheduled-task"
  description         = "Trigger ECS task on a daily schedule at midnight UTC"
  schedule_expression = "cron(0 0 * * ? *)"
  state               = var.is_project_live ? "ENABLED" : "DISABLED"

  tags = {
    Name        = "${var.environment}-${var.cluster_name}-scheduled-task"
    Environment = var.environment
  }
}

# EventBridge target to run the ECS task
resource "aws_cloudwatch_event_target" "ecs_scheduled_task_target" {
  rule      = aws_cloudwatch_event_rule.ecs_scheduled_task.name
  target_id = "${var.environment}-${var.cluster_name}-ecs-target"
  arn       = aws_ecs_cluster.ecs_cluster.arn
  role_arn  = aws_iam_role.cloudwatch_role.arn

  ecs_target {
    task_definition_arn = aws_ecs_task_definition.task_definition.arn
    task_count          = 1
    launch_type         = "FARGATE"

    network_configuration {
      subnets          = local.subnet_ids
      security_groups  = [aws_security_group.ecs_tasks.id]
      assign_public_ip = true
    }
  }
}

####################################
## Outputs                        ##
####################################

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.repository.repository_url
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.ecs_cluster.arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.ecs_cluster.name
}

output "task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = aws_ecs_task_definition.task_definition.arn
}

output "security_group_id" {
  description = "ID of the security group for ECS tasks"
  value       = aws_security_group.ecs_tasks.id
}

output "cloudwatch_rule_arn" {
  description = "ARN of the EventBridge rule for scheduled ECS tasks"
  value       = aws_cloudwatch_event_rule.ecs_scheduled_task.arn
}