resource "aws_sns_topic" "HighBalanceAlert" {
  name  = "HighBalanceAlert"
  display_name = "HighAlert"
}

/*
Create SQS queues..
1. Create queue itself
2. Define queue policy granting sendmessage access from SNS topic
3. Subscribe SNS topic to SQS
*/

resource "aws_sqs_queue" "queue" {
  count = "${length(var.sqs-queues)}"
  name  = "${var.sqs-queues[count.index]}"
}

resource "aws_sqs_queue_policy" "queue-policy" {
  count     = "${length(var.sqs-queues)}"
  queue_url = "${aws_sqs_queue.queue[count.index].id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.queue[count.index].arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.HighBalanceAlert.arn}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_sns_topic_subscription" "sns-subscription" {
  count     = "${length(var.sqs-queues)}"
  topic_arn = "${aws_sns_topic.HighBalanceAlert.arn}"
  protocol  = "sqs"
  endpoint  = "${aws_sqs_queue.queue[count.index].arn}"
}