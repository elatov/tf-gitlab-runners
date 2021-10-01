variable "gcp_project" {
  type        = string
  description = "The GCP project to deploy into."
}

variable "gcp_zone" {
  type        = string
  description = "The GCP zone to deploy into."
}

variable "gcp_region" {
  type        = string
  description = "The GCP region to deploy into."
}

variable "gitlab_url" {
  type        = string
  description = "The URL of the GitLab."
}

variable "ci_token" {
  type        = string
  description = "The runner registration token from GitLab."
}

variable "ci_runner_instance_type" {
  type        = string
  default     = "f1-micro"
  description = "The instance type used for the runner. "
}
