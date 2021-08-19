[![Maintained by Gruntwork.io](https://img.shields.io/badge/maintained%20by-gruntwork.io-%235849a6.svg)](https://gruntwork.io/?ref=repo_google_static_assets)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/gruntwork-io/terraform-google-static-assets.svg?label=latest)](https://github.com/gruntwork-io/terraform-google-static-assets/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D1.0.x-blue.svg)

<!-- NOTE: Because the module is published to Terraform Module Registry, we have to use absolute links in all READMEs. -->

# Static Assets Modules

This repo contains modules for managing static assets (CSS, JS, images) in GCP.

## Quickstart

If you want to quickly launch a static website using [Google Cloud Storage](https://cloud.google.com/storage/),
you can run the example that is in the root of this repo. Check out the [cloud-storage-static-website example documentation](https://github.com/gruntwork-io/terraform-google-static-assets/blob/master/examples/cloud-storage-static-website) for instructions.

## What's in this repo

This repo has the following folder structure:

- [root](https://github.com/gruntwork-io/terraform-google-static-assets/tree/master): The root folder contains an example of how to launch a static website using [Google Cloud Storage](https://cloud.google.com/storage/). See [cloud-storage-static-website example documentation](https://github.com/gruntwork-io/terraform-google-static-assets/blob/master/examples/cloud-storage-static-website) for the documentation.

- [modules](https://github.com/gruntwork-io/terraform-google-static-assets/blob/master/modules): This folder contains the main implementation code for this Module.

  The primary modules are:

  - [cloud-storage-static-website](https://github.com/gruntwork-io/terraform-google-static-assets/blob/master/modules/cloud-storage-static-website):
    The Cloud Storage Static Website module is used to create a [Google Cloud Storage](https://cloud.google.com/storage/)
    bucket that can be used to host a [static website](https://cloud.google.com/storage/docs/hosting-static-website).

  - [http-load-balancer-website](https://github.com/gruntwork-io/terraform-google-static-assets/blob/master/modules/http-load-balancer-website):
    The HTTP Load Balancer Website module is used to create a [HTTP Load Balancer](https://cloud.google.com/load-balancing/docs/https/)
    that routes requests to a [Google Cloud Storage](https://cloud.google.com/storage/) bucket for static content hosting,
    allowing you to also configure SSL with a custom domain name.

- [examples](https://github.com/gruntwork-io/terraform-google-static-assets/blob/master/examples): This folder contains examples of how to use the submodules.

- [test](https://github.com/gruntwork-io/terraform-google-static-assets/blob/master/test): Automated tests for the submodules and examples.

## Who maintains this Module?

This Module and its Submodules are maintained by [Gruntwork](http://www.gruntwork.io/). Read the [Gruntwork Philosophy](/GRUNTWORK_PHILOSOPHY.md) document to learn more about how Gruntwork builds production grade infrastructure code. If you are looking for help or commercial support, send an email to
[support@gruntwork.io](mailto:support@gruntwork.io?Subject=Google%20Static%20Assets%20Module).

Gruntwork can help with:

- Setup, customization, and support for this Module.
- Modules and submodules for other types of infrastructure, such as VPCs, Docker clusters, databases, and continuous
  integration.
- Modules and Submodules that meet compliance requirements, such as HIPAA.
- Consulting & Training on GCP, AWS, Terraform, and DevOps.

## How do I contribute to this Module?

Contributions are very welcome! Check out the [Contribution Guidelines](https://github.com/gruntwork-io/terraform-google-static-assets/blob/master/CONTRIBUTING.md) for instructions.

## How is this Module versioned?

This Module follows the principles of [Semantic Versioning](http://semver.org/). You can find each new release, along
with the changelog, in the [Releases Page](https://github.com/gruntwork-io/terraform-google-static-assets/releases).

During initial development, the major version will be 0 (e.g., `0.x.y`), which indicates the code does not yet have a stable API. Once we hit `1.0.0`, we will make every effort to maintain a backwards compatible API and use the MAJOR, MINOR, and PATCH versions on each release to indicate any incompatibilities.

## License

Please see [LICENSE.txt](https://github.com/gruntwork-io/terraform-google-static-assets/blob/master/LICENSE.txt) for details on how the code in this repo is licensed.
