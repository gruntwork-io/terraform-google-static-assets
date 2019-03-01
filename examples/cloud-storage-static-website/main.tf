# ---------------------------------------------------------------------------------------------------------------------
# LAUNCH A STATIC WEBSITE USING CLOUD STORAGE
#
# This is an example of how to use the cloud-storage-static-website module to deploy a static website with a custom domain.
# ---------------------------------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# CONFIGURE OUR GCP CONNECTION
# ------------------------------------------------------------------------------

provider "google-beta" {
  project = "${var.project}"
}

# ------------------------------------------------------------------------------
# CREATE THE SITE
# ------------------------------------------------------------------------------

module "static_site" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "git::git@github.com:gruntwork-io/terraform-google-static-assets.git//modules/cloud-storage-static-website?ref=v0.1.0"
  source = "../../modules/cloud-storage-static-website"

  project = "${var.project}"

  website_domain_name = "${var.website_domain_name}"
  website_location    = "${var.website_location}"

  force_destroy_access_logs_bucket = "${var.force_destroy_access_logs_bucket}"
  force_destroy_website            = "${var.force_destroy_website}"

  create_dns_entry      = "${var.create_dns_entry}"
  dns_record_ttl        = "${var.dns_record_ttl}"
  dns_managed_zone_name = "${var.dns_managed_zone_name}"

  enable_versioning = "${var.enable_versioning}"

  index_page     = "${var.index_page}"
  not_found_page = "${var.not_found_page}"
}

# ------------------------------------------------------------------------------
# CREATE DEFAULT PAGES
# ------------------------------------------------------------------------------

resource "google_storage_bucket_object" "index" {
  name    = "${var.index_page}"
  content = "Hello, World!"
  bucket  = "${module.static_site.website_bucket_name}"
}

resource "google_storage_bucket_object" "not_found" {
  name    = "${var.not_found_page}"
  content = "Uh oh"
  bucket  = "${module.static_site.website_bucket_name}"
}

# ------------------------------------------------------------------------------
# SET GLOBAL READ PERMISSIONS
# ------------------------------------------------------------------------------

resource "google_storage_object_acl" "index_acl" {
  bucket      = "${module.static_site.website_bucket_name}"
  object      = "${google_storage_bucket_object.index.name}"
  role_entity = ["READER:allUsers"]
}

resource "google_storage_object_acl" "not_found_acl" {
  bucket      = "${module.static_site.website_bucket_name}"
  object      = "${google_storage_bucket_object.not_found.name}"
  role_entity = ["READER:allUsers"]
}
