#Create ECS cluster
resource "aws_ecs_cluster" "fargate_vpn" {
  name = var.project_name
}

#Create ECS service and set to 1 running task
resource "aws_ecs_service" "tailscale" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.fargate_vpn.name
  task_definition = aws_ecs_task_definition.tailscale.arn
  launch_type     = "FARGATE"

  desired_count = 1

  network_configuration {
    assign_public_ip = true
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.tailscale.id]
  }

  wait_for_steady_state = true
}

#Create ECS task definition using the ECR repo created as part of this and inject our SSM parameters
resource "aws_ecs_task_definition" "tailscale" {
  family = var.service_name
  container_definitions = jsonencode([
    {
      name      = var.service_name
      image     = "${aws_ecr_repository.tailscale.repository_url}:latest"
      essential = true
      linuxParameters = {
        initProcessEnabled = true
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.tailscale.name,
          "awslogs-region"        = var.region,
          "awslogs-stream-prefix" = var.service_name
        }
      }
      environment = [
        { name = "HOSTNAME", value = var.project_name}
      ],
      secrets = [
        { name = "STATE", valueFrom = aws_ssm_parameter.state.arn },
        { name = "AUTH_KEY", valueFrom = aws_ssm_parameter.authkey.arn },
      ]
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = 256
  memory = 512

  execution_role_arn = aws_iam_role.execution.arn
  task_role_arn      = aws_iam_role.task.arn
}

#Allow all outbound traffic
resource "aws_security_group" "tailscale" {
  name   = var.service_name
  vpc_id = aws_vpc.main.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

#Create Cloudwatch Log Group to send the containers logs to
resource "aws_cloudwatch_log_group" "tailscale" {
  name = "ecs/${var.service_name}"
}