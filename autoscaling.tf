# ./autoscaling.tf

# 起動テンプレート作成
resource "aws_launch_template" "web_launch_template" {
  name_prefix = "${var.ec2_instance_name}-lt-"
  image_id      = var.ec2_ami
  instance_type = var.ec2_instance_type
  key_name      = var.ec2_key_pair
  
  # インスタンスプロファイルを適用
  iam_instance_profile {
    name = aws_iam_instance_profile.cloudwatch_instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.asg_sg.id]
  }

  # user_dataスクリプト参照
  user_data = base64encode(templatefile("${path.module}/scripts/fetch_cloudwatch_config.sh", {}))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.ec2_instance_name}"
    }
  }
}

# オートスケール設定
resource "aws_autoscaling_group" "web_asg" {
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  vpc_zone_identifier = aws_subnet.public_subnets[*].id
  launch_template {
    id      = aws_launch_template.web_launch_template.id
    version = "$Latest"
  }

  tag {
    key   = "Name"
    value = "${var.ec2_instance_name}"
    propagate_at_launch = true
  }
}