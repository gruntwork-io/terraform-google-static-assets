# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY A STATIC SITE
# This module deploys a Cloud Storage static website
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ------------------------------------------------------------------------------
# PREPARE LOCALS
#
# NOTE: Due to limitations in terraform and heavy use of nested sub-blocks in the resource,
# we have to construct some of the configuration values dynamically
# ------------------------------------------------------------------------------

locals {
  # Terraform does not allow using lists of maps with coditionals, so we have to
  # trick terraform by creating a string conditional first.
  # See https://github.com/hashicorp/terraform/issues/12453
  cors_configuration_key = "${var.enable_cors ? "CORS" : "EMPTY"}"

  cors_configuration_def = {
    "CORS" = {
      origin          = ["${var.cors_origins}"]
      method          = ["${var.cors_methods}"]
      response_header = ["${var.cors_extra_headers}"]
      max_age_seconds = "${var.cors_max_age_seconds}"
    }

    # We have to set at least one CORS property in the "empty" block
    # To avoid terraform failures. This does not have effect on the
    # CORS headers.
    "EMPTY" = {
      origin = [""]
    }
  }

  # Construct the sub-block dynamically
  cors_configuration = "${local.cors_configuration_def[local.cors_configuration_key]}"

  # We have to use dashes instead of dots in the access log bucket, because
  # that bucket is not a website
  website_domain_name_dashed = "${replace(var.website_domain_name, ".", "-")}"
}

# ------------------------------------------------------------------------------
# CREATE THE WEBSITE BUCKET
# ------------------------------------------------------------------------------

resource "google_storage_bucket" "website" {
  provider = "google-beta"

  project = "${var.project}"

  name          = "${var.website_domain_name}"
  location      = "${var.website_location}"
  storage_class = "${var.website_storage_class}"

  versioning {
    enabled = "${var.enable_versioning}"
  }

  website {
    main_page_suffix = "${var.index_page}"
    not_found_page   = "${var.not_found_page}"
  }

  cors = ["${local.cors_configuration}"]

  force_destroy = "${var.force_destroy_website}"

  # We disable custom KMS keys until we have a fix for
  # https://github.com/terraform-providers/terraform-provider-google/issues/3134
  #encryption {
  #  default_kms_key_name = "${var.website_kms_key_name}"
  #}

  labels = "${var.custom_labels}"
  logging {
    log_bucket        = "${google_storage_bucket.access_logs.name}"
    log_object_prefix = "${var.access_log_prefix != "" ? var.access_log_prefix : local.website_domain_name_dashed}"
  }
}

# ------------------------------------------------------------------------------
# CONFIGURE BUCKET ACLS
# ------------------------------------------------------------------------------

resource "google_storage_default_object_acl" "website_acl" {
  provider    = "google-beta"
  bucket      = "${google_storage_bucket.website.name}"
  role_entity = ["${var.website_acls}"]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SEPARATE BUCKET TO STORE ACCESS LOGS
# ---------------------------------------------------------------------------------------------------------------------

resource "google_storage_bucket" "access_logs" {
  provider = "google-beta"

  project = "${var.project}"

  # Use the dashed domain name
  name          = "${local.website_domain_name_dashed}-logs"
  location      = "${var.website_location}"
  storage_class = "${var.website_storage_class}"

  force_destroy = "${var.force_destroy_access_logs_bucket}"

  # We disable custom KMS keys until we have a fix for
  # https://github.com/terraform-providers/terraform-provider-google/issues/3134
  #encryption {
  #  default_kms_key_name = "${var.access_logs_kms_key_name}"
  #}

  lifecycle_rule {
    "action" {
      type = "Delete"
    }

    "condition" {
      age = "${var.access_logs_expiration_time_in_days}"
    }
  }
  labels = "${var.custom_labels}"
}

# ---------------------------------------------------------------------------------------------------------------------
# GRANT WRITER ACCESS TO GOOGLE ANALYTICS
# ---------------------------------------------------------------------------------------------------------------------

resource "google_storage_bucket_acl" "analytics_write" {
  provider = "google-beta"

  bucket = "${google_storage_bucket.access_logs.name}"

  # The actual identity is 'cloud-storage-analytics@google.com', but
  # we're required to prefix that with the type of identity
  role_entity = ["WRITER:group-cloud-storage-analytics@google.com"]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE CNAME ENTRY IN DNS
# ---------------------------------------------------------------------------------------------------------------------

resource "google_dns_record_set" "cname" {
  provider = "google-beta"
  count = "${var.create_dns_entry == "true" ? 1 : 0}"

  depends_on = ["google_storage_bucket.website"]

  project = "${var.project}"

  name         = "${var.website_domain_name}."
  managed_zone = "${var.dns_managed_zone_name}"
  type         = "CNAME"
  ttl          = "${var.dns_record_ttl}"
  rrdatas      = ["c.storage.googleapis.com."]
}
