variable "sqs-queues" {
  description = "list of SQS message queues to create" 
  type        = list(string)
  default     = ["CreditCollection","CustomerNotify"]
}