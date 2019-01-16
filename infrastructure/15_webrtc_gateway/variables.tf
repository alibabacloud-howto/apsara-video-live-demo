variable "domain_name" {
  description = "Domain name of the project."
  default = "my-sample-domain.xyz"
}

variable "webrtcgw_sub_domain_name" {
  description = "Sub-domain name of the WebRTC gateway."
  default = "livevideo-webrtcgw"
}

variable "turnstun_sub_domain_name" {
  description = "Sub-domain name of the TURN / STUN server."
  default = "livevideo-turnstun"
}

variable "ecs_root_password" {
  description = "ECS root password (simpler to configure than key pairs)"
  default = "YourR00tP@ssword"
}

variable "turn_user" {
  description = "Username to authenticate to the TURN server."
  default = "livevideo"
}

variable "turn_password" {
  description = "Password to authenticate to the TURN server."
  default = "YourTurnPassw0rd"
}