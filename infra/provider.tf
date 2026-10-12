# ============================================================
# PROVIDER.TF
# WHAT: OCI provider ki authentication setting.
# WHY:  Credentials code mein kabhi nahi — ye environment se
#       aate hain: OCI_TENANCY_OCID, OCI_USER_OCID,
#       OCI_FINGERPRINT, OCI_PRIVATE_KEY, OCI_REGION.
#       Ya ~/.oci/config (OCI CLI wali file) se auto-read.
#       Region variable se aata hai taake ek jagah badlo.
# ============================================================
provider "oci" {
  region = var.region
}
