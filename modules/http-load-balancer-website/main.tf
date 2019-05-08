# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY A STATIC SITE WITH HTTP CLOUD LOAD BALANCER
# This module deploys a HTTP Load Balancer that directs traffic to Cloud Storage Bucket
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ------------------------------------------------------------------------------
# PREPARE COMMONLY USED LOCALS
# ------------------------------------------------------------------------------

locals {
  # We have to use dashes instead of dots in the bucket name, because
  # that bucket is not a website
  website_domain_name_dashed = "${replace(var.website_domain_name, ".", "-")}"
}

module "load_balancer" {
  source = "git::https://github.com/gruntwork-io/terraform-google-load-balancer.git//modules/http-load-balancer?ref=v0.1.0"

  name                  = "${local.website_domain_name_dashed}"
  project               = "${var.project}"
  url_map               = "${google_compute_url_map.urlmap.self_link}"
  create_dns_entries    = "${var.create_dns_entry}"
  custom_domain_names   = ["${var.website_domain_name}"]
  dns_managed_zone_name = "${var.dns_managed_zone_name}"
  dns_record_ttl        = "${var.dns_record_ttl}"
  enable_http           = "${var.enable_http}"
  enable_ssl            = "${var.enable_ssl}"
  ssl_certificates      = ["${var.ssl_certificate}"]
  custom_labels         = "${var.custom_labels}"
}

# ------------------------------------------------------------------------------
# CREATE THE URL MAP WITH THE BACKEND BUCKET AS DEFAULT SERVICE
# ------------------------------------------------------------------------------

resource "google_compute_url_map" "urlmap" {
  provider = "google-beta"
  project  = "${var.project}"

  name        = "${local.website_domain_name_dashed}-url-map"
  description = "URL map for ${local.website_domain_name_dashed}"

  default_service = "${google_compute_backend_bucket.static.self_link}"
}

# ------------------------------------------------------------------------------
# CREATE THE BACKEND BUCKET
# ------------------------------------------------------------------------------

resource "google_compute_backend_bucket" "static" {
  provider = "google-beta"
  project  = "${var.project}"

  name        = "${local.website_domain_name_dashed}-bucket"
  bucket_name = "${module.site_bucket.website_bucket_name}"
  enable_cdn  = "${var.enable_cdn}"
}

# ------------------------------------------------------------------------------
# CREATE CLOUD STORAGE BUCKET FOR CONTENT AND ACCESS LOGS
# ------------------------------------------------------------------------------

module "site_bucket" {
  source = "../cloud-storage-static-website"

  project = "${var.project}"

  website_domain_name   = "${local.website_domain_name_dashed}"
  website_acls          = ["${var.website_acls}"]
  website_location      = "${var.website_location}"
  website_storage_class = "${var.website_storage_class}"
  force_destroy_website = "${var.force_destroy_website}"

  index_page     = "${var.index_page}"
  not_found_page = "${var.not_found_page}"

  enable_versioning = "${var.enable_versioning}"

  access_log_prefix                   = "${var.access_log_prefix}"
  access_logs_expiration_time_in_days = "${var.access_logs_expiration_time_in_days}"
  force_destroy_access_logs_bucket    = "${var.force_destroy_access_logs_bucket}"

  enable_cors          = "${var.enable_cors}"
  cors_extra_headers   = ["${var.cors_extra_headers}"]
  cors_max_age_seconds = "${var.cors_max_age_seconds}"
  cors_methods         = ["${var.cors_methods}"]
  cors_origins         = ["${var.cors_origins}"]

  # We don't want a separate CNAME entry
  create_dns_entry = false

  custom_labels = "${var.custom_labels}"
}
