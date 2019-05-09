# Cloud Storage Static Website Example

The root folder of this repo shows an example of how to use the [cloud-storage-static-website module](https://github.com/gruntwork-io/terraform-google-static-assets/tree/master/modules/cloud-storage-static-website) to launch a
static website on top of [Google Cloud Storage](https://cloud.google.com/storage/). 


## How do you run this example?
   
To run this example, you need to:
   
1. Install [Terraform](https://www.terraform.io/).
1. Make sure you are in the root folder of the repo.
1. Open up `variables.tf` and set secrets at the top of the file as environment variables and fill in any other variables in the file that don't have defaults. 
1. `terraform init`.
1. `terraform plan`.
1. If the plan looks good, run `terraform apply`.

When the `apply` command finishes, this module will output the domain name you can use to test the website in your web browser.





