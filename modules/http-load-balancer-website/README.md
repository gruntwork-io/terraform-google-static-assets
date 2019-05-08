# HTTP Load Balancer Static Website

This Terraform Module deploys a [HTTP Load Balancer](https://cloud.google.com/load-balancing/docs/https/) that routes 
requests to a [Google Cloud Storage](https://cloud.google.com/storage/) bucket for static content hosting. Internally the 
module uses the [terraform-google-load-balancer](https://github.com/gruntwork-io/terraform-google-load-balancer) 
[http-load-balancer](https://github.com/gruntwork-io/terraform-google-load-balancer/tree/master/modules/http-load-balancer) -module.

Some benefits of serving your static assets, like images or JavaScript files, with a Cloud Load Balancer include:

* It allows you to configure SSL with a custom domain name.
* Cloud Load Balancing is integrated with [Google Cloud CDN](https://cloud.google.com/cdn/) for optimal 
application and content delivery
* Cloud Load Balancing will automatically scale without pre-warming as your users and traffic grow


## Quick Start

* See the [http-load-balancer-website example](https://github.com/gruntwork-io/terraform-google-static-assets/tree/master/examples/http-load-balancer-website) for working sample code.
* Check out [variables.tf](https://github.com/gruntwork-io/terraform-google-static-assets/blob/master/modules/http-load-balancer-website/variables.tf) for all parameters you can set for this module.


## How do I test my website?

This module outputs the IP address of your load balancer website using the `load_balancer_ip_address` output variable.

If you set `var.create_dns_entry` to true, then this module will create a DNS A record in [Google Domains](https://domains.google/#/) 
for your load balancer with the domain name in `var.website_domain_name`, and you will 
be able to use that custom domain name to access your bucket instead of the IP address.


## How do I control access to my website?

By default, the module makes your website publicly accessible by setting the website bucket default object ACL to
 `"READER:allUsers"`. For more fine-grained access control, you can set [ACLs](https://cloud.google.com/storage/docs/access-control/lists) 
 using the `website_acls`  variable. For example setting to `["READER:your-work-group@googlegroups.com"]` restricts
 access to only users in the group `your-work-group`.  

You can read more about access control in [the official documentation](https://cloud.google.com/storage/docs/access-control/).


## How do I configure HTTPS (SSL)?

To enable serving your content through a custom domain over SSL, you can use the `enable_ssl` and `website_domain_name` 
input variables. You will also have to pass a link to an SSL certificate with `ssl_certificate` input variable.  


## How do I encrypt the buckets?

Cloud Storage always encrypts your data on the server side, before it is written to disk, at no additional charge. 
See https://cloud.google.com/storage/docs/encryption/.


## How do I handle www + root domains?

If you are using your Cloud Storage bucket for both the `www.` and root domain of a website (e.g. `www.foo.com` and `foo.com`),
you can create [Synthetic records](https://support.google.com/domains/answer/6069273?hl=en) with 
[Subdomain forwarding](https://support.google.com/domains/answer/6072198).
