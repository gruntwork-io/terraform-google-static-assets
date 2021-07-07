# ---------------------------------------------------------------------------------------------------------------------
# LAUNCH A STATIC WEBSITE USING CLOUD LOAD BALANCER
#
# This is an example of how to use the cloud-load-balancer-website module to deploy a static website with a custom domain.
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  # This module is now only being tested with Terraform 0.14.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 0.14.x code.
  required_version = ">= 0.12.26"

  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 3.50.0"
    }
  }
}

# ------------------------------------------------------------------------------
# CONFIGURE OUR GCP CONNECTION
# ------------------------------------------------------------------------------

provider "google-beta" {
  project = var.project
}

# ------------------------------------------------------------------------------
# CREATE THE SITE
# ------------------------------------------------------------------------------

module "static_site" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "github.com/gruntwork-io/terraform-google-static-assets.git//modules/http-load-balancer-website?ref=v0.3.0"
  source = "../../modules/http-load-balancer-website"

  project = var.project

  website_domain_name = var.website_domain_name
  website_location    = var.website_location

  force_destroy_access_logs_bucket = var.force_destroy_access_logs_bucket
  force_destroy_website            = var.force_destroy_website

  create_dns_entry      = var.create_dns_entry
  dns_record_ttl        = var.dns_record_ttl
  dns_managed_zone_name = var.dns_managed_zone_name

  enable_versioning = var.enable_versioning

  index_page     = var.index_page
  not_found_page = var.not_found_page

  enable_cdn  = false
  enable_ssl  = var.enable_ssl
  enable_http = var.enable_http

  ssl_certificate = join("", google_compute_ssl_certificate.certificate.*.self_link)

  custom_headers = var.custom_headers
}

# ------------------------------------------------------------------------------
# CREATE DEFAULT PAGES
# ------------------------------------------------------------------------------

resource "google_storage_bucket_object" "index" {
  name    = var.index_page
  content = "Hello, World!"
  bucket  = module.static_site.website_bucket_name
}

resource "google_storage_bucket_object" "not_found" {
  name    = var.not_found_page
  content = "Uh oh"
  bucket  = module.static_site.website_bucket_name
}

# ------------------------------------------------------------------------------
# SET GLOBAL READ PERMISSIONS
# ------------------------------------------------------------------------------

resource "google_storage_object_acl" "index_acl" {
  bucket      = module.static_site.website_bucket_name
  object      = google_storage_bucket_object.index.name
  role_entity = ["READER:allUsers"]
}

resource "google_storage_object_acl" "not_found_acl" {
  bucket      = module.static_site.website_bucket_name
  object      = google_storage_bucket_object.not_found.name
  role_entity = ["READER:allUsers"]
}

# ------------------------------------------------------------------------------
# IF SSL IS ENABLED, CREATE A SELF-SIGNED CERTIFICATE
#
# In a production setup, you will likely manage your certificates separately.
# ------------------------------------------------------------------------------

resource "tls_self_signed_cert" "cert" {
  count = var.enable_ssl ? 1 : 0

  key_algorithm   = "RSA"
  private_key_pem = join("", tls_private_key.private_key.*.private_key_pem)

  subject {
    common_name  = var.website_domain_name
    organization = "Examples, Inc"
  }

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "tls_private_key" "private_key" {
  count = var.enable_ssl ? 1 : 0

  algorithm   = "RSA"
  ecdsa_curve = "P256"
}

# ------------------------------------------------------------------------------
# CREATE A CORRESPONDING GOOGLE CERTIFICATE THAT WE CAN ATTACH TO THE LOAD BALANCER
# ------------------------------------------------------------------------------

resource "google_compute_ssl_certificate" "certificate" {
  count = var.enable_ssl ? 1 : 0

  project  = var.project
  provider = google-beta

  name_prefix = "petri-test"
  description = "SSL Certificate for ${var.website_domain_name}"
  private_key = join("", tls_private_key.private_key.*.private_key_pem)
  certificate = join("", tls_self_signed_cert.cert.*.cert_pem)

  lifecycle {
    create_before_destroy = true
  }
}
