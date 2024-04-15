locals {
  port = 5432
}
module "standard_tags" {
  source  = "truemark/standard-tags/aws"
  version = "1.0.0"
  automation_component = {
    id     = "terraform-aws-rds-postgres"
    url    = "https://registry.terraform.io/modules/truemark/rds-postgres"
    vendor = "TrueMark"
  }
}
data "aws_kms_alias" "db" {
  count = var.create_db_instance && var.kms_key_arn == null && var.kms_key_id == null && var.kms_key_alias != null ? 1 : 0
  name  = var.kms_key_alias
}

data "aws_kms_key" "db" {
  count  = var.create_db_instance && var.kms_key_arn == null && var.kms_key_id != null ? 1 : 0
  key_id = var.kms_key_id
}

resource "random_password" "root_password" {
  count   = var.create_db_instance ? 1 : 0
  length  = var.random_password_length
  special = false
}

resource "aws_security_group" "db" {
  count  = var.create_db_instance ? 1 : 0
  name   = var.instance_name
  vpc_id = var.vpc_id
  tags   = var.tags

  ingress {
    from_port   = local.port
    to_port     = local.port
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = var.egress_cidrs
  }
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

resource "aws_iam_role" "rds_enhanced_monitoring" {
  count              = var.create_db_instance ? 1 : 0
  name               = "rds-enhanced-monitoring-${lower(var.instance_name)}"
  assume_role_policy = data.aws_iam_policy_document.rds_enhanced_monitoring.json
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count      = var.create_db_instance ? 1 : 0
  role       = aws_iam_role.rds_enhanced_monitoring[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

module "db" {
  # https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/latest
  source  = "terraform-aws-modules/rds/aws"
  version = "6.5.4"

  allocated_storage          = var.allocated_storage
  apply_immediately          = var.apply_immediately
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  backup_retention_period    = var.backup_retention_period
  ca_cert_identifier         = var.ca_cert_identifier
  copy_tags_to_snapshot      = var.copy_tags_to_snapshot
  create_db_instance         = var.create_db_instance
  create_db_parameter_group  = true
  create_db_subnet_group     = true
  db_instance_tags           = var.tags
  db_name                    = var.database_name
  db_subnet_group_tags       = var.tags
  deletion_protection        = var.deletion_protection
  engine                     = "postgres"
  engine_version             = var.engine_version
  family                     = var.family
  identifier                 = var.instance_name
  instance_class             = var.instance_type
  iops                       = var.iops
  kms_key_id                 = var.kms_key_arn != null ? var.kms_key_arn : (var.kms_key_id != null) ? join("", data.aws_kms_key.db.*.arn) : (var.kms_key_alias != null) ? join("", data.aws_kms_alias.db.*.target_key_arn) : null
  max_allocated_storage      = var.max_allocated_storage
  monitoring_interval        = var.monitoring_interval
  monitoring_role_arn        = join("", aws_iam_role.rds_enhanced_monitoring.*.arn)
  multi_az                   = var.multi_az
  parameters                 = var.db_parameters
  #password                              = join("", random_password.db.*.result)
  password                              = var.store_master_password_as_secret ? random_password.root_password.result : null
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  skip_final_snapshot                   = var.skip_final_snapshot
  snapshot_identifier                   = var.snapshot_identifier
  storage_encrypted                     = true
  storage_type                          = var.storage_type
  subnet_ids                            = var.subnet_ids
  tags                                  = var.tags
  username                              = var.username
  vpc_security_group_ids                = [join("", aws_security_group.db.*.id)]
}

module "master_secret" {
  source        = "truemark/rds-secret/aws"
  version       = "1.1.2"
  create        = var.create_db_instance && var.create_secrets
  cluster       = false
  identifier    = module.db.db_instance_id
  name          = "master"
  username      = module.db.db_instance_username
  password      = join("", random_password.db.*.result)
  database_name = var.database_name != null ? var.database_name : "postgres"
}

module "user_secrets" {
  for_each      = { for user in var.additional_users : user.username => user }
  source        = "truemark/rds-secret/aws"
  version       = "1.1.2"
  create        = var.create_db_instance && var.create_secrets
  cluster       = false
  identifier    = module.db.db_instance_id
  name          = each.value.username
  database_name = each.value.database_name
}

