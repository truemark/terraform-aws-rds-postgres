variable "ingress_cidrs" {
  default = ["0.0.0.0/0"]
}

variable "egress_cidrs" {
  default = ["0.0.0.0/0"]
}
variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "copy_tags_to_snapshot" {
  description = "Copy all cluster tags to snapshots"
  default     = false
}

variable "store_master_password_as_secret" {
  description = "Toggle on or off storing the root password in Secrets Manager."
  default     = true
}

variable "random_password_length" {
  description = "The length of the password to generate for root user."
  default     = 16
}

variable "username" {
  description = "The master database account to create."
  default     = "root"
}

variable "create_security_group" {
  description = "Whether to create the security group for the RDS instance"
  default     = true
  type        = bool
}

variable "security_group_tags" {
  description = "Additional tags for the security group"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "The ID of the VPC to provision into"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to use"
  type        = list(string)
}

variable "family" {
  description = "The family of the DB parameter group"
  type        = string
  default     = "postgres"
}

variable "allocated_storage" {
  description = "Storage size in GB."
  default     = 100
}

variable "max_allocated_storage" {
  description = "Maximum storage size in GB."
  default     = 2000
}

variable "db_parameters" {
  description = "Map of parameters to use in the aws_db_parameter_group resource"
  type        = list(map(any))
  default     = [{}]
}

variable "db_parameter_group_tags" {
  description = "A map of tags to add to the aws_db_parameter_group resource if one is created."
  default     = {}
}

variable "instance_name" {
  description = "Name for the db instance. This will display in the console."
  type        = string
  default     = ""
}

variable "engine_version" {
  description = "Postgres database engine version."
  type        = string
  default     = "14.1"
}


variable "instance_type" {
  description = "Instance type to use at master instance. If instance_type_replica is not set it will use the same type for replica instances"
  type        = string
  default     = "db.t2.small"
}

variable "apply_immediately" {
  description = "Determines whether or not any DB modifications are applied immediately, or during the maintenance window"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Should a final snapshot be created on cluster destroy"
  type        = bool
  default     = false
}

variable "allowed_cidr_blocks" {
  description = "A list of CIDR blocks which are allowed to access the database"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "backup_retention_period" {
  description = "How long to keep backups for (in days)"
  type        = number
  default     = 7
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

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "share" {
  default = false
  type    = bool
}

variable "share_tags" {
  description = "Additional tags for the resource access manager share."
  type        = map(string)
  default     = {}
}

variable "snapshot_identifier" {
  description = "DB snapshot to create this database from"
  type        = string
  default     = null
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0."
  type        = number
  default     = 60
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window."
  type        = bool
  default     = false
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ."
  type        = bool
  default     = false
}

variable "database_name" {
  description = "Name for the database to be created."
  type        = string
  default     = ""
}
