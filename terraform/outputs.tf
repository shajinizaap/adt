output "function_url" {
  description = "URL of the Cloud Function"
  value       = google_cloudfunctions_function.hello_world.https_trigger_url
}

output "load_balancer_ip" {
  description = "IP address of the Load Balancer"
  value       = google_compute_global_address.lb_ip.address
}
