output "security_list" {
  description = "Security List"
  value       = oci_core_security_list.create_security_list
}

output "security_list_id" {
  description = "Security List ID"
  value       = oci_core_security_list.create_security_list.id
}
