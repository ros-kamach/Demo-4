output "public_ip_bastion" {
   value = ["${google_compute_instance.jenkins.*.network_interface.0.access_config.0.nat_ip}"]
}
output "global_ip_load_balancer" {
   value = ["${google_compute_address.lb_ex.*.address}"]
}
output "public_ip_sql" {
   value = ["${google_sql_database_instance.primary-instance.ip_address.0.ip_address}"]
}
