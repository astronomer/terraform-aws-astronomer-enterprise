variable deployment_id {}

variable route53_domain {
  default = "astronomer-development.com"
}

# A windows instance with firefox
# and network access to the deployment.
# Useful for debugging.
# It's unnecessary for most use cases.
variable enable_windows_box {
  default = false
}

module "astronomer_aws_from_scratch" {
  # To use this module, source like this:
  # source          = "astronomer/astronomer-enterprise/aws"
  # and provide a version:
  # version         = "< supply version >"
  source = "../.."

  # a collision avoidance variable used to separate
  # deployments in the same account
  deployment_id = var.deployment_id

  # provide your email
  email = "steven@astronomer.io"

  # supply your public DNS hosted zone name
  route53_domain = var.route53_domain

  # EKS kubernetes management endpoint
  management_api = "public"

  enable_bastion     = true
  enable_windows_box = var.enable_windows_box

  # This configuration serves the platform publicly
  allow_public_load_balancers = true
  astronomer_helm_values      = <<EOF
  global:
    # Replace to match your certificate, less the wildcard.
    # If you are using Let's Encrypt + Route 53, then it should be <deployment_id>.<route53_domain>
    # For example, astro.your-route53-domain.com
    baseDomain: ${var.deployment_id}.${var.route53_domain}
    tlsSecret: astronomer-tls
    postgresqlEnabled: false
  nginx:
    privateLoadBalancer: false
  astronomer:
    houston:
      config:
        publicSignups: false
  EOF

  # Choose tags for the AWS resources
  tags = {
    "CI" = "true"
  }
}

# used for debugging

output "windows_debug_box_password" {
  value = module.astronomer_aws_from_scratch.windows_debug_box_password
}

output "windows_debug_box_hostname" {
  value = module.astronomer_aws_from_scratch.windows_debug_box_hostname
}
