variable "domain_name" {
  description = "Domain name of the project."
  default = "my-sample-domain.xyz"
}

variable "webapp_sub_domain_name" {
  description = "Sub-domain name of the web application."
  default = "livevideo"
}

variable "transcoding_sub_domain_name" {
  description = "Sub-domain name of the transcoding server."
  default = "livevideo-transcoding"
}

variable "ecs_root_password" {
  description = "ECS root password (simpler to configure than key pairs)"
  default = "YourR00tP@ssword"
}