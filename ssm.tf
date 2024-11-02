# ./ssm.tf

# SSMパラメータストアへCloudWatchエージェントの設定情報を保存
resource "aws_ssm_parameter" "cloudwatch_config" {
  name  = "AmazonCloudWatch-ForwardProxy"
  type  = "String"
  value = jsonencode({
    logs = {
      logs_collected = {
        files = {
          collect_list = [
            {
              file_path        = "/var/log/messages"
              log_group_name   = "var-log-messages"
              log_stream_name  = "{instance_id}"
              timestamp_format = "%b %d %H:%M:%S"
            },
            {
              file_path        = "/var/log/httpd/access_log"
              log_group_name   = "HttpAccessLog"
              log_stream_name  = "{instance_id}"
              timestamp_format = "%b %d %H:%M:%S"
            },
            {
              file_path        = "/var/log/httpd/error_log"
              log_group_name   = "HttpErrorLog"
              log_stream_name  = "{instance_id}"
              timestamp_format = "%b %d %H:%M:%S"
            }
          ]
        }
      }
    }
  })
}