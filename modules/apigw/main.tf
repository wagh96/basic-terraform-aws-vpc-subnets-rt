resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_name
  description = var.api_description

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name        = var.api_name
    Environment = var.env
  }
}

# Resource for /path1
resource "aws_api_gateway_resource" "path_1" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "path_1"
}

# Resource for /path_1/path_2
resource "aws_api_gateway_resource" "path_2" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.path_1.id
  path_part   = "path_2"

  depends_on = [aws_api_gateway_resource.path_2]
}

# OPTIONS Method for /path_1/path_2 with mock integration
resource "aws_api_gateway_method" "path_2_options" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.path_2.id
  http_method   = "OPTIONS"
  authorization = "NONE"

  depends_on = [aws_api_gateway_resource.path_2]
}

resource "aws_api_gateway_integration" "path_2_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.path_2.id
  http_method             = aws_api_gateway_method.path_2_options.http_method
  integration_http_method = "OPTIONS"
  type                    = "MOCK"

  depends_on = [aws_api_gateway_method.path_2_options]
}

# PUT Method for /path_1/path_2 with mock integration
resource "aws_api_gateway_method" "path_2_put" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.path_2.id
  http_method   = "PUT"
  authorization = "NONE"

  depends_on = [aws_api_gateway_resource.path_2]
}

resource "aws_api_gateway_integration" "path_2_put_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.path_2.id
  http_method             = aws_api_gateway_method.path_2_put.http_method
  integration_http_method = "PUT"
  type                    = "MOCK"

  depends_on = [aws_api_gateway_method.path_2_put]
}

# Resource for /path_1/path_3
resource "aws_api_gateway_resource" "path_3" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.path_1.id
  path_part   = "path_3"

  depends_on = [aws_api_gateway_resource.path_1]
}

# GET Method for /path_1/path_3 with mock integration
resource "aws_api_gateway_method" "path_3_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.path_3.id
  http_method   = "GET"
  authorization = "NONE"

  depends_on = [aws_api_gateway_resource.path_3]
}

resource "aws_api_gateway_integration" "path_3_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.path_3.id
  http_method             = aws_api_gateway_method.path_3_get.http_method
  integration_http_method = "GET"
  type                    = "MOCK"

  depends_on = [aws_api_gateway_method.path_3_get]
}

# POST Method for /path_1/path_3 with mock integration
resource "aws_api_gateway_method" "path_3_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.path_3.id
  http_method   = "POST"
  authorization = "NONE"

  depends_on = [aws_api_gateway_resource.path_3]
}

resource "aws_api_gateway_integration" "path_3_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.path_3.id
  http_method             = aws_api_gateway_method.path_3_post.http_method
  integration_http_method = "POST"
  type                    = "MOCK"

  depends_on = [aws_api_gateway_method.path_3_post]
}

# Deployment
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = var.stage_name

  # Ensure the deployment happens after all methods are defined
  depends_on = [
    aws_api_gateway_method.path_2_options,
    aws_api_gateway_method.path_2_put,
    aws_api_gateway_method.path_3_get,
    aws_api_gateway_method.path_3_post,
  ]
}