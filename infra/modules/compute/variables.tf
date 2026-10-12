# Module ke inputs — root module ye values dega.

variable "compartment_id" {
  type        = string
  description = "OCI compartment jisme VMs banengi"
}

variable "subnet_id" {
  type        = string
  description = "Network module ka output — VMs isi public subnet mein banengi"
}

variable "image_id" {
  type        = string
  description = "Ubuntu 22.04 ARM image ki OCID (region-specific, data source se aayegi)"
}

variable "availability_domains" {
  type        = list(string)
  description = "Region ke ADs ki list — free tier mein capacity jis AD mein mile"
}

variable "ssh_public_key" {
  type        = string
  sensitive   = true
  description = "Tumhari SSH public key — VMs mein inject hogi (private key repo mein kabhi nahi)"
}

variable "nodes" {
  type = map(object({
    ad_index                = number
    ocpus                   = number
    memory_in_gbs           = number
    boot_volume_size_in_gbs = number
    role                    = string
  }))
  description = "Har node ka naam => config. role: control-plane ya worker (Ansible is se inventory banayega)"
}
