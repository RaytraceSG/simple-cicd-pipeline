data "aws_vpc" "selected_vpc" {
  filter {
    name   = "tag:Name"
    values = ["ce7-ty-vpc"]
  }

}

data "aws_security_group" "selected_sg" {
  filter {
    name   = "group-name"
    values = ["ce7-ty-vpc"]
  }
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.aws_vpc_data.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}