# ./outputs.tf

#------------------------
# VPC
output "vpc_info" {
  value = {
    vpc_id              = aws_vpc.vpc03.id
    public_subnets_ids  = aws_subnet.public_subnets[*].id
  }
}


#------------------------
# Security Group
output "security_group_info" {
  value = {
    asg_sg = {
      id   = aws_security_group.asg_sg.id
      name = aws_security_group.asg_sg.name
      description = aws_security_group.asg_sg.description
    }
  }
}

#------------------------
# Launch Template
output "launch_template_info" {
  value = {
    id      = aws_launch_template.web_launch_template.id
    version = aws_launch_template.web_launch_template.latest_version
  }
}

#------------------------
# Auto ScalingGroup
output "asg_info" {
  value = {
    name               = aws_autoscaling_group.web_asg.name
    arn                = aws_autoscaling_group.web_asg.arn
    desired_capacity   = aws_autoscaling_group.web_asg.desired_capacity
    max_size           = aws_autoscaling_group.web_asg.max_size
    min_size           = aws_autoscaling_group.web_asg.min_size
  }
}

#------------------------
# IAM Role and Instance Profile
output "iam_role_info" {
  value = {
    role_name         = aws_iam_role.cloudwatch_agent_role.name
    role_arn          = aws_iam_role.cloudwatch_agent_role.arn
    instance_profile  = aws_iam_instance_profile.cloudwatch_instance_profile.name
  }
}

#------------------------
# CloudWatch Log Groups
output "cloudwatch_log_groups" {
  value = {
    http_access_log = {
      name            = aws_cloudwatch_log_group.http_access_log.name
      arn             = aws_cloudwatch_log_group.http_access_log.arn
      retention_days  = aws_cloudwatch_log_group.http_access_log.retention_in_days
    }
    http_error_log = {
      name            = aws_cloudwatch_log_group.http_error_log.name
      arn             = aws_cloudwatch_log_group.http_error_log.arn
      retention_days  = aws_cloudwatch_log_group.http_error_log.retention_in_days
    }
  }
}

#------------------------
# SSM Parameter Store
output "ssm_parameter_info" {
  value = {
    parameter_name  = aws_ssm_parameter.cloudwatch_config.name
    parameter_type  = aws_ssm_parameter.cloudwatch_config.type
  }
}