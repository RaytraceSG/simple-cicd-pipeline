resource "aws_instance" "ec2_example" {
  ami           = data.aws_ami.aws_ami_data.id
  instance_type = "t3.micro"
  ebs_optimized = true
  monitoring    = true
  metadata_options {
    http_endpoint = "disabled"
  }
  tags = {
    Name = "azmi1-terraform-ec2-cicd"
  }
  #checkov:skip=CKV2_AWS_41:Skip IAM role
  #checkov:skip=CKV_AWS_8:No launch configuration
}

data "aws_ami" "aws_ami_data" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

}