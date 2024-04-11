variable "additional_users" {
  description = "Additional users to generate secrets for"
  type = list(object({
    username      = string
    database_name = string
  }))
  default = []
}

variable "allocated_storage" {
  description = "Storage size in GB."
  default     = 100
}

variable "apply_immediately" {
  description = "Determines whether or not any DB modifications are applied immediately, or during the maintenance window"
  type        = bool
  default     = true
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "How long to keep backups for (in days)"
  type        = number
  default     = 7
}

variable "ca_cert_identifier" {
  description = "The identifier of the CA certificate for the DB instance"
  type        = string
  default     = "rds-ca-rsa2048-g1"
}

variable "copy_tags_to_snapshot" {
  description = "Copy all cluster tags to snapshots"
  type        = bool
  default     = false
}

variable "create_db_instance" {
  description = "Whether to create the database instance"
  type        = bool
  default     = true
}

variable "create_security_group" {
  description = "Whether to create the security group for the RDS instance"
  type        = bool
  default     = true
}

variable "create_secrets" {
  description = "Toggle on or off storing passwords in AWS Secrets Manager."
  type        = bool
  default     = true
}

variable "database_name" {
  description = "Name for the database to be created."
  type        = string
  default     = null
}

variable "db_parameter_group_tags" {
  description = "A map of tags to add to the aws_db_parameter_group resource if one is created."
  default     = {}
}

variable "db_parameters" {
  description = "Map of parameters to use in the aws_db_parameter_group resource"
  type        = list(map(any))
  default     = []
}

variable "db_subnet_group_name" {
  description = "The name of the subnet group name (existing or created)"
  type        = string
  default     = " "
}

variable "deletion_protection" {
  description = "Sets deletion protection on the instance"
  type        = bool
  default     = false
}

variable "egress_cidrs" {
  description = "List of allowed CIDRs that this RDS instance can access."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "engine_version" {
  description = "PostgreSQL database engine version."
  type        = string
  default     = "14.4"
}

variable "family" {
  description = "The DB parameter group family name"
  type        = string
  default     = "postgres14"
}

variable "iops" {
  description = "The amount of provisioned IOPS. Setting implies a storage_type of io1."
  type        = number
  default     = 500
}

variable "ingress_cidrs" {
  description = "List of allowed CIDRs that can access this RDS instance."
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "instance_name" {
  description = "Name for the db instance. This will display in the console."
  type        = string
}

variable "instance_type" {
  description = "Instance type to use at master instance. If instance_type_replica is not set it will use the same type for replica instances"
  type        = string
  default     = "db.t4g.small"
}

variable "kms_key_alias" {
  description = "The alias of the KMS key to use."
  type        = string
  default     = null
}

variable "kms_key_arn" {
  description = "The KMS key to use. Setting this overrides any value put in kms_key_id and kms_key_alias."
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "The ID of the KMS key to use. Setting this overrides any value put in kms_key_alias."
  type        = string
  default     = null
}

variable "manage_master_user_password" {
  description = "Set to true to allow RDS to manage the master user password in Secrets Manager"
  type        = bool
  default     = true
}

variable "master_user_secret_kms_key_id" {
  description = "The Amazon Web Services KMS key identifier is the key ARN, key ID, alias ARN, or alias name for the KMS key"
  type        = string
  default     = null
}
variable "max_allocated_storage" {
  description = "Maximum storage size in GB."
  default     = 500
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0."
  type        = number
  default     = 60
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ."
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "Amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years)"
  type        = number
  default     = null
}
variable "preferred_backup_window" {
  description = "When to perform DB backups"
  type        = string
  default     = "02:00-03:00" # 7PM-8PM MST
}

variable "preferred_maintenance_window" {
  description = "When to perform DB maintenance"
  type        = string
  default     = "sat:03:00-sat:05:00" # 8PM-10PM MST
}

variable "random_password_length" {
  description = "The length of the password to generate for root user."
  type        = number
  default     = 16
}

variable "security_group_tags" {
  description = "Additional tags for the security group"
  type        = map(string)
  default     = {}
}

variable "skip_final_snapshot" {
  description = "Should a final snapshot be created on cluster destroy"
  type        = bool
  default     = false
}

variable "snapshot_identifier" {
  description = "DB snapshot to create this database from"
  type        = string
  default     = null
}

variable "storage_type" {
  description = "One of 'standard', 'gp2' or 'io1'."
  type        = string
  default     = "io1"
}

variable "store_master_password_as_secret" {
  description = "Set to true to allow self-management of the master user password in Secrets Manager"
  type        = bool
  default     = false
}
variable "subnet_ids" {
  description = "List of subnet IDs to use"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "username" {
  description = "The master database account to create."
  default     = "postgres" # This is the default username RDS uses
}

variable "vpc_id" {
  description = "The ID of the VPC to provision into"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate to the cluster in addition to the security group created"
  type        = list(string)
  default     = []
}
