provider "aws" {
  region = "ap-southeast-2"
}

# S3
resource "aws_s3_bucket" "weather_data_bucket" {
  bucket = "snowflake-platform-weather-data"
}

resource "aws_s3_bucket" "weather_data_notifications_bucket" {
  bucket = "snowflake-platform-weather-data-notifications"
}

# Lambda
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

# Lambda 1: weather Data
data "aws_iam_policy_document" "sns_publish" {
  statement {
    effect = "Allow"

    actions = [
      "sns:Publish"
    ]

    resources = [
      aws_sns_topic.weather_data.arn
    ]
  }
}

resource "aws_iam_role" "weather_data_lambda_role" {
  name               = "snowflake-platform-weather-data-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "weather_data_basic_execution" {
  role       = aws_iam_role.weather_data_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_sns_publish" {
  role = aws_iam_role.weather_data_lambda_role.name    
  policy = data.aws_iam_policy_document.sns_publish.json
}

data "archive_file" "weather_data" {
  type        = "zip"
  source_file = "${path.module}/lambdas/weather_data.py"
  output_path = "${path.module}/lambdas/weather_data.py.zip"
}

resource "aws_lambda_function" "weather_data" {
  filename         = data.archive_file.weather_data.output_path
  function_name    = "weather-data"
  role             = aws_iam_role.weather_data_lambda_role.arn
  handler          = "weather_data.handler"
  source_code_hash = data.archive_file.weather_data.output_base64sha256
  runtime = "python3.10"

    environment {
        variables = {
        SNS_TOPIC_ARN = aws_sns_topic.weather_data.arn
        }
    }
}

resource "aws_cloudwatch_event_rule" "every_minute" {
    name = "every-minute"
    description = "Fires every minute"
    schedule_expression = "rate(1 minute)"
    state = "DISABLED"
}

resource "aws_cloudwatch_event_target" "weather_data" {
    rule = aws_cloudwatch_event_rule.every_minute.name
    target_id = "weather-data-target"
    arn = aws_lambda_function.weather_data.arn
}

resource "aws_lambda_permission" "eventbridge_invoke_weather_data" {
    statement_id = "AllowExecutionFromEventbridge"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.weather_data.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.every_minute.arn
}

# Lambda 2: weather Data Notifications
data "aws_iam_policy_document" "sqs_handle_messages" {
  statement {
    effect = "Allow"

    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]

    resources = [
      aws_sqs_queue.weather_data_notifications.arn
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
      "${aws_s3_bucket.weather_data_notifications_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_role" "weather_data_notifications_lambda_role" {
  name               = "snowflake-platform-weather-data-notifications-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "weather_data_notifications_basic_execution" {
  role       = aws_iam_role.weather_data_notifications_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_sqs_handle_messages" {
  role = aws_iam_role.weather_data_notifications_lambda_role.name 
  policy = data.aws_iam_policy_document.sqs_handle_messages.json
}

resource "aws_iam_role_policy" "lambda_s3_put" {
  role = aws_iam_role.weather_data_notifications_lambda_role.name 
  policy = data.aws_iam_policy_document.s3_put.json
}

data "archive_file" "weather_data_notifications" {
  type        = "zip"
  source_file = "${path.module}/lambdas/weather_data_notifications.py"
  output_path = "${path.module}/lambdas/weather_data_notifications.py.zip"
}

resource "aws_lambda_function" "weather_data_notifications" {
  filename         = data.archive_file.weather_data_notifications.output_path
  function_name    = "weather-data-notifications"
  role             = aws_iam_role.weather_data_notifications_lambda_role.arn
  handler          = "weather_data_notifications.handler"
  source_code_hash = data.archive_file.weather_data_notifications.output_base64sha256
  runtime = "python3.10"

    environment {
        variables = {
        QUEUE_NAME = aws_sqs_queue.weather_data_notifications.name
        BUCKET_NAME = aws_s3_bucket.weather_data_notifications_bucket.bucket
        }
    }
}

resource "aws_lambda_event_source_mapping" "weather_data_notifications_sqs" {
  event_source_arn = aws_sqs_queue.weather_data_notifications.arn
  function_name    = aws_lambda_function.weather_data_notifications.arn
  batch_size       = 10          # Number of messages per invocation
  enabled          = true
}

# SNS
resource "aws_sns_topic" "weather_data" {
  name = "weather-data-topic"
}

# SQS
resource "aws_sqs_queue" "weather_data_notifications" {
  name = "weather-data-notifications-queue"
}

data "aws_iam_policy_document" "sns_send_message_to_sqs" {
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
      aws_sqs_queue.weather_data_notifications.arn
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.weather_data.arn]
    }
  }
}

resource "aws_sqs_queue_policy" "sns_send_message_to_sqs" {
  queue_url = aws_sqs_queue.weather_data_notifications.id
  policy    = data.aws_iam_policy_document.sns_send_message_to_sqs.json
}

resource "aws_sns_topic_subscription" "weather_data_notifications" {
  topic_arn = aws_sns_topic.weather_data.arn
  endpoint  = aws_sqs_queue.weather_data_notifications.arn
  protocol  = "sqs"
}
