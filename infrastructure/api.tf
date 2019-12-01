resource "aws_api_gateway_rest_api" "quarters" {
  name        = "quarters"
  description = "United States Quarters"

  tags {
    project   = "quarters"
    terraform = "true"
  }
}

resource "aws_api_gateway_resource" "states" {
  rest_api_id = "${aws_api_gateway_rest_api.quarters.id}"
  parent_id   = "${aws_api_gateway_rest_api.quarters.root_resource_id}"
  path_part   = "states"
}

resource "aws_api_gateway_method" "states" {
  rest_api_id   = "${aws_api_gateway_rest_api.quarters.id}"
  resource_id   = "${aws_api_gateway_resource.states.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "states" {
  rest_api_id = "${aws_api_gateway_rest_api.quarters.id}"
  resource_id = "${aws_api_gateway_method.states.resource_id}"
  http_method = "${aws_api_gateway_method.states.http_method}"

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.quarters.invoke_arn}"
}

resource "aws_api_gateway_method_response" "states_200" {
  rest_api_id = "${aws_api_gateway_rest_api.quarters.id}"
  resource_id = "${aws_api_gateway_resource.states.id}"
  http_method = "${aws_api_gateway_method.states.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_stage" "quarters_test" {
  stage_name    = "test"
  rest_api_id   = "${aws_api_gateway_rest_api.quarters.id}"
  deployment_id = "${aws_api_gateway_deployment.quarters.id}"

  tags {
    terraform = "true"
  }
}

resource "aws_api_gateway_deployment" "quarters" {
  depends_on = [
    "aws_api_gateway_integration.states",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.quarters.id}"
  stage_name  = "test"
}

