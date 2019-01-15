variable "domain_name" {
  description = "Domain name of the project."
  default = "my-sample-domain.xyz"
}

variable "turnstun_sub_domain_name" {
  description = "Sub-domain name of the TURN / STUN server."
  default = "livevideo-turnstun"
}

variable "ecs_root_password" {
  description = "ECS root password (simpler to configure than key pairs)"
  default = "YourR00tP@ssword"
}