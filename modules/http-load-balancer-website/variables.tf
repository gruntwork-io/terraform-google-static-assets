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

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# These variables have defaults, but may be overridden by the operator.
# ---------------------------------------------------------------------------------------------------------------------
variable "website_location" {
  description = "Location of the bucket that will store the static website. Once a bucket has been created, its location can't be changed. See https://cloud.google.com/storage/docs/bucket-locations"
  type        = string
  default     = "US"
}

variable "website_storage_class" {
  description = "Storage class of the bucket that will store the static website"
  type        = string
  default     = "MULTI_REGIONAL"
}

variable "website_acls" {
  description = "Bucket default object ACLs to allow users access to objects, for example 'READER:allUsers'. See https://cloud.google.com/storage/docs/access-control/lists"
  type        = list(string)
  default     = ["READER:allUsers"]
}

variable "enable_versioning" {
  description = "Set to true to enable versioning. This means the website bucket will retain all old versions of all files. This is useful for backup purposes (e.g. you can rollback to an older version), but it may mean your bucket uses more storage."
  type        = bool
  default     = true
}

variable "enable_ssl" {
  description = "Set to true to enable ssl. If set to 'true', you will also have to provide 'var.ssl_certificate'."
  type        = bool
  default     = false
}

variable "ssl_certificate" {
  description = "SSL certificate self_link. Required if 'enable_ssl' is 'true'."
  type        = string
  default     = ""
}

variable "enable_http" {
  description = "Set to true to enable plain http. Note that disabling http does not force SSL and/or redirect HTTP traffic. See https://issuetracker.google.com/issues/35904733"
  type        = bool
  default     = true
}

variable "enable_cdn" {
  description = "Set to `true` to enable cdn on website backend bucket."
  type        = bool
  default     = true
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

variable "enable_cors" {
  description = "Set to true if you want to enable CORS headers"
  type        = bool
  default     = false
}

variable "cors_origins" {
  description = "List of Origins eligible to receive CORS response headers. Note: '*' is permitted in the list of origins, and means 'any Origin'"
  type        = list(string)
  default     = []
}

variable "cors_methods" {
  description = "list of HTTP methods on which to include CORS response headers, (GET, OPTIONS, POST, etc). Note: '*' is permitted in the list of methods, and means 'any method'"
  type        = list(string)
  default     = []
}

variable "cors_extra_headers" {
  description = "List of HTTP headers other than the simple response headers to give permission for the user-agent to share across domains"
  type        = list(string)
  default     = []
}

variable "cors_max_age_seconds" {
  description = "The value, in seconds, to return in the Access-Control-Max-Age header used in preflight responses"
  type        = number
  default     = 600
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

variable "access_logs_expiration_time_in_days" {
  description = "How many days to keep access logs around for before deleting them."
  type        = number
  default     = 30
}

variable "access_log_prefix" {
  description = "The object prefix for log objects. If it's not provided, it is set to the value of var.website_domain_name with dots are replaced with dashes, e.g. 'site-acme-com'."
  type        = string
  default     = ""
}

variable "website_kms_key_name" {
  description = "A Cloud KMS key that will be used to encrypt objects inserted into the website bucket. If empty, the contents will not be encrypted. You must pay attention to whether the crypto key is available in the location that this bucket is created in."
  type        = string
  default     = ""
}

variable "access_logs_kms_key_name" {
  description = "A Cloud KMS key that will be used to encrypt objects inserted into the access logs bucket. If empty, the contents will not be encrypted. You must pay attention to whether the crypto key is available in the location that this bucket is created in."
  type        = string
  default     = ""
}

variable "create_dns_entry" {
  description = "If set to true, create a DNS CNAME Record in Cloud DNS with the domain name in var.website_domain_name."
  type        = bool
  default     = false
}

variable "dns_managed_zone_name" {
  description = "The name of the Cloud DNS Managed Zone in which to create the DNS CNAME Record specified in var.website_domain_name. Only used if var.create_dns_entry is true."
  type        = string
  default     = "replace-me"
}

variable "dns_record_ttl" {
  description = "The time-to-live for the site CNAME record set (seconds)"
  type        = number
  default     = 300
}

variable "custom_labels" {
  description = "A map of custom labels to apply to the resources. The key is the label name and the value is the label value."
  type        = map(string)
  default     = {}
}

