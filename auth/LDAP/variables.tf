variable "srv_pass" {
  description = "Service Account (Bind DN) password"
  type        = string
  sensitive   = true
  ephemeral   = true
}