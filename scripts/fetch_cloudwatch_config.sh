#!/bin/bash

# Apacheのインストールと起動
echo "Starting Apache installation..." | tee -a /var/log/user_data.log
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "Apache installed and started." | tee -a /var/log/user_data.log

# CloudWatchエージェントのインストール
echo "Installing CloudWatch Agent..." | tee -a /var/log/user_data.log
yum install -y amazon-cloudwatch-agent
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to install CloudWatch Agent." | tee -a /var/log/user_data.log
    exit 1
fi
echo "CloudWatch Agent installed." | tee -a /var/log/user_data.log

# jqのインストール
echo "Installing jq..." | tee -a /var/log/user_data.log
if ! command -v jq &> /dev/null; then
    yum install -y jq
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to install jq." | tee -a /var/log/user_data.log
        exit 1
    fi
fi
echo "jq installed." | tee -a /var/log/user_data.log

# インスタンスIDの取得
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
echo "Instance ID is $INSTANCE_ID" | tee -a /var/log/user_data.log

# CloudWatchエージェント設定ディレクトリの確認・作成
CONFIG_DIR="/opt/aws/amazon-cloudwatch-agent/etc"
if [[ ! -d "$CONFIG_DIR" ]]; then
    echo "Creating CloudWatch Agent config directory..." | tee -a /var/log/user_data.log
    sudo mkdir -p $CONFIG_DIR
fi

# Apacheのログディレクトリの権限修正
echo "Adjusting permissions for Apache log directory..." | tee -a /var/log/user_data.log
sudo chown -R cwagent:cwagent /var/log/httpd/
sudo chmod -R 644 /var/log/httpd/*
echo "Permissions adjusted for Apache logs." | tee -a /var/log/user_data.log

# SSMパラメータストアからCloudWatch設定を取得
echo "Fetching CloudWatch configuration from SSM Parameter Store..." | tee -a /var/log/user_data.log
aws ssm get-parameter \
  --name "AmazonCloudWatch-ForwardProxy" \
  --query "Parameter.Value" \
  --output text \
  --region "us-west-2" \
  | jq --arg id "$INSTANCE_ID" '.logs.logs_collected.files.collect_list[] |= (.log_stream_name = $id)' \
  | sudo tee $CONFIG_DIR/amazon-cloudwatch-agent.json > /dev/null

if [[ $? -ne 0 ]]; then
    echo "Error: Failed to retrieve or save CloudWatch configuration." | tee -a /var/log/user_data.log
    exit 1
fi
echo "CloudWatch configuration retrieved and saved." | tee -a /var/log/user_data.log

# CloudWatchエージェントの起動
echo "Starting CloudWatch Agent..." | tee -a /var/log/user_data.log
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -s -c file:$CONFIG_DIR/amazon-cloudwatch-agent.json
if [[ $? -eq 0 ]]; then
    echo "CloudWatch Agent started successfully." | tee -a /var/log/user_data.log
else
    echo "Error: Failed to start CloudWatch Agent." | tee -a /var/log/user_data.log
    exit 1
fi
