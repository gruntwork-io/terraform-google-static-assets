# Google Cloud Storage Static Website

This Terraform Module creates a [Google Cloud Storage](https://cloud.google.com/storage/) bucket that can be used to host a [static
website](https://cloud.google.com/storage/docs/hosting-static-website). That is, the website can contain static HTML, CSS, JS, and images. This module also allows you to optionally create a custom domain name for it.

Some benefits of hosting your static assets, like images or JavaScript files, in a bucket include:

* Cloud Storage behaves essentially like a Content Delivery Network (CDN) with no work on your part because publicly readable objects are, by default, cached in the Cloud Storage network.
* Bandwidth charges for accessing content typically cost less with Cloud Storage.
* The load on your web servers is lessened when serving the static content from Cloud Storage.



## Quick Start

* See the [cloud-storage-static-website example](https://github.com/gruntwork-io/terraform-google-static-assets/blob/master/examples/cloud-storage-static-website) for working sample code.
* Check out [variables.tf](https://github.com/gruntwork-io/terraform-google-static-assets/blob/master/variables.tf) for all parameters you can set for this module.



## How do I test my website?

This module outputs the domain name of your website using the `website_url` output variable.

By default, the URL for your assets name will be of the form:

```
storage.googleapis.com/[BUCKET_NAME]/
```

Where `BUCKET_NAME` is the name you specified for the website with `var.website_domain_name`.

If you set `var.create_dns_entry` to true, then this module will create a DNS CNAME record in [Google Domains](https://domains.google/#/) 
for your bucket with the domain name in `var.website_domain_name`, and you will 
be able to use that custom domain name to access your bucket instead of the `storage.googleapis.com` domain.

**NOTE:** When using a custom domain, you will not be able to access your site over HTTPS, as Google Cloud Storage does not allow SSL on a custom domain. Also note that you will only be able to serve individual files with the `storage.googleapis.com` url, such as `https://storage.googleapis.com/acme.com/badge.svg`, as Google does not enable the website functionality without a custom domain.




## How do I control access to my website?

By default, the module makes your website publicly accessible by setting the default object ACL to `"READER:allUsers"`. For more fine-grained access control, you can set [ACLs](https://cloud.google.com/storage/docs/access-control/lists) using the `website_acls`  variable, for example ["READER:your-work-group@googlegroups.com"]  

You can read more about access control here: https://cloud.google.com/storage/docs/access-control/




## How do I configure HTTPS (SSL) or a CDN?

Accessing through google storage domain is by default having SSL enabled. However, when you intend to use a custom domain, Google Cloud Storage does not enable SSL on a custom domain.

To serve your content through a custom domain over SSL, you can 
* Use the [http-load-balancer-website](https://github.com/gruntwork-io/terraform-google-static-assets/tree/master/modules/http-load-balancer-website) module

* [Use a third-party Content Delivery Network](https://cloudplatform.googleblog.com/2015/09/push-google-cloud-origin-content-out-to-users.html) with Cloud Storage
  <!-- * Serve your static website content from [Firebase Hosting](https://firebase.google.com/docs/hosting/) using the using the [Firebase CDN module](/modules/firebase-cdn). --> 

  


## How do I encrypt the buckets?

Cloud Storage always encrypts your data on the server side, before it is written to disk, at no additional charge. See https://cloud.google.com/storage/docs/encryption/.



## How do I handle www + root domains?

If you are using your Cloud Storage bucket for both the `www.` and root domain of a website (e.g. `www.foo.com` and `foo.com`),
you can create [Synthetic records](https://support.google.com/domains/answer/6069273?hl=en) with [Subdomain forwarding](https://support.google.com/domains/answer/6072198).