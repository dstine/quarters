resource "aws_resourcegroups_group" "quarters" {
  name = "quarters"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "project",
      "Values": ["quarters"]
    }
  ]
}
JSON
  }

  tags = {
    project   = "quarters"
    terraform = true
  }
}

