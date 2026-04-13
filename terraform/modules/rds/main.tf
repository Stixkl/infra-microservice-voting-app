locals {
  db_identifier = "${var.project_name}-${var.environment}-postgres"
}

resource "aws_db_subnet_group" "this" {
  name       = "${local.db_identifier}-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${local.db_identifier}-subnet-group"
  }
}

resource "aws_db_instance" "this" {
  identifier             = local.db_identifier
  engine                 = "postgres"
  engine_version         = var.engine_version
  instance_class         = var.db_instance_class
  allocated_storage      = 20
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.rds_security_group_id]
  publicly_accessible    = false
  skip_final_snapshot    = var.environment == "dev"
  deletion_protection    = var.environment != "dev"

  tags = {
    Name = local.db_identifier
  }
}

