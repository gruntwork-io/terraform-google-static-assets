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

    "EMPTY" = {
      origin = [""]
    }
  }

  # Construct the sub-block dynamically
  cors_configuration = "${local.cors_configuration_def[local.cors_configuration_key]}"

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
# CONFIGURE BUCKET ACLs
#
# We will create the ACL either with a predefined ACL or, if provided, list of
# more granular access rights
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

  name          = "${local.website_domain_name_dashed}-logs"
  location      = "${var.website_location}"
  storage_class = "${var.website_storage_class}"

  force_destroy = "${var.force_destroy_access_logs_bucket}"

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

  bucket      = "${google_storage_bucket.access_logs.name}"
  role_entity = ["WRITER:group-cloud-storage-analytics@google.com"]
}

resource "google_dns_record_set" "cname" {
  count = "${var.create_dns_entry}"

  project = "${var.project}"

  name         = "${var.website_domain_name}."
  managed_zone = "${var.dns_managed_zone_name}"
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["c.storage.googleapis.com."]
}
