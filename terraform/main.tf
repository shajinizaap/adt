terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Cloud Function
resource "google_cloudfunctions_function" "hello_world" {
  name                  = var.function_name
  runtime               = var.runtime
  available_memory_mb = var.memory_mb
  source_archive_bucket = google_storage_bucket.function_source_bucket.name
  source_archive_object = google_storage_bucket_object.function_source_zip.name
  trigger_http          = true
}

# Bucket to store the function code
resource "google_storage_bucket" "function_source_bucket" {
  name     = "${var.project_id}-function-source-bucket"
  location = var.region
}

# Zip the function code and upload it
resource "google_storage_bucket_object" "function_source_zip" {
  name   = "${var.function_name}-${data.archive_file.function_source.output_md5}.zip"
  bucket = google_storage_bucket.function_source_bucket.name
  source = data.archive_file.function_source.output_path
  depends_on = [
    google_storage_bucket.function_source_bucket
  ]
}

# Create archive of Cloud Function code
data "archive_file" "function_source" {
  type        = "zip"
  source_dir  = "../function" # Relative path to function code
  output_path = "/tmp/function.zip"
}

# HTTPs Load Balancer
resource "google_compute_global_address" "lb_ip" {
  name = "${var.lb_name}-ip"
}

resource "google_compute_global_forwarding_rule" "default" {
  name       = "${var.lb_name}-forwarding-rule"
  ip_address = google_compute_global_address.lb_ip.address
  ip_protocol = "TCP"
  port_range = "80"
  target     = google_compute_target_http_proxy.default.self_link
}

resource "google_compute_target_http_proxy" "default" {
  name       = "${var.lb_name}-http-proxy"
  url_map = google_compute_url_map.default.self_link
}

resource "google_compute_url_map" "default" {
  name            = "${var.lb_name}-url-map"
  default_service = google_cloudfunctions_function.hello_world.https_trigger_url
}
