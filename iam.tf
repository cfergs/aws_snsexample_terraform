resource "aws_iam_role" "TransactionProcessor" {
  name                  = "TransactionProcessorRole"
  description           = "TransactionProcessorRole"
  force_detach_policies = true
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "roleattach1" {
  role        = "${aws_iam_role.TransactionProcessor.name}"
  policy_arn  = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "roleattach2" {
  role        = "${aws_iam_role.TransactionProcessor.name}"
  policy_arn  = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_policy" "CWLogsPolicy" {
  name = "CWLogsPolicy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "roleattachCWS" {
  role        = "${aws_iam_role.TransactionProcessor.name}"
  policy_arn  = "${aws_iam_policy.CWLogsPolicy.arn}"
}


resource "aws_iam_role" "TotalNotifier" {
  name                  = "TotalNotifierRole"
  description           = "TotalNotifierRole"
  force_detach_policies = true
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "StreamsPolicy" {
  name = "StreamsPolicy"
  role = "${aws_iam_role.TotalNotifier.name}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:GetRecords",
        "dynamodb:GetShardIterator",
        "dynamodb:DescribeStream",
        "dynamodb:ListStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "roleattachCWS2" {
  role        = "${aws_iam_role.TotalNotifier.name}"
  policy_arn  = "${aws_iam_policy.CWLogsPolicy.arn}"
}

resource "aws_iam_role_policy_attachment" "TotalNotifierSNS" {
  role        = "${aws_iam_role.TotalNotifier.name}"
  policy_arn  = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

resource "aws_iam_role_policy_attachment" "TotalNotifierDynamo" {
  role        = "${aws_iam_role.TotalNotifier.name}"
  policy_arn  = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}