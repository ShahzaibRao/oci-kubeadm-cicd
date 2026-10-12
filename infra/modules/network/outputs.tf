# Module ke outputs — root module aur doosre modules (compute)
# inhein use karenge. Masalan compute module ko subnet_id chahiye
# taake VMs isi subnet mein banein.

output "vcn_id" {
  value       = oci_core_vcn.main.id
  description = "Banaye gaye VCN ki OCID"
}

output "subnet_id" {
  value       = oci_core_subnet.public.id
  description = "Public subnet ki OCID — VMs isi mein banengi"
}
