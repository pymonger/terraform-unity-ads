data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "vpc_id" {
  name = "/unity/account/network/vpc_id"
}

data "aws_ssm_parameter" "subnet_list" {
  name = "/unity/account/network/subnet_list"
}

data "aws_ssm_parameter" "ami_id" {
  name = "/mcp/amis/aml2-eks-1-30"
}

data "external" "current_ip" {
  program = ["./get_ip.sh"]
}
