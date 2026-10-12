# ============================================================
# VARIABLES.TF
# WHAT: Poore infra ke inputs — ek jagah saari values.
# WHY:  Code mein koi hardcoded OCID/IP nahi. Local run mein
#       terraform.tfvars se, CI mein TF_VAR_* env vars se.
# ============================================================

variable "tenancy_ocid" {
  type        = string
  sensitive   = true
  description = "OCI tenancy ki OCID — AD list ke liye chahiye"
}

variable "compartment_id" {
  type        = string
  description = "Compartment OCID jisme sab banega (root compartment ke liye tenancy OCID hi use karo)"
}

variable "region" {
  type        = string
  default     = "eu-frankfurt-1"
  description = "OCI region — Frankfurt mein free tier capacity aam tor par milti hai"
}

variable "name_prefix" {
  type        = string
  default     = "cicd"
  description = "Har resource ke display name ka prefix"
}

variable "ssh_public_key" {
  type        = string
  sensitive   = true
  description = "Tumhari SSH PUBLIC key — VMs mein inject hogi. Private key kabhi repo mein nahi."
}

variable "admin_cidr" {
  type        = string
  default     = "0.0.0.0/0"
  description = "Jahan se SSH (22) aur kubectl (6443) allowed — abhi khula, baad mein apni IP par lock karenge"
}

variable "vcn_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VCN ka address space"
}

variable "subnet_cidr" {
  type        = string
  default     = "10.0.1.0/24"
  description = "Public subnet — dono VMs isi mein"
}

variable "nodes" {
  type = map(object({
    ad_index                = number
    ocpus                   = number
    memory_in_gbs           = number
    boot_volume_size_in_gbs = number
    role                    = string # "control-plane" | "worker" — Ansible is se inventory banayega
  }))
  description = "Dono Kubernetes nodes. Alag ADs mein taake ek AD down ho to dono na jayen."

  default = {
    "k8s-control-plane" = {
      ad_index                = 0
      ocpus                   = 2
      memory_in_gbs           = 12
      boot_volume_size_in_gbs = 100
      role                    = "control-plane"
    }
    "k8s-worker" = {
      ad_index                = 1
      ocpus                   = 2
      memory_in_gbs           = 12
      boot_volume_size_in_gbs = 100
      role                    = "worker"
    }
  }

  # WHY validations: free tier ki hard limits — apply se PEHLE
  # pakra jaye taake aadhe bane infra ka masla na ho.
  validation {
    condition     = sum([for n in var.nodes : n.ocpus]) <= 4
    error_message = "Total OCPUs must not exceed the Always Free limit of 4."
  }

  validation {
    condition     = sum([for n in var.nodes : n.memory_in_gbs]) <= 24
    error_message = "Total RAM must not exceed the Always Free limit of 24 GB."
  }

  validation {
    condition     = sum([for n in var.nodes : n.boot_volume_size_in_gbs]) <= 200
    error_message = "Total boot volume must not exceed the Always Free limit of 200 GB."
  }
}
