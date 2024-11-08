resource "aws_instance" "ec2_example" {
  ami                    = data.aws_ami.aws_ami_data.id
  key_name               = "azmi1-keypair-useast1"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.azmi1-tf-sg-allow-ssh-http-https.id]
  subnet_id              = module.vpc.public_subnets[0]
  instance_type          = "t3.micro"
  ebs_optimized          = true
  metadata_options {
    http_endpoint = "disabled"
  }
  tags = {
    Name = "azmi1-terraform-ec2-cicd"
  }
  #checkov:skip=CKV2_AWS_41:Skip IAM role
  #checkov:skip=CKV_AWS_8:No launch configuration
}