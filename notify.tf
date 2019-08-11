resource "aws_sqs_queue" "CreditCollection" {
  name  = "CreditCollection"
}

resource "aws_sqs_queue" "CustomerNotify" {
  name  = "CustomerNotify"
}

resource "aws_sns_topic" "HighBalanceAlert" {
  name  = "HighBalanceAlert"
  display_name = "HighAlert"
}

resource "aws_sns_topic_subscription" "HighBalanceAlert2CreditCollection" {
  topic_arn = "${aws_sns_topic.HighBalanceAlert.arn}"
  protocol  = "sqs"
  endpoint  = "${aws_sqs_queue.CreditCollection.arn}"
}

resource "aws_sns_topic_subscription" "HighBalanceAlert2CustomerNotify" {
  topic_arn = "${aws_sns_topic.HighBalanceAlert.arn}"
  protocol  = "sqs"
  endpoint  = "${aws_sqs_queue.CustomerNotify.arn}"
}