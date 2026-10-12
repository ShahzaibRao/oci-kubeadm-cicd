# ============================================================
# DATA.TF
# WHAT: OCI se READ-ONLY maloomat — kuch banata nahi.
# WHY:  ADs ke naam aur Ubuntu image ki OCID har region mein
#       mukhtalif hoti hai. Hardcode karne ke bajaye Terraform
#       khud dhoond le — region badlo to code nahi badalna parta.
# ============================================================

# Region ke availability domains (free tier capacity jis AD mein mile)
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# Ubuntu 22.04 ARM image — hamesha taaza tareen (sort by newest)
data "oci_core_images" "ubuntu_arm" {
  compartment_id           = var.compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}
