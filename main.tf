provider "aws" {
  region                  = "ap-southeast-2"
  shared_credentials_file = "./credentials"
  profile                 = "terraform"
}

#creates random value for storage group and cognito
resource "random_id" "name"	{
	byte_length = "4"
}

resource "aws_s3_bucket" "bucket" {
  bucket        = "bucket-${random_id.name.dec}"
  acl           = "private"
  force_destroy = true #Forcably delete the bucket & contents if i run terraform destroy
}

resource "aws_lambda_function" "transactionprocessor" {
  function_name = "TransactionProcessor"
  description   = "Process data and send to DynamoDB tables"
  runtime       = "python2.7"
  role          = "${aws_iam_role.TransactionProcessor.arn}"
  filename      = "TransactionProcessor.zip"
  handler       = "lambda_function.lambda_handler"
  timeout       = "20"
}

resource "aws_lambda_function" "totalnotifier" {
  function_name = "TotalNotifier"
  description   = "Update total, send notification for balance exceeding $1500"
  runtime       = "python2.7"
  role          = "${aws_iam_role.TotalNotifier.arn}"
  filename      = "TotalNotifier.zip"
  handler       = "lambda_function.lambda_handler"
  timeout       = "20"
}

#lambda to grant access to S3
resource "aws_lambda_permission" "lambdaS3_permission" {
  depends_on    = ["aws_lambda_function.transactionprocessor"]
  statement_id  = "AllowWildrydesAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.transactionprocessor.function_name}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.bucket.arn}"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket      = "${aws_s3_bucket.bucket.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.transactionprocessor.arn}"
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_event_source_mapping" "dynamodb_transactions" {
  event_source_arn  = "${aws_dynamodb_table.transactions.stream_arn}"
  function_name     = "${aws_lambda_function.totalnotifier.arn}"
  starting_position = "LATEST"
}