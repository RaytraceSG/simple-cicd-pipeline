# Create ECS Cluster
resource "aws_ecs_cluster" "nginx_cluster" {
  name = var.ecs_cluster_name
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
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "nginx_service" {
  name            = "azmi1-nginx-service"
  cluster         = aws_ecs_cluster.nginx_cluster.id
  task_definition = aws_ecs_task_definition.nginx_task.arn
  launch_type     = "FARGATE"
  desired_count   = 2

  network_configuration {
    subnets          = module.vpc.public_subnets# Replace with your subnet IDs
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.nginx_tg.arn
    container_name   = "azmi1-nginx-container-1"
    container_port   = 80
  }
}

# Application Load Balancer
resource "aws_lb" "nginx_alb" {
  name               = "azmi1-nginx-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.azmi1-tf-sg-allow-ssh-http-https.id]
  subnets            = module.vpc.public_subnets # Replace with your subnet IDs
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
}