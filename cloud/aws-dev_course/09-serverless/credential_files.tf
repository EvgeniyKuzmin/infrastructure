locals {
  credential_file     = ".env.development"
  credentials_db_file = ".env.db.development"
}

resource "local_file" "credentials_env" {
  filename = "${local.app_path}/${local.credential_file}"
  content = templatefile(
    "${path.module}/templates/${local.credential_file}",
    {
      db_host       = local.db_host
      db_name       = local.app_name
      db_user       = local.db_username
      db_password   = random_password.db_password.result
      flask_secret  = random_password.app_secret.result
      aws_region    = var.region
      bucket_name   = aws_s3_bucket.images.id
      bucket_prefix = "${local.fs_public_prefix}/"
      sqs_name      = aws_sqs_queue.uploads_notification.name
      ssn_arn       = aws_sns_topic.uploads_notification.id
    }
  )
}

resource "local_file" "credentials_db_env" {
  filename = "${local.app_path}/${local.credentials_db_file}"
  content = templatefile(
    "${path.module}/templates/${local.credentials_db_file}",
    {
      db_name     = local.app_name
      db_user     = local.db_username
      db_password = random_password.db_password.result
    }
  )
}
