module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.15.0"

  name = "${var.name_prefix}-vpc-${terraform.workspace}"
  cidr = "10.0.0.0/16"

  azs                  = ["us-east-1a", "us-east-1b"]
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_names = ["${var.name_prefix}-tf-private-subnet-az1-${terraform.workspace}", "${var.name_prefix}-tf-private-subnet-az2-${terraform.workspace}"]
  public_subnets       = ["10.0.101.0/24", "10.0.102.0/24"]
  public_subnet_names  = ["${var.name_prefix}-tf-public-subnet-az1-${terraform.workspace}", "${var.name_prefix}-tf-public-subnet-az2-${terraform.workspace}"]

  #checkov:skip=CKV_TF_1:Ensure Terraform module sources use a commit hash
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_arn" {
  value = module.vpc.vpc_arn
}