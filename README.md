# Astronomer Enterprise

Updates are not guaranteed to be non-interrupting. Always use Terraform best-practices when deploying updates by reviewing the Terraform "plan" and understanding the impact before applying.

# Architecture

- optional bastion
- optional VPC and subnet creation
- optional public or private for application load balancer

![Astronomer Private Cloud Architecture](images/Astronomer_AWS_Architecture_EE.svg)

Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions.

You can read more about it here https://www.terraform.io/intro/index.html

### Install Astronomer with Terraform

Astronomer’s terraform scripts can be used to automate the provisioning of a production grade Airflow environment.

The [Astronomer Enterprise module for AWS](https://registry.terraform.io/modules/astronomer/astronomer-enterprise/aws) can be used to provision the Astronomer platform in your AWS account. The automation deploys the following by default:

* VPC
* Network
* Database
* Kubernetes
* TLS certificate
* Astronomer

More detailed information can also be found here:
https://github.com/astronomer/terraform-aws-astronomer-enterprise

## Prerequisites

Install the necessary tools:

* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
* [AWS IAM Authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
* [Terraform](https://www.terraform.io/downloads.html) *Use version 0.12.3 or later*
* [Helm client](https://github.com/helm/helm#install) *Use version 2, 2.14.1 or later*
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) *Use the version appropriate for your Kubernetes cluster version*

## Installation

### Configure the AWS CLI

Run the following command and enter the appropriate values when prompted. If you don't know the `AWS Access Key ID` or `AWS Secret Access Key` for your account, contact your AWS admin.

```
aws configure
```

Confirm you are authenticated

```
aws sts get-caller-identity
```

### Write the Terraform

Make a new directory to work in. Read through this configuration and replace values where appropriate, writing to a file "astronomer.tf"

```
provider "aws" {
  region = "us-east-1"
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

terraform {
  required_version = ">= 0.12"
  backend "s3" {
	  bucket  = "astronomer-platform"
	  key	    = "terraform-state"
	  region  = "us-east-1"
    encrypt = true
  }
}

module "astronomer-enterprise" {
  source                = "astronomer/astronomer-enterprise/aws"
  # Look up the most recent version in the Terraform Registry
  version               = "TODO"
  email                 = "your-name@your-domain.com"
  deployment_id         = "astro"
  route53_domain        = "a-domain-you-own-in-your-route-53.com"
  management_api        = "public"
}
```

- email: used to create a Let's Encrypt user
- deployment_id: a short, character-only prefix for AWS resources that enables deployment of multiple Astronomer platforms in the same account
- management_api: a configuration for the Kubernetes API - public is recommended for deployment, see the Terraform registry documentation
- route53_domain: the domain that will be used for your Astronomer platform

The above options alone are sufficient to deploy a new VPC, network, database, Kubernetes cluster, Let's Encrypt certificate, and Astronomer. Before production, all options should be reviewed, especially the following options:

- db_instance_type
- worker_instance_type
- max_cluster_size
- tags

Features are often added to this module. A full list of configuration options, and more detailed descriptions, can be found on the [Terraform Registry](https://registry.terraform.io/modules/astronomer/astronomer-aws/aws). There are configurations available to deploy into existing AWS networks.

### Plan access

After the Terraform apply is complete in the next step, the platform will be running on `app.<deployment_id>.<route53_domain>`. By default, the platform will be deployed on a private network, so this domain will only be accessible from inside the VPC in which it's deployed. There are a few options to consider for access to Astronomer.

- Deploy into an existing VPC in your network (see options vpc_id, private_subnets, and db_subnets)
- Deploy a Linux or Windows VM accessible from the public internet that can access the private Astronomer platform (see options enable_bastion and enable_windows_box). Windows will use RDP and Linux will use SSH. Both will be deployed with an IP whitelist only including the public IP address of where the Terraform is executed.
- Deploy the Astronomer on a public endpoint, see below "Different VPC or network configuration"

### Run Terraform

* `terraform init`
* `terraform apply`

When your run the 'apply' command, be sure to review the output before typing 'yes'. This is critical in the case of using Terraform for upgrades. For an initial deployment, it usually takes 15-30 minutes. It may take a few minutes after the web UI is available for the platform to be ready. When there is an option to log in or sign up, then the platform is ready.

A `kubeconfig` file will be generated in your working directory. Be sure to reference this file when running `kubectl` or `helm` commands. Example:
```
export KUBECONFIG=./kubeconfig

kubectl get pods -n astronomer
helm ls
```

The kubeconfig file along with other secrets such as the TLS certificate are backed up in the remote Terraform state S3 bucket.

## Frequently requested infrastructure configurations

Astronomer is installed on Kubernetes. We are making use of the Kubernetes package manager called 'Helm'. All reconfiguration options that are intended for the Astronomer platform rather than Terraform or infrastructure are passed in YAML and will be referred to as "Helm values". For all reconfigurations, you can make use of the Terraform option astronomer_helm_values, which should be a YAML block in a Terraform string. Creating an Astronomer Helm configuration is documented here: https://www.astronomer.io/docs/ee-configyaml/

For any reconfiguration, make sure that your configuration includes at least the following options:
```
global:
  # Replace to match your certificate, less the wildcard.
  # If you are using Let's Encrypt + Route 53, then it should be <deployment_id>.<route53_domain>
  # For example, astro.your-route53-domain.com
  baseDomain: deployment-id.your-domain.com
  tlsSecret: astronomer-tls
nginx:
  privateLoadBalancer: true
```

For example, your Terraform block that calls the Astronomer Enterprise module might look like this:
```
module "astronomer-enterprise" {
  source                  = "astronomer/astronomer-enterprise/aws"
  # Look up the most recent version in the Terraform Registry
  version                 = "TODO"
  email                   = "your-name@your-domain.com"
  deployment_id           = "astro"
  route53_domain          = "a-domain-you-own-in-your-route-53.com"
  management_api          = "public"
  astronomer_helm_values  = <<EOM
  global:
    # Replace to match your certificate, less the wildcard.
    # If you are using Let's Encrypt + Route 53, then it should be <deployment_id>.<route53_domain>
    # For example, astro.your-route53-domain.com
    baseDomain: deployment-id.your-domain.com
    tlsSecret: astronomer-tls
  nginx:
    privateLoadBalancer: true
  EOM
}
```

All possible reconfigurations can be found by browsing the Astronomer Helm chart Github repository. Values are located in values.yaml and all subcharts' values.yaml. For more details, refer to the Helm documentation https://helm.sh/docs/chart_template_guide/values_files/

#### If you do not wish to use Let's Encrypt or provide a Route 53 domain

If you are not going provide a Route 53 domain to get a Let's Encrypt cert, then additional configuration is required. Provide your own TLS certificates using the options tls_cert and tls_key. Astronomer has found this to be a common point of configuration error, so please check after you deploy by accessing the Astronomer UI and making an Airflow deployment using the Astronomer CLI. Docker clients are the most restrictive TLS clients (compared to browsers): it is possible to misconfigure the tls_cert such that it is trusted by a browser and not by a Docker client. If you find that your browsers trust the Astronomer application but 'astro deploy' is not working with a TLS error, please make sure that your TLS cert is properly chained, including both the certificate and issuer pem in the same file, with the issuer second and no newline in between. Your cert should match \*.deployment_id.domain_name, for example "\*.astro.mydomain.com"

With regard to the Astronomer Helm values - global.baseDomain should be the same as your certificate, less the wildcard, for example "astro.mydomain.com".

By default, a certificate will be generated from LetsEncrypt. Certificates can be used from ther sources if they can be exported into plain text PEM format:

```
  lets_encrypt          = false
  tls_cert              = <<EOF
-----BEGIN CERTIFICATE-----
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
-----END CERTIFICATE-----
EOF
  tls_key               = <<EOF
-----BEGIN PRIVATE KEY-----
-----END PRIVATE KEY-----
EOF
}
}
```

#### Different VPC or network configuration

##### Deploy in your existing AWS network

By default, a new VPC and subnets will be created. There are options to allow you to provide your own networks instead:

- vpc_id
- private_subnets
- db_subnets

Make sure that your subnets and VPC meet the tagging requirements outlined here: https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html.

By default, a public subnet is created only to allow egress internet traffic. The cluster, database, and load balancer (where the application is accessed) are placed in the private networks by default. Options that can be changed from default that provision resources in the public subnet are enable_bastion and enable_windows_box. The Kubernetes API will be deployed into the public internet by default. This is to enable a one-click solution (deploy network, deploy Kubernetes in that network, deploy application on Kubernetes all in one go). Otherwise you have to deploy the VPC, networks, and Kubernetes, then deploy the rest executing Terraform from inside the VPC. It is best security practice to disable the public Kubernetes API when you are not using it. This can be accomplished using AWS EKS in the AWS console, this can be safely toggled to private in a non-interrupting fashion when Terraform is not being used. If you want to use Terraform again, just re-enable it. To use Terraform completely privately from scratch, you will need to deploy from an existing VPC into the same VPC.

##### Deploy on public internet

If you want to serve the platform itself publicly, then you need to configure both the infrastructure to allow this (setting up tags on the public subnets to allow the creation of load balancers) and configure the platform to deploy its load balancer into a public subnet. If you are using your own network, see above. If you are using Route 53 + Let's Encrypt automation, then the following configuration alone will work.

Provide these options to the Astronomer enterprise module for public access to be enabled:
```
  # This configuration serves the platform publicly
  allow_public_load_balancers = true
  astronomer_helm_values = <<EOF
  global:
    baseDomain: ${var.deployment_id}.${var.route53_domain}
    tlsSecret: astronomer-tls
  nginx:
    privateLoadBalancer: false
  astronomer:
    houston:
      config:
        # Only the first user will be allowed to sign up
        # and will be granted top-level admin. Then all
        # remaining users must be invited to the platform.
        # SMTP must be configured for invitations to work.
        publicSignups: false
  EOF

```

## Multiple AZ Database

To deploy the Aurora database to multiple availability zones, additional replicas and subnets in different AZs need to be specified:

```
  db_replica_count      = 2
  db_subnets            = []
```

**Note:** `db_subnets` only need to be specified if deploying to pre-existing subnets. Otherwise, all subnets will be created fresh and the `db_subnets` parameter can be excluded from the enterprise module.
