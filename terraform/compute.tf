module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.7.0"

  name                        = var.ec2_name
  ami                         = data.aws_ami.aws_ami_data.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.azmi1-tf-sg-allow-ssh-http-https.id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  ebs_optimized               = true

  tags = {
    Name = var.ec2_name
  }
  #checkov:skip=CKV2_AWS_41:Skip IAM role
  #checkov:skip=CKV_AWS_8:No launch configuration
}