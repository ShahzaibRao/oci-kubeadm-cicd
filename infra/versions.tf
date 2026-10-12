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

  # NOTE: backend block nahi hai = LOCAL state (terraform.tfstate
  # tumhari machine par). Learning ke liye simple rakha hai.
  # Remote state (R2/S3) baad mein add karenge jab CI se apply
  # karne lagenge — ek step ek waqt mein.
}
