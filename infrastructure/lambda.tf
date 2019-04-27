resource "aws_cloudwatch_log_group" "quarters" {
  name = "/aws/lambda/quarters"

  tags {
    terraform = "true"
  }
}

resource "aws_iam_policy" "quarters" {
  name        = "quarters"
  description = "Access for Quarters Lambda function"
  path        = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.quarters.name}:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:PutMetricData"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "quarters" {
  name        = "quarters"
  description = "Runtime role for Quarters Lambda function"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "quarters" {
  role       = "quarters"
  policy_arn = "${aws_iam_policy.quarters.arn}"
}


resource "aws_lambda_function" "quarters" {
  function_name = "quarters"
  role          = "${aws_iam_role.quarters.arn}"
  handler       = "lambda.handler"
  runtime       = "python3.7"
  memory_size   = "128"
  timeout       = "30"
  filename      = "../src/lambda/lambda.zip"

  tags {
    terraform = "true"
  }
}

resource "aws_lambda_permission" "quarters" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.quarters.arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.quarters.execution_arn}/*/*"
}

