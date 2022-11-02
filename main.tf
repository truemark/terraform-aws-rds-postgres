
module "db" {
  # https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/latest
  # https://github.com/terraform-aws-modules/terraform-aws-rds/blob/v3.3.0/examples/complete-oracle/main.tf
  source  = "terraform-aws-modules/rds/aws"
  version = "5.1.0"

  # The name of the database to create. Upper is required by Oracle.
  # Can't be more than 8 characters.
  db_name = var.database_name

  # parameter_group_use_name_prefix = false
  allocated_storage               = var.allocated_storage
  auto_minor_version_upgrade      = var.auto_minor_version_upgrade
  apply_immediately               = var.apply_immediately
  backup_retention_period         = var.backup_retention_period
  copy_tags_to_snapshot           = var.copy_tags_to_snapshot
  create_db_subnet_group          = true
  create_random_password          = false
  db_instance_tags                = var.tags
  db_subnet_group_tags            = var.tags
  deletion_protection             = var.deletion_protection
  # enabled_cloudwatch_logs_exports = ["alert", "trace", "listener"]
  engine                          = "postgres"
  engine_version                  = var.engine_version
  family                          = var.family
  identifier                      = var.instance_name
  instance_class                  = var.instance_type
  # license_model                   = var.license_model
  # major_engine_version            = var.major_engine_version
  max_allocated_storage           = var.max_allocated_storage
  monitoring_interval             = var.monitoring_interval
  multi_az                        = var.multi_az

  password                              = random_password.root_password.result
  skip_final_snapshot                   = var.skip_final_snapshot
  snapshot_identifier                   = var.snapshot_identifier
  storage_encrypted                     = true
  subnet_ids                            = var.subnet_ids
  tags                                  = var.tags
  username                              = var.username # defaults to root
  vpc_security_group_ids                = [aws_security_group.db_security_group.id]
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  # create_monitoring_role                = true
  monitoring_role_arn = aws_iam_role.rds_enhanced_monitoring.arn
}

#-----------------------------------------------------------------------------
# Define the paramter group explicitly. Do not let the db module above
# create it. This is all to get around the issue with Oracle requiring
# database names to be in CAPS and
resource "aws_db_parameter_group" "db_parameter_group" {
  name_prefix = var.instance_name
  description = "Terraform managed parameter group for ${var.instance_name}"
  family      = var.family
  tags        = var.tags
  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }
}

resource "aws_secretsmanager_secret" "db" {
  count       = var.store_master_password_as_secret ? 1 : 0
  name_prefix = "database/${var.instance_name}/master-"
  description = "Master password for ${var.username} in ${var.instance_name}"
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "db" {
  count     = var.store_master_password_as_secret ? 1 : 0
  secret_id = aws_secretsmanager_secret.db[count.index].id
  secret_string = jsonencode({
    "username"       = "root"
    "password"       = random_password.root_password.result
    "host"           = module.db.db_instance_address
    "port"           = module.db.db_instance_port
    "dbname"         = module.db.db_instance_name
    "connect_string" = "${module.db.db_instance_endpoint}/${upper(var.database_name)}"
    "engine"         = "oracle"
  })
}
resource "random_password" "root_password" {
  length  = var.random_password_length
  special = false
}

data "aws_secretsmanager_secret_version" "db" {
  # There will only ever be one password here. Hard coding the index.
  secret_id  = aws_secretsmanager_secret.db[0].id
  depends_on = [aws_secretsmanager_secret_version.db]
}

#-----------------------------------------------------------------------------

resource "aws_security_group" "db_security_group" {
  name   = var.instance_name
  vpc_id = var.vpc_id
  tags   = var.tags

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidrs
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidrs
  }

  # TODO Lock this down later
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = var.ingress_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = var.egress_cidrs
  }
}

################################################################################
# Create an IAM role to allow enhanced monitoring
################################################################################

resource "aws_iam_role" "rds_enhanced_monitoring" {
  name               = "rds-enhanced-monitoring-${lower(var.instance_name)}"
  assume_role_policy = data.aws_iam_policy_document.rds_enhanced_monitoring.json
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

data "aws_iam_policy_document" "rds_enhanced_monitoring" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

