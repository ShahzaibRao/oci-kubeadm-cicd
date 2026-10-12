# ============================================================
# MAIN.TF
# WHAT: Dono modules ko jorta hai — poora infra ek nazar mein.
# WHY:  Ye file "wiring diagram" hai: network banao, uska
#       subnet_id compute ko do, ADs data source se lo, image variable se.
#       Detail modules ke andar, faisle yahan.
# ============================================================

module "network" {
  source         = "./modules/network"
  compartment_id = var.compartment_id
  name_prefix    = var.name_prefix
  vcn_cidr       = var.vcn_cidr
  subnet_cidr    = var.subnet_cidr
  admin_cidr     = var.admin_cidr
}

module "compute" {
  source               = "./modules/compute"
  compartment_id       = var.compartment_id
  subnet_id            = module.network.subnet_id # network module ka output yahan input
  image_id             = data.oci_core_images.ubuntu_arm.images[0].id
  availability_domains = [for ad in data.oci_identity_availability_domains.ads.availability_domains : ad.name]
  ssh_public_key       = var.ssh_public_key
  # WHY ad_index override: CI ka capacity-hunt loop -var="ad_index=N" se
  # har attempt par alag AD try karta hai. Default (var.ad_index=2) par
  # ye no-op hai — nodes map wali value hi lagti hai.
  nodes = { for name, cfg in var.nodes : name => merge(cfg, { ad_index = var.ad_index }) }
}

# NOTE: LB aur Vault modules baad mein aayenge — apne phase mein.
# Abhi sirf wahi jo Phase 0 ke liye zaroori hai.
