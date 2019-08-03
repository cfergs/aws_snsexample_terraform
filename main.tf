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

resource "aws_lambda_function" "lambda" {
  function_name = "TransactionProcessor"
  runtime       = "python2.7"
  role          = "${aws_iam_role.TransactionProcessor.arn}"
  filename      = "TransactionProcessor.zip"
  handler       = "lambda_function.lambda_handler"
}
