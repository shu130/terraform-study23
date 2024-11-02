# ./cloudwatch.tf

# CloudWatchエージェントのログ送信先：
## 1.アクセスロググループ
resource "aws_cloudwatch_log_group" "http_access_log" {
  name              = "HttpAccessLog"
  retention_in_days = 7
}

## 2. エラーロググループ
resource "aws_cloudwatch_log_group" "http_error_log" {
  name              = "HttpErrorLog"
  retention_in_days = 7
}
