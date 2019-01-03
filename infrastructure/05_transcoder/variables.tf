variable "domain_name" {
  description = "Domain name of the project."
  default = "my-sample-domain.xyz"
}

variable "transcoder_sub_domain_name" {
  description = "Sub-domain name of the transcoding server."
  default = "livevideo-transcoder"
}

variable "ecs_root_password" {
  description = "ECS root password (simpler to configure than key pairs)"
  default = "YourR00tP@ssword"
}