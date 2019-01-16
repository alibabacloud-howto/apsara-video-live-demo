variable "domain_name" {
  description = "Domain name of the project."
  default = "my-sample-domain.xyz"
}

variable "webapp_sub_domain_name" {
  description = "Sub-domain name of the web application."
  default = "livevideo"
}

variable "webrtcgw_sub_domain_name" {
  description = "Sub-domain name of the WebRTC gateway."
  default = "livevideo-webrtcgw"
}

variable "turnstun_sub_domain_name" {
  description = "Sub-domain name of the TURN / STUN server."
  default = "livevideo-turnstun"
}

variable "transcoder_sub_domain_name" {
  description = "Sub-domain name of the transcoding server."
  default = "livevideo-transcoder"
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

variable "apsaravideolive_user_accesskey_id" {
  description = "Access key ID of the (RAM) user that can access to Apsara Video Live."
  default = "avl-access-key-id"
}

variable "apsaravideolive_user_accesskey_secret" {
  description = "Access key secret of the (RAM) user that can access to Apsara Video Live."
  default = "avl-access-key-secret"
}

variable "apsaravideolive_region_id" {
  description = "Region ID where the Apsara Video Live service is running."
  default = "ap-southeast-1"
}

variable "apsaravideolive_push_domain" {
  description = "Push domain name for the Apsara Video Live service."
  default = "livevideo-push.my-sample-domain.xyz"
}

variable "apsaravideolive_pull_domain" {
  description = "Pull domain name for the Apsara Video Live service."
  default = "livevideo-pull.my-sample-domain.xyz"
}

variable "apsaravideolive_app_name" {
  description = "Application name for the Apsara Video Live service (allow several applications to share one domain)."
  default = "livevideo"
}

variable "apsaravideolive_push_auth_primary_key" {
  description = "Primary key for the authentication for the push domain."
  default = "push-primary-key"
}

variable "apsaravideolive_push_auth_validity_period" {
  description = "Validity period in seconds of an authentication key for the push domain."
  default = 1800
}

variable "apsaravideolive_pull_auth_primary_key" {
  description = "Primary key for the authentication for the pull domain."
  default = "pull-primary-key"
}

variable "apsaravideolive_pull_auth_validity_period" {
  description = "Validity period in seconds of an authentication key for the pull domain."
  default = 1800
}