#Assume role policy for ECS tasks service
data "aws_iam_policy_document" "ecs_tasks_service" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "ecs-tasks.amazonaws.com",
      ]
    }
  }
}

#ECS Execution IAM role
resource "aws_iam_role" "execution" {
  name               = "${var.service_name}-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_service.json

  inline_policy {
    name   = "ssm"
    policy = data.aws_iam_policy_document.ecs_execution_policy.json
  }
}

#Apply ECS Task execution role to execution IAM role
resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#Allow ECS execution role to get the SSM parameters so it can inject them into the container
data "aws_iam_policy_document" "ecs_execution_policy" {
  statement {
    effect  = "Allow"
    actions = ["ssm:GetParameters"]

    resources = [aws_ssm_parameter.authkey.arn, aws_ssm_parameter.state.arn]
  }
}

#ECS Task IAM role
resource "aws_iam_role" "task" {
  name               = "${var.service_name}-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_service.json

  inline_policy {
    name   = "ssm"
    policy = data.aws_iam_policy_document.ecs_task_policy.json
  }
}

#Allow read/write of the SSM parameter from the container
data "aws_iam_policy_document" "ecs_task_policy" {
  statement {
    effect  = "Allow"
    actions = ["ssm:GetParameter", "ssm:PutParameter"]

    resources = [aws_ssm_parameter.state.arn]
  }
}