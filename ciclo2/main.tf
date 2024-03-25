# Tabla de DynamoDB
resource "aws_dynamodb_table" "db" {
  name           = "${var.common_name}-db"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }

  tags = {
    Environment = var.env
  }
}

output "db-arn" {
  value = aws_dynamodb_table.db.arn
}

#IAM Role y Policy
data "aws_iam_policy_document" "lambda_document" {
	statement {
		sid    = "testPolicyId"
		effect = "Allow"
		principals {
			identifiers = ["lambda.amazonaws.com"]
			type        = "Service"
		}
		actions = ["sts:AssumeRole"]
	}
}

resource "aws_iam_role" "lambda_role" {
	name               = "lambda_test_role"
	assume_role_policy = data.aws_iam_policy_document.lambda_document.json
}

resource "aws_iam_policy" "iam_policy_for_lambda" {

  name        = "aws_iam_policy_for_terraform_aws_lambda_role"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy      = <<EOF
{
"Version": "2012-10-17",
"Statement": [
    {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": [
            "dynamodb:PutItem",
            "dynamodb:DeleteItem",
            "dynamodb:GetItem",
            "dynamodb:Scan",
            "dynamodb:Query",
            "dynamodb:UpdateItem"
        ],
        "Resource": "${aws_dynamodb_table.db.arn}"
    }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

#Función Lambda

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/python/lambda_function.py"
  output_path = "lambda_function.zip"
}

resource "aws_lambda_function" "test_lambda" {

  filename      = "lambda_function.zip"
  function_name = "${var.common_name}-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.test"
  runtime       = "python3.8"
  depends_on    = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
  environment {
    variables = {
      Environment = var.env
    }
  }
}

#API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "${var.common_name}-API"

}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "lambda"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.test_lambda.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${var.accountID}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
}

resource "aws_api_gateway_deployment" "deploy" {
  depends_on  = [aws_api_gateway_integration.integration]
  rest_api_id = aws_api_gateway_rest_api.api.id

}

# Creación de AWS Amplify, servira para mostrar la página en la internet pública
resource "aws_amplify_app" "front" {
  name                     = "${var.common_name}-app"
  repository               = var.repo
  access_token             = var.gh_token
  enable_branch_auto_build = true

  build_spec = <<-EOT
    version: 0.1
    frontend:
      phases:
        build:
          commands: []
      artifacts:
        baseDirectory: /ciclo2/HTML
        files:
          - '**/*'
      cache:
        paths: []
      
  EOT


  environment_variables = {
    ENV    = var.env
    apiURL = aws_api_gateway_deployment.deploy.invoke_url
  }
}