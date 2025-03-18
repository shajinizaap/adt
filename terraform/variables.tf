variable "project_id" {
  description = "GCP Project ID"
}

variable "region" {
  description = "GCP Region"
  default     = "us-central1"
}

variable "function_name" {
  description = "Name of the Cloud Function"
  default     = "hello-world"
}

variable "runtime" {
  description = "Runtime for the Cloud Function"
  default     = "python39"
}

variable "memory_mb" {
  description = "Memory allocation for the Cloud Function (MB)"
  default     = 128
}

variable "lb_name" {
  description = "Load Balancer Name"
  default     = "hello-world-lb"
}
