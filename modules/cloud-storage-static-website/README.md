# Google Cloud Storage Static Website

This Terraform Module creates an [Google Cloud Storage](https://cloud.google.com/storage/) bucket that can be used to host a [static
website](https://cloud.google.com/storage/docs/hosting-static-website). That is, the website can contain static HTML, CSS, JS, and images. This module allows you to specify custom routing rules for the website and optionally, create a custom domain name for it. 

Some benefits of hosting your static assets, like images or JavaScript files, in a bucket include:

* Cloud Storage behaves essentially like a Content Delivery Network (CDN) with no work on your part because publicly readable objects are, by default, cached in the Cloud Storage network.
* Bandwidth charges for accessing content typically cost less with Cloud Storage.
* The load on your web servers is lessened when serving the static content from Cloud Storage.



## Quick Start

* See the [cloud-storage-static-website example](/examples/cloud-storage-static-website) for working sample code.
* Check out [variables.tf](variables.tf) for all parameters you can set for this module.



## How do I test my website?

This module outputs the domain name of your website using the `website_domain_name` output variable.

By default, the URL for your assets name will be of the form:

```
storage.googleapis.com/[BUCKET_NAME]/
```

Where `BUCKET_NAME` is the name you specified for the bucket.

If you set `var.create_dns_entry` to true, then this module will create a DNS A record in [Google Domains](https://domains.google/#/) 
for your bucket with the domain name in `var.website_domain_name`, and you will 
be able to use that custom domain name to access your bucket instead of the `storage.googleapis.com` domain.

**NOTE:** When using a custom domain, you will not be able to access your site over HTTPS, as Google Cloud Storage does not allow SSL on a custom domain.


## How do I configure HTTPS (SSL) or a CDN?

Accessing through google storage domain is by default having SSL enabled. However, when you intend to use a custom domain, Google Cloud Storage does not enable SSL on a custom domain.

To serve your content through a custom domain over SSL, [set up a load balancer](https://cloud.google.com/compute/docs/load-balancing/http/adding-a-backend-bucket-to-content-based-load-balancing),
[use a third-party Content Delivery Network](https://cloudplatform.googleblog.com/2015/09/push-google-cloud-origin-content-out-to-users.html) with Cloud Storage, or serve your static website content 
from [Firebase Hosting](https://firebase.google.com/docs/hosting/) using the using the [Firebase CDN module](/modules/firebase-cdn). 



## How do I handle www + root domains?

If you are using your Cloud Storage bucket for both the `www.` and root domain of a website (e.g. `www.foo.com` and `foo.com`),
you can create [Synthetic records](https://support.google.com/domains/answer/6069273?hl=en) with [Subdomain forwarding](https://support.google.com/domains/answer/6072198).
