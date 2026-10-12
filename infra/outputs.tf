# ============================================================
# OUTPUTS.TF
# WHAT: Apply ke baad kya nazar aayega.
# WHY:  IPs ke baghair agla step (Ansible) shuru nahi ho sakta —
#       outputs se IPs niklegi aur inventory banegi.
# ============================================================

output "node_public_ips" {
  description = "Har node ka public IP — Ansible inventory isi se banegi"
  value       = module.compute.public_ips
}

output "node_private_ips" {
  description = "Har node ka private IP — kubeadm join isi par hoga"
  value       = module.compute.private_ips
}

output "vcn_id" {
  description = "VCN ki OCID"
  value       = module.network.vcn_id
}

output "subnet_id" {
  description = "Public subnet ki OCID"
  value       = module.network.subnet_id
}
