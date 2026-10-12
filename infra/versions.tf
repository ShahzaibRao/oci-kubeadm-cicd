# ============================================================
# VERSIONS.TF
# WHAT: Toolchain ke version pins.
# WHY:  Bina pins ke "mere paas chalta hai" wali problem —
#       har machine par same Terraform + provider versions,
#       taake plan har jagah identical aaye.
# ============================================================
terraform {
  required_version = ">= 1.9.0, < 2.0.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.0.0, < 7.0.0"
    }
  }

  # Remote state: Cloudflare R2 (S3-compatible).
  # WHY R2: local terraform.tfstate delete ho sakta hai, aur team mein
  # sab ko same state chahiye. R2 free tier mein aata hai.
  # Credentials backend.hcl mein (gitignored) — kabhi commit nahi.
  # Local: terraform init -backend-config=backend.hcl
  backend "s3" {}
}
