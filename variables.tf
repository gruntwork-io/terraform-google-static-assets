# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------

variable "project" {
  description = "The project ID to host the site in."
  type        = string
}

variable "website_domain_name" {
  description = "The name of the website and the Cloud Storage bucket to create (e.g. static.foo.com)."
  type        = string
}

variable "create_dns_entry" {
  description = "If set to true, create a DNS CNAME Record in Cloud DNS with the domain name in var.website_domain_name."
  type        = bool
}

variable "dns_managed_zone_name" {
  description = "The name of the Cloud DNS Managed Zone in which to create the DNS CNAME Record specified in var.website_domain_name. Only used if var.create_dns_entry is true."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables have defaults, but may be overridden by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "dns_record_ttl" {
  description = "The time-to-live for the site CNAME record set (seconds)"
  type        = number
  default     = 60
}

variable "website_location" {
  description = "Location of the bucket that will store the static website. Once a bucket has been created, its location can't be changed. See https://cloud.google.com/storage/docs/bucket-locations"
  type        = string
  default     = "US"
}

variable "enable_versioning" {
  description = "Set to true to enable versioning. This means the website bucket will retain all old versions of all files. This is useful for backup purposes (e.g. you can rollback to an older version), but it may mean your bucket uses more storage."
  type        = bool
  default     = false
}

variable "index_page" {
  description = "Bucket's directory index"
  type        = string
  default     = "index.html"
}

variable "not_found_page" {
  description = "The custom object to return when a requested resource is not found"
  type        = string
  default     = "404.html"
}

variable "force_destroy_website" {
  description = "If set to true, this will force the delete of the website bucket when you run terraform destroy, even if there is still content in it. This is only meant for testing and should not be used in production."
  type        = bool
  default     = false
}

variable "force_destroy_access_logs_bucket" {
  description = "If set to true, this will force the delete of the access logs bucket when you run terraform destroy, even if there is still content in it. This is only meant for testing and should not be used in production."
  type        = bool
  default     = false
}

