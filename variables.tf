variable "route53_domain" {
  description = "The name of your public route53 hosted zone, does not include a trailing dot. Should match the domain. This is used to generate a certificate with let's encrypt. If you don't want to make a certificate with let's encrypt, and you also don't want the DNS record created on your behalf, then set this as an empty string, set create_record to falsee, and provide tls_cert and tls_key variables"
  type        = string
}

variable "create_record" {
  description = "The name of your public Route 53 hosted zone, does not include a trailing dot. Should match the domain. This is used to generate a certificate with Let's Encrypt"
  default     = true
  type        = bool
}

variable "allow_public_load_balancers" {
  description = "Configuring this variable will allow for public load balancers to be created in the Kubernetes. You need to turn this on if you want to serve Astronomer publicly and you also need to configure nginx.privateLoadBalancer in the Astronomer Helm values."
  default     = false
  type        = bool
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

variable "db_subnets" {
  default     = []
  type        = list
  description = "This variable does nothing unless vpc_id is also set. Specify the subnet IDs in which the DB will be deployed. If not provided, it will fall back to private_subnets."
}

variable "bastion_subnet" {
  default     = ""
  description = "Public subnet ID for use with bastion host when enable_bastion variable is true and using bring-your-own VPC configuration (vpc_id and private_subnets provided by user)."
  type        = string
}

variable "enable_windows_box" {
  default     = false
  description = "Launch a Windows instance with Firefox installed in a public subnet?"
  type        = bool
}

variable "enable_bastion" {
  default     = false
  description = "Launch a bastion in a public subnet. For this to work with bring-your-own VPC configuration, you must include a public subnet id in the bastion_subnets variable. This should be in the same VPC as vpc_id and the provided private subnets."
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

variable "astronomer_version" {
  description = "Version of the Astronomer platform installed"
  default     = "0.10.2"
  type        = string
}

variable "cluster_version" {
  default = "1.15"
  type    = string
}

variable "tls_cert" {
  default     = ""
  type        = string
  description = "The signed certificate for the Astronomer Load Balancer. It should be signed by a certificate authorize and should have common name *.base_domain."
}

variable "tls_key" {
  default     = ""
  type        = string
  description = "The private key corresponding to the signed certificate tls_cert."
}

variable "lets_encrypt" {
  default = true
  type    = bool
}

variable "db_instance_type" {
  default = "db.r4.large"
  type    = string
}

variable "worker_instance_type" {
  default = "m5.xlarge"
  type    = string
}

variable "db_replica_count" {
  description = "How many replicas for the database"
  default     = 1
  type        = number
}

variable "astronomer_helm_values" {
  default     = ""
  description = "Values in raw yaml to pass to Helm to override defaults in Astronomer Helm chart. Please see the Astronomer Helm chart's values.yaml for options. global.baseDomain is required. https://github.com/astronomer/astronomer/blob/master/values.yaml"
  type        = string
}
