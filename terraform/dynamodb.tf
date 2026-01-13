# DynamoDB Tables
resource "aws_dynamodb_table" "users" {
  name           = "${var.project_name}-users"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  global_secondary_index {
    name     = "email-index"
    hash_key = "email"
  }

  tags = {
    Name = "${var.project_name}-users"
  }
}

resource "aws_dynamodb_table" "donors" {
  name           = "${var.project_name}-donors"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "bloodType"
    type = "S"
  }

  global_secondary_index {
    name     = "bloodType-index"
    hash_key = "bloodType"
  }

  tags = {
    Name = "${var.project_name}-donors"
  }
}

resource "aws_dynamodb_table" "requests" {
  name           = "${var.project_name}-requests"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "status"
    type = "S"
  }

  global_secondary_index {
    name     = "status-index"
    hash_key = "status"
  }

  tags = {
    Name = "${var.project_name}-requests"
  }
}

resource "aws_dynamodb_table" "inventory" {
  name           = "${var.project_name}-inventory"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "bloodType"

  attribute {
    name = "bloodType"
    type = "S"
  }

  tags = {
    Name = "${var.project_name}-inventory"
  }
}
