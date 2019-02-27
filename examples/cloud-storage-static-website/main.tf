provider "google-beta" {
  region  = "europe-north1"
  project = "dev-sandbox-228703"
}

module "site" {
  source                           = "../../modules/cloud-storage-static-website"
  project                          = "dev-sandbox-228703"
  website_domain_name              = "acme.gcloud-dev.com"
  website_location                 = "EU"
  force_destroy_access_logs_bucket = "true"
  force_destroy_website            = "true"
  create_dns_entry                 = true
  dns_managed_zone_name            = "gclouddev"
  enable_cors                      = "true"
  cors_methods                     = ["*"]
  cors_origins                     = ["*"]
}

output "website_url" {
  description = "URL of the website"
  value       = "${module.site.website_url}"
}

output "website_bucket" {
  description = "Self link to the website bucket"
  value       = "${module.site.website_bucket}"
}

output "access_logs_bucket" {
  description = "Self link to the access logs bucket"
  value       = "${module.site.access_logs_bucket}"
}
