# Module ke outputs — Ansible ko IPs chahiye hongi inventory ke liye.

output "public_ips" {
  value       = { for k, v in oci_core_instance.nodes : k => v.public_ip }
  description = "Har node ka public IP (Ansible inventory banane ke kaam aayega)"
}

output "private_ips" {
  value       = { for k, v in oci_core_instance.nodes : k => v.private_ip }
  description = "Har node ka private IP (kubeadm join isi se hoga)"
}
