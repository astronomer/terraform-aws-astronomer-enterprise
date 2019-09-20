variable "route53_domain" {
  description = "The name of your public route53 hosted zone, does not include a trailing dot. Should match the domain. This is used to generate a certificate with let's encrypt"
  type        = string
}

variable "management_api" {
  description = "'public' or 'private', this will enable / disable the public EKS endpoint. It's easier to deploy the platform from scratch if you leave it public. Then you can just toggle if off in the console for better security."
  type        = string
}

variable "email" {
  description = "Email address to use when requesting the let's encrypt TLS certificate"
  type        = string
}

variable "vpc_id" {
  default     = ""
  description = "The VPC ID in which your subnets are located, empty string means create a VPC from scratch"
  type        = string
}

variable "deployment_id" {
  description = "A short, letters-only string to identify your deployment, and to prefix some AWS resources. We recommend 'astro'."
  type        = string
}

variable "private_subnets" {
  default     = []
  description = "list of subnet ids, should be private subnets in different AZs"
  type        = list(string)
}

variable "enable_windows_box" {
  default     = false
  description = "Launch a Windows instance with Firefox installed in a public subnet?"
  type        = bool
}

variable "enable_bastion" {
  default     = false
  description = "Launch a bastion in a public subnet? For this to work, you must include 1 subnet id in the public_subets variable"
  type        = bool
}

variable "min_cluster_size" {
  default     = 6
  description = "The minimum number of instance in the EKS worker nodes auto scaling group."
  type        = number
}

variable "max_cluster_size" {
  default     = 12
  description = "The maximum number of instance in the EKS worker nodes auto scaling group."
  type        = number
}

variable "tags" {
  description = "A mapping of tags to be applied to AWS resources"
  default     = {}
  type        = map(string)
}

variable "security_groups_to_whitelist_on_eks_api" {
  description = "A list of security group IDs to whitelist on the EKS management security group using security group referencing. For example, if you have a security group assigned to your terraform server, you can add that security group to this list to allow access to the private EKS endpoint from that server."
  default     = []
  type        = list
}

variable "ten_dot_what_cidr" {
  description = "This variable is applicable only when creating a VPC. 10.X.0.0/16 - choose X."

  # This is probably not that common
  default = "234"
  type    = string
}

variable "cluster_type" {
  description = "Toggle the type of cluster - public or private"
  default     = "private"
  type        = string
}

variable "private_load_balancer" {
  description = "Enable / disable private load balancer. The web UI will be publicly accessible when disabled. Use boolean value true or false"
  default     = true
  type        = bool
}

variable "astronomer_version" {
  description = "Version of the Astronomer platform installed"
  default     = "0.10.0"
  type        = string
}

variable "cluster_version" {
  default = null
  type    = string
}
