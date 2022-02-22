locals {
  hdl_purpose = "${local.app_name}-uploads-batch-notifier"
  hdl_name    = "${var.project_name}-${local.hdl_purpose}"
  hdl_tags    = merge(local.tags, {
    "Purpose" = local.hdl_purpose
  })
  code_path = "${path.module}/code/uploads-batch-notifier"
  logs_path = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}"
}


## LAMBDA #####################################################################

data "archive_file" "code" {
  type        = "zip"
  source_dir = local.code_path
  output_path = "${local.code_path}.zip"
}

resource "aws_lambda_function" "batch_notifier" {
  description      = "Transferring SQS messages to SNS"
  filename         = "${local.code_path}.zip"
  function_name    = local.hdl_name
  role             = aws_iam_role.lambda.arn
  handler          = "notifier.__main__.handler"
  source_code_hash = data.archive_file.code.output_base64sha256
  runtime          = "python3.8"
  timeout          = 3
  tags             = local.hdl_tags

  environment {
    variables = {
      SQS_NAME = aws_sqs_queue.uploads_notification.name
      SNS_ARN  = aws_sns_topic.uploads_notification.id
    }
  }
}


## ROLE #######################################################################

resource "aws_iam_role" "lambda" {
  name = "${var.project_name}-${local.hdl_purpose}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
  tags = local.hdl_tags
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_logs" {
  policy_id = "cloudwatch"
  statement {
    actions = ["logs:CreateLogGroup"]
    resources = ["${local.logs_path}:*"]
  }
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["${local.logs_path}:log-group:/aws/lambda/${local.hdl_name}*"]
  }
}
resource "aws_iam_role_policy" "lambda_logs" {
  role   = aws_iam_role.lambda.id
  name   = data.aws_iam_policy_document.lambda_logs.policy_id
  policy = data.aws_iam_policy_document.lambda_logs.json
}


data "aws_iam_policy_document" "lambda_sqs" {
  policy_id = "sqs"
  statement {
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage",
    ]
    resources = [aws_sqs_queue.uploads_notification.arn]
  }
}
resource "aws_iam_role_policy" "lambda_sqs" {
  role   = aws_iam_role.lambda.id
  name   = data.aws_iam_policy_document.lambda_sqs.policy_id
  policy = data.aws_iam_policy_document.lambda_sqs.json
}


data "aws_iam_policy_document" "lambda_sns" {
  policy_id = "sns"
  statement {
    actions = ["sns:Publish"]
    resources = [aws_sns_topic.uploads_notification.arn]
  }
}
resource "aws_iam_role_policy" "lambda_sns" {
  role   = aws_iam_role.lambda.id
  name   = data.aws_iam_policy_document.lambda_sns.policy_id
  policy = data.aws_iam_policy_document.lambda_sns.json
}


## PERIODICALLY RUNS ##########################################################

resource "aws_cloudwatch_event_rule" "periodic_sqs_drain" {
  description         = "Periodically runs ${local.hdl_name} Lambda"
  name                = local.hdl_name
  schedule_expression = "rate(5 minutes)"
  tags                = local.hdl_tags
}

resource "aws_cloudwatch_event_target" "periodic_sqs_drain" {
  target_id = local.hdl_name
  rule      = aws_cloudwatch_event_rule.periodic_sqs_drain.name
  arn       = aws_lambda_function.batch_notifier.arn
}

resource "aws_lambda_permission" "periodic_sqs_drain" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.batch_notifier.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.periodic_sqs_drain.arn
}


## HTTP API ###################################################################

resource "aws_apigatewayv2_api" "lambda" {
  name          = "${local.hdl_name}-gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = "${local.hdl_name}-gw-stage"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.batch_notifier.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "hello_world" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /hello"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.batch_notifier.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}
