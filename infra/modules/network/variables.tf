# Module ke inputs — root module (infra/main.tf) ye values dega.
# Student note: variables alag file mein is liye ke module dobara
# use ho sake bina code chede — sirf values badlo.

variable "compartment_id" {
  type        = string
  description = "OCI compartment jisme network banega"
}

variable "name_prefix" {
  type        = string
  description = "Har resource ke naam ka prefix, taake console mein pehchana jaye"
}

variable "vcn_cidr" {
  type        = string
  description = "Poore VCN ka address space, masalan 10.0.0.0/16"
}

variable "subnet_cidr" {
  type        = string
  description = "Public subnet ka block, masalan 10.0.1.0/24 (VCN ke andar hona chahiye)"
}

variable "admin_cidr" {
  type        = string
  description = "Jahan se SSH (22) aur kubectl API (6443) allowed hai — abhi 0.0.0.0/0, baad mein apni IP par lock karenge"
}
