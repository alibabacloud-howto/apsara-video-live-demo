variable "domain_name" {
  description = "Domain name of the project."
  default = "my-sample-domain.xyz"
}

variable "certman_sub_domain_name" {
  description = "Sub-domain name of the certificate manager."
  default = "livevideo-certman"
}

variable "apsaravideolive_pull_top_domain_name" {
  description = "Pull domain name for the Apsara Video Live service."
  default = "my-sample-domain.xyz"
}

variable "apsaravideolive_pull_sub_domain_name" {
  description = "Pull sub-domain name for the Apsara Video Live service."
  default = "livevideo-pull"
}

variable "ecs_root_password" {
  description = "ECS root password (simpler to configure than key pairs)"
  default = "YourR00tP@ssword"
}

variable "api_user_accesskey_id" {
  description = "Access key ID of a user that can call CDN and DNS OpenAPIs."
  default = "api-access-key-id"
}

variable "api_user_accesskey_secret" {
  description = "Access key secret of a user that can call CDN and DNS OpenAPIs."
  default = "api-access-key-secret"
}

variable "api_region_id" {
  description = "Region ID of this server."
  default = "ap-southeast-1"
}

variable "lets_encrypt_email_address" {
  description = "Email address for Let's Encrypt to notify us when a certificate is going to be expired."
  default = "john.doe@example.net"
}