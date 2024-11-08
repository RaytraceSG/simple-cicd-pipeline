# Create ECS Cluster
resource "aws_ecs_cluster" "nginx_cluster" {
  name = var.ecs_cluster_name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Task Definition
resource "aws_ecs_task_definition" "nginx_task" {
  family                   = var.ecs_task_def_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([
    {
      name  = "azmi1-nginx-container-1"
      image = "nginx:latest"
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    },
    {
      name  = "azmi1-nginx-container-2"
      image = "nginx:latest"
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
    }
  ])
  #checkov:skip=CKV_AWS_336:Ensure ECS containers are limited to read-only access to root filesystems
}

# ECS Service
resource "aws_ecs_service" "nginx_service" {
  name            = "azmi1-nginx-service"
  cluster         = aws_ecs_cluster.nginx_cluster.id
  task_definition = aws_ecs_task_definition.nginx_task.arn
  launch_type     = "FARGATE"
  desired_count   = 2

  network_configuration {
    subnets          = module.vpc.public_subnets # Replace with your subnet IDs
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.nginx_tg.arn
    container_name   = "azmi1-nginx-container-1"
    container_port   = 80
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.nginx_tg_2.arn
    container_name   = "azmi1-nginx-container-2"
    container_port   = 8080
  }
  #checkov:skip=CKV_AWS_333:Ensure ECS services do not have public IP addresses assigned to them automatically
}

# Application Load Balancer
resource "aws_lb" "nginx_alb" {
  name                       = "azmi1-nginx-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.azmi1-tf-sg-allow-ssh-http-https.id]
  subnets                    = module.vpc.public_subnets # Replace with your subnet IDs
  drop_invalid_header_fields = true
  #checkov:skip=CKV_AWS_150:Ensure that Load Balancer has deletion protection enabled
  #checkov:skip=CKV_AWS_91:Ensure the ELBv2 (Application/Network) has access logging enabled
  #checkov:skip=CKV2_AWS_20:Ensure that ALB redirects HTTP requests into HTTPS ones
  #checkov:skip=CKV2_AWS_28:Ensure public facing ALB are protected by WAF
}

# ALB Listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.nginx_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg.arn
  }
  #checkov:skip=CKV_AWS_2:Ensure ALB protocol is HTTPS
  #checkov:skip=CKV_AWS_103:Ensure that load balancer is using at least TLS 1.2
}

resource "aws_lb_listener_rule" "nginx_rule_2" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg_2.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"] # Adjust this path as needed
    }
  }
}

# Target Group
resource "aws_lb_target_group" "nginx_tg" {
  name        = "azmi1-nginx-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
  #checkov:skip=CKV_AWS_378:Ensure AWS Load Balancer doesn't use HTTP protocol
}

resource "aws_lb_target_group" "nginx_tg_2" {
  name        = "azmi1-nginx-tg-2"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
  #checkov:skip=CKV_AWS_378:Ensure AWS Load Balancer doesn't use HTTP protocol
}