resource "aws_lambda_function" "api" {
  description      = "Symptom Checker API for ${local.namespace}"
  function_name    = local.api_name
  role             = aws_iam_role.lambda.arn
  runtime          = "nodejs14.x"
  filename         = local.api_build_zip
  source_code_hash = filebase64sha256(local.api_build_zip)
  handler          = "lambda.handler"
  memory_size      = 512
  timeout          = 30

  vpc_config {
    security_group_ids = [module.network.aws_security_groups.app.id]
    subnet_ids         = module.network.aws_subnet_ids.app.ids
  }

  environment {
    variables = {
      TARGET_ENV  = var.target_env
      RUNTIME_ENV = "hosted"
    }
  }
}

resource "aws_apigatewayv2_api" "api" {
  name          = local.api_name
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "api" {
  api_id             = aws_apigatewayv2_api.api.id
  integration_type   = "AWS_PROXY"
  connection_type    = "INTERNET"
  description        = local.api_name
  integration_method = "POST"
  integration_uri    = aws_lambda_function.api.invoke_arn
}

resource "aws_apigatewayv2_route" "api" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.api.id}"
}

locals {
  api_gateway_log_format_with_newlines = <<EOF
{ 
"requestId":"$context.requestId",
"ip":"$context.identity.sourceIp",
"requestTime":"$context.requestTime",
"httpMethod":"$context.httpMethod",
"status":"$context.status",
"path":"$context.path",
"responseLength":"$context.responseLength",
"errorMessage":"$context.error.message"
}
EOF
  api_gateway_log_format               = replace(local.api_gateway_log_format_with_newlines, "\n", "")
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name = "api-gw/${local.api_name}/logs"

  lifecycle {
    ignore_changes = [
      retention_in_days
    ]
  }
}

resource "aws_apigatewayv2_stage" "api" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format          = local.api_gateway_log_format
  }
}

resource "aws_lambda_permission" "api_allow_gateway" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_stage.api.execution_arn}/*"
}