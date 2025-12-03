provider "aws" {
  region = "ap-southeast-2"
}

# S3
resource "aws_s3_bucket" "iot_bucket_air_temp" {
  bucket = "databricks-platform-iot-air-temp"
}

resource "aws_s3_bucket" "iot_bucket_track_temp" {
  bucket = "databricks-platform-iot-track-temp"
}

resource "aws_s3_bucket" "iot_bucket_humidity" {
  bucket = "databricks-platform-iot-humidity"
}

resource "aws_s3_bucket" "iot_bucket_air_pressure" {
  bucket = "databricks-platform-iot-air-pressure"
}

resource "aws_s3_bucket" "iot_notifications_bucket" {
  bucket = "databricks-platform-iot-notifications"
}

resource "aws_s3_bucket_public_access_block" "iot_bucket_air_temp_block" {
  bucket = aws_s3_bucket.iot_bucket_air_temp.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_public_access_block" "iot_bucket_track_temp_block" {
  bucket = aws_s3_bucket.iot_bucket_track_temp.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_public_access_block" "iot_bucket_humidity_block" {
  bucket = aws_s3_bucket.iot_bucket_humidity.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_public_access_block" "iot_bucket_air_pressure_block" {
  bucket = aws_s3_bucket.iot_bucket_air_pressure.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Lambdas
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
  output_path = "${path.module}/lambdas/iot/iot_air_temp.zip"
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
    "arn:aws:lambda:ap-southeast-2:851886554434:layer:confluent_layer:2" # Layer for confluent-kafka library
    ]

  environment {
    variables = {
      SNS_TOPIC_ARN         = aws_sns_topic.iot_notifications.arn
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

# SNS
resource "aws_sns_topic" "iot_notifications" {
  name = "iot-notifications-topic"
}

# SQS
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