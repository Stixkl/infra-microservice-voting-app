locals {
  ecs_service_names = var.service_names
}

locals {
  service_port_map = {
    vote   = 8080
    worker = 8080
    result = 80
  }
}

data "aws_region" "current" {}

resource "aws_cloudwatch_log_group" "services" {
  name              = "/ecs/${var.project_name}-${var.environment}"
  retention_in_days = 14
}

resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-${var.environment}-cluster"
}

resource "aws_iam_role" "task_execution" {
  name = "${var.project_name}-${var.environment}-ecs-task-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "task_execution" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task" {
  name = "${var.project_name}-${var.environment}-ecs-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_ecs_task_definition" "service" {
  for_each = toset(local.ecs_service_names)

  family                   = "${var.project_name}-${var.environment}-${each.value}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.cpu)
  memory                   = tostring(var.memory)
  execution_role_arn       = aws_iam_role.task_execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = each.value
      image     = var.service_images[each.value]
      essential = true
      portMappings = each.value == "worker" ? [] : [
        {
          containerPort = local.service_port_map[each.value]
          hostPort      = local.service_port_map[each.value]
          protocol      = "tcp"
        }
      ]
      environment = concat(
        [
          {
            name  = "KAFKA_HOST"
            value = var.kafka_host
          }
        ],
        each.value == "worker" || each.value == "result" ? [
          {
            name  = "POSTGRES_HOST"
            value = var.db_host
          },
          {
            name  = "POSTGRES_PORT"
            value = "5432"
          },
          {
            name  = "POSTGRES_DB"
            value = var.db_name
          },
          {
            name  = "POSTGRES_USER"
            value = var.db_username
          },
          {
            name  = "POSTGRES_PASSWORD"
            value = var.db_password
          }
        ] : []
      )
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.services.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = each.value
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "kafka" {
  family                   = "${var.project_name}-${var.environment}-kafka"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.task_execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = "kafka"
      image     = var.kafka_image
      essential = true
      portMappings = [
        {
          containerPort = 9092
          hostPort      = 9092
          protocol      = "tcp"
        },
        {
          containerPort = 9093
          hostPort      = 9093
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "KAFKA_CFG_NODE_ID"
          value = "1"
        },
        {
          name  = "KAFKA_CFG_PROCESS_ROLES"
          value = "broker,controller"
        },
        {
          name  = "KAFKA_CFG_LISTENERS"
          value = "PLAINTEXT://:9092,CONTROLLER://:9093"
        },
        {
          name  = "KAFKA_CFG_ADVERTISED_LISTENERS"
          value = "PLAINTEXT://kafka:9092"
        },
        {
          name  = "KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP"
          value = "CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT"
        },
        {
          name  = "KAFKA_CFG_CONTROLLER_QUORUM_VOTERS"
          value = "1@localhost:9093"
        },
        {
          name  = "KAFKA_CFG_CONTROLLER_LISTENER_NAMES"
          value = "CONTROLLER"
        },
        {
          name  = "ALLOW_PLAINTEXT_LISTENER"
          value = "yes"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.services.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "kafka"
        }
      }
    }
  ])
}

resource "aws_service_discovery_private_dns_namespace" "this" {
  name = "${var.project_name}-${var.environment}.local"
  vpc  = var.vpc_id
}

resource "aws_service_discovery_service" "kafka" {
  name = "kafka"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

resource "aws_ecs_service" "kafka" {
  name            = "${var.project_name}-${var.environment}-kafka"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.kafka.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = true
    subnets          = var.subnet_ids
    security_groups  = [var.ecs_security_group_id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.kafka.arn
  }
}

resource "aws_ecs_service" "service" {
  for_each = toset(local.ecs_service_names)

  name            = "${var.project_name}-${var.environment}-${each.value}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.service[each.value].arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = true
    subnets          = var.subnet_ids
    security_groups  = [var.ecs_security_group_id]
  }

  depends_on = [aws_ecs_service.kafka]
}

