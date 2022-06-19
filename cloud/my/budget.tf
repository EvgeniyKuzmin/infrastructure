resource "aws_budgets_budget" "total" {
  name              = "${local.prefix}-total"
  budget_type       = "COST"
  limit_amount      = 10
  limit_unit        = "USD"
  time_period_start = "2022-06-13_00:00"
  time_unit         = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.email]
  }
}

resource "aws_budgets_budget" "s3" {
  name         = "${local.prefix}-s3"
  budget_type  = "USAGE"
  limit_amount = 5
  limit_unit   = "GB"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.email]
  }
}
