# ============================================================
# COMPUTE MODULE
# WHAT: Dono Kubernetes nodes (VMs) banata hai.
# WHY:  kubeadm cluster ke liye 2 machines chahiye — ek
#       control-plane (API, scheduler, etcd) aur ek worker
#       (asal workloads). Free tier: 2 OCPU / 12 GB per VM.
# ============================================================

# WHAT: Dono VMs — for_each se ek hi block se 2 machines.
# WHY:  for_each ka matlab: nodes ki list badlo (masalan teesra
#       worker), code dobara nahi likhna parta. Har VM apne naam,
#       shape aur disk ke saath banti hai.
resource "oci_core_instance" "nodes" {
  for_each = var.nodes

  compartment_id      = var.compartment_id
  availability_domain = var.availability_domains[each.value.ad_index]
  # WHY: null = OCI khud place kare (default). CI hunt explicit FD try karta hai.
  fault_domain        = var.fault_domain
  display_name        = each.key
  shape               = "VM.Standard.A1.Flex" # Free tier ARM shape

  # WHAT: 2 OCPU / 12 GB per VM.
  # WHY:  Free tier total 4 OCPU / 24 GB hai — is se zyada manga
  #       to OCI mana kar dega. kubeadm ko kam-az-kam 2 CPU /
  #       2 GB chahiye hota hai; 2/12 mein control-plane +
  #       ArgoCD + monitoring aaram se chalenge.
  shape_config {
    ocpus         = each.value.ocpus
    memory_in_gbs = each.value.memory_in_gbs
  }

  # WHAT: OS image (Ubuntu 22.04 ARM) + boot disk size.
  # WHY:  50 GB boot volume free tier ke 200 GB total mein aata
  #       hai (2 VMs = 100 GB). Ubuntu 22.04 — kubeadm ke liye
  #       stable aur documented.
  source_details {
    source_type             = "image"
    source_id               = var.image_id
    boot_volume_size_in_gbs = each.value.boot_volume_size_in_gbs
  }

  # WHAT: Network card — public subnet mein, public IP ke saath.
  # WHY:  Ansible ko SSH chahiye, humein kubectl chahiye, aur
  #       baad mein OCI LB ko backends chahiye — sab ke liye
  #       public IP zaroori hai.
  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = true
    hostname_label   = each.key
  }

  # WHAT: Tumhari SSH public key VM mein inject hoti hai.
  # WHY:  Iske baghair Ansible andar nahi ja sakta. Private key
  #       tumhare paas rehti hai — repo mein kabhi nahi aati.
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  # WHY: VM delete ho to uska boot volume bhi delete ho — warna
  #      orphaned volumes free tier ka 200 GB kha jayenge.
  preserve_boot_volume = false
}
