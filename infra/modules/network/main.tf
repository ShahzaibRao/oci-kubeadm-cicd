# ============================================================
# NETWORK MODULE
# WHAT: Poora network fabric — VCN, Internet Gateway, Route
#       Table, Security List, Public Subnet.
# WHY:  VMs ko (a) internet se baat karni hai (apt, Docker Hub,
#       GitHub) aur (b) aapas mein (kubeadm cluster traffic).
#       Ye sab ek module mein taake network dobara banana ya
#       samajhna ek jagah se ho — infra/ mein bikhra hua nahi.
# ============================================================

# WHAT: Virtual Cloud Network — hamara private data center.
# WHY:  OCI mein har VM kisi VCN ke andar banta hai. Ye
#       10.0.0.0/16 address space dono Kubernetes nodes ko dega.
resource "oci_core_vcn" "main" {
  compartment_id = var.compartment_id
  display_name   = "${var.name_prefix}-vcn"
  cidr_blocks    = [var.vcn_cidr]
  dns_label      = "${var.name_prefix}vcn"
}

# WHAT: Internet Gateway — VCN ka internet se darwaza.
# WHY:  Public subnet ke VMs ko public IP to milta hai, lekin
#       internet tak route isi gateway se jata hai. Iske baghair
#       VM bahar ki duniya se baat nahi kar sakta.
resource "oci_core_internet_gateway" "main" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.name_prefix}-igw"
  enabled        = true
}

# WHAT: Route Table — "0.0.0.0/0 jana hai to IGW se jao".
# WHY:  Subnet ko batana parta hai ke internet-bound traffic
#       kahan bhejna hai. Ye table public subnet se attach hogi.
resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.name_prefix}-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.main.id
  }
}

# WHAT: Security List — subnet ka firewall (stateful).
# WHY:  Kaun se port bahar se khulenge, ye yahin decide hota hai.
#       Har rule ke neeche WHY likha hai taake dobara parhne par
#       samajh aaye ke ye port kyun khula hai.
resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.name_prefix}-public-seclist"

  # WHY: Nodes ko bahar nikalna zaroori hai — apt updates,
  #      container image pulls (Docker Hub), GitHub, Calico
  #      manifests. Outbound band kiya to cluster andha ho jayega.
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  # WHY: kubeadm nodes aapas mein bohat se ports par baat karte
  #      hain — etcd 2379/2380, kubelet 10250, kube-apiserver
  #      6443 (internal), Calico BGP 179. Ek rule (VCN se all)
  #      sab cover kar deta hai; learning ke liye simple rakha.
  ingress_security_rules {
    protocol = "all"
    source   = var.vcn_cidr
  }

  # WHY: Ansible SSH se dono VMs par kaam karega. Abhi admin_cidr
  #      0.0.0.0/0 hai (IP badalti rehti hai); baad mein apni IP
  #      par lock karenge.
  ingress_security_rules {
    protocol = "6"
    source   = var.admin_cidr
    tcp_options {
      min = 22
      max = 22
    }
  }

  # WHY: kubectl isi port par control-plane se baat karta hai.
  #      Browser/laptop se API access ke liye khula hona chahiye.
  ingress_security_rules {
    protocol = "6"
    source   = var.admin_cidr
    tcp_options {
      min = 6443
      max = 6443
    }
  }

  # WHY: HTTP/HTTPS — mustaqbil mein OCI LB yahin aayega aur
  #      traffic NGINX Ingress tak pahunchayega. Abhi se khula
  #      taake baad mein dobara firewall na kholna pare.
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
  }

  # WHY: NGINX Ingress ko hum NodePort par expose karenge
  #      (30000-32767). LB aane tak testing/app access isi
  #      range se hogi, is liye ye ports duniya ke liye khule.
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 30000
      max = 32767
    }
  }

  # WHY: ping + path MTU discovery — network debugging ke kaam
  #      aata hai (VM reachability test karna).
  ingress_security_rules {
    protocol = "1"
    source   = "0.0.0.0/0"
  }
}

# WHAT: Public Subnet — dono VMs isi mein banenge.
# WHY:  Public subnet = VMs ko public IP milta hai + route table
#       internet tak jati hai. Dono nodes ek hi subnet mein taake
#       cluster traffic local rahe aur design simple rahe.
resource "oci_core_subnet" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.name_prefix}-public-subnet"
  cidr_block     = var.subnet_cidr
  dns_label      = "publicsubnet"

  route_table_id    = oci_core_route_table.public.id
  security_list_ids = [oci_core_security_list.public.id]

  prohibit_public_ip_on_vnic = false
}
