#Create Dynamo database
resource "aws_dynamodb_table" "customer" {
  name           = "Customer"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "CustomerId"

  attribute {
    name = "CustomerId"
    type = "S"
  }
}

resource "aws_dynamodb_table" "transactions" {
  name           = "Transactions"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "CustomerId"
  range_key      = "TransactionId"

  attribute {
    name = "CustomerId"
    type = "S"
  }

  attribute {
    name = "TransactionId"
    type = "S"
  }

  stream_enabled    = true
  stream_view_type  = "NEW_IMAGE"
}

resource "aws_dynamodb_table" "transtotal" {
  name           = "TransactionTotal"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "CustomerId"

  attribute {
    name = "CustomerId"
    type = "S"
  }
}