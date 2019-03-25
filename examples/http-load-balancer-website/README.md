# HTTP Load Balancer Website Example

This example deploys a [HTTP Load Balancer](https://cloud.google.com/load-balancing/docs/https/) that routes 
requests to a [Google Cloud Storage](https://cloud.google.com/storage/) bucket for static content hosting.


## How do you run this example?

To run this example, you need to:

1. Install [Terraform](https://www.terraform.io/).
1. Open up `variables.tf` and set secrets at the top of the file as environment variables and fill in any other variables 
in the file that don't have defaults. 
1. `terraform init`.
1. `terraform plan`.
1. If the plan looks good, run `terraform apply`.

When the `apply` command finishes, this module will output the load balancer public IP address you can use to test the 
website in your web browser.
