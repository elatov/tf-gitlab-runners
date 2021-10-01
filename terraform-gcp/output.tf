output "ip" {
    value = google_compute_instance.ci_runner.network_interface.0.access_config.0.nat_ip
}
