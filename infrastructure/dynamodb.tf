resource "aws_dynamodb_table" "united_states" {
  name           = "UnitedStates"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "Id"
  range_key      = "Name"

  attribute {
    name = "Id"
    type = "S"
  }

  attribute {
    name = "Name"
    type = "S"
  }

  tags = {
    project   = "quarters"
    terraform = "true"
  }
}

