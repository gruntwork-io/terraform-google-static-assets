# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY A STATIC SITE
# This module deploys a Cloud Storage static website
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  # This module is now only being tested with Terraform 1.0.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 1.0.x code.
  required_version = ">= 0.12.26"
}

# ------------------------------------------------------------------------------
# PREPARE LOCALS
#
# NOTE: Due to limitations in terraform and heavy use of nested sub-blocks in the resource,
# we have to construct some of the configuration values dynamically
# ------------------------------------------------------------------------------

locals {
  # We have to use dashes instead of dots in the access log bucket, because that bucket is not a website
  website_domain_name_dashed = replace(var.website_domain_name, ".", "-")
  access_log_kms_keys        = var.access_logs_kms_key_name == "" ? [] : [var.access_logs_kms_key_name]
  website_kms_keys           = var.website_kms_key_name == "" ? [] : [var.website_kms_key_name]
}

# ------------------------------------------------------------------------------
# CREATE THE WEBSITE BUCKET
# ------------------------------------------------------------------------------

resource "google_storage_bucket" "website" {
  provider = google-beta

  project = var.project

  name          = var.website_domain_name
  location      = var.website_location
  storage_class = var.website_storage_class

  versioning {
    enabled = var.enable_versioning
  }

  website {
    main_page_suffix = var.index_page
    not_found_page   = var.not_found_page
  }

  dynamic "cors" {
    for_each = var.enable_cors ? ["cors"] : []
    content {
      origin          = var.cors_origins
      method          = var.cors_methods
      response_header = var.cors_extra_headers
      max_age_seconds = var.cors_max_age_seconds
    }
  }

  force_destroy = var.force_destroy_website

  dynamic "encryption" {
    for_each = local.website_kms_keys
    content {
      default_kms_key_name = encryption.value
    }
  }

  labels = var.custom_labels
  logging {
    log_bucket        = google_storage_bucket.access_logs.name
    log_object_prefix = var.access_log_prefix != "" ? var.access_log_prefix : local.website_domain_name_dashed
  }
}

# ------------------------------------------------------------------------------
# CONFIGURE BUCKET ACLS
# ------------------------------------------------------------------------------

resource "google_storage_default_object_acl" "website_acl" {
  provider    = google-beta
  bucket      = google_storage_bucket.website.name
  role_entity = var.website_acls
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SEPARATE BUCKET TO STORE ACCESS LOGS
# ---------------------------------------------------------------------------------------------------------------------

resource "google_storage_bucket" "access_logs" {
  provider = google-beta

  project = var.project

  # Use the dashed domain name
  name          = "${local.website_domain_name_dashed}-logs"
  location      = var.website_location
  storage_class = var.website_storage_class

  force_destroy = var.force_destroy_access_logs_bucket

  dynamic "encryption" {
    for_each = local.access_log_kms_keys
    content {
      default_kms_key_name = encryption.value
    }
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }

    condition {
      age = var.access_logs_expiration_time_in_days
    }
  }
  labels = var.custom_labels
}

# ---------------------------------------------------------------------------------------------------------------------
# GRANT WRITER ACCESS TO GOOGLE ANALYTICS
# ---------------------------------------------------------------------------------------------------------------------

resource "google_storage_bucket_acl" "analytics_write" {
  provider = google-beta

  bucket = google_storage_bucket.access_logs.name

  # The actual identity is 'cloud-storage-analytics@google.com', but
  # we're required to prefix that with the type of identity
  role_entity = ["WRITER:group-cloud-storage-analytics@google.com"]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE OPTIONAL CNAME ENTRY IN CLOUD DNS
# ---------------------------------------------------------------------------------------------------------------------

resource "google_dns_record_set" "cname" {
  provider = google-beta
  count    = var.create_dns_entry ? 1 : 0

  depends_on = [google_storage_bucket.website]

  project = var.project

  name         = "${var.website_domain_name}."
  managed_zone = var.dns_managed_zone_name
  type         = "CNAME"
  ttl          = var.dns_record_ttl
  rrdatas      = ["c.storage.googleapis.com."]
}
