# ./iam.tf

# IAMロールを作成
resource "aws_iam_role" "cloudwatch_agent_role" {
  name = "CloudWatchAgentRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# IAMロールにポリシーをアタッチ：
## cloudwatch-Logsへのログ送信用
resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.cloudwatch_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

## SSMパラメータストア接続用
resource "aws_iam_role_policy_attachment" "ssm_access" {
  role       = aws_iam_role.cloudwatch_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

# IAMロールをインスタンスプロファイルとして定義
resource "aws_iam_instance_profile" "cloudwatch_instance_profile" {
  name = "CloudWatchInstanceProfile"
  role = aws_iam_role.cloudwatch_agent_role.name
}