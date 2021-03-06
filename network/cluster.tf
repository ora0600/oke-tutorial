# Start OKE variables: Please change
variable "cluster_kubernetes_version" {default = "v1.11.1"}
variable "cluster_name" {default = "Tutorial1"}
variable "availability_domain" {default = 3}
variable "cluster_options_add_ons_is_kubernetes_dashboard_enabled" {default = true}
variable "cluster_options_add_ons_is_tiller_enabled" {default = true}
variable "cluster_options_kubernetes_network_config_pods_cidr" {default = "10.244.0.0/16"}
variable "cluster_options_kubernetes_network_config_services_cidr" {default = "10.96.0.0/16"}
variable "node_pool_initial_node_labels_key" {default = "key"}
variable "node_pool_initial_node_labels_value" {default = "value"}
variable "node_pool_kubernetes_version" {default = "v1.11.1"}
variable "node_pool_name" {default = "TutorialNodePool1"}
variable "node_pool_node_image_name" {default = "Oracle-Linux-7.4"}
variable "node_pool_node_shape" {default = "VM.Standard2.1"}
variable "node_pool_quantity_per_subnet" {default = 1}
variable "node_pool_ssh_public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAgPfRQ8nGeFd39jdULiw/E0EDjelrdmMY6ToJYR5JOjfMe3iRQrYi3HevnGPS20haW0l9x6LAgwVS+K0+Xg9tFBVa+hvLX6CIocrnO8FlTUgN7zv6+eqz7IMsrrrHaNQDbKRpnZl8WS10Zo6WAPp6Dc4jntnFqVRG57NHJnUVyCDroqDERNkvp4Tn0t3UtCOhbyvfhXqxd0B3i1aDgsF3p9K2sauD6ge/RRnkLmSNkRSbOTyAd+ZYFS4uBse7Wue6ELI/7HAEolGEQEVR/kCdn9gf3slblNpkzYhq4jHFX02D/lC7+sbEY88KZWA/9kB73u8TTXFjVM0rx7WgnvSDuQ== CM_KEY"
}
# END OKE variables: Please change



resource "oci_containerengine_cluster" "test_cluster" {
  #Required
  compartment_id     = "${var.compartment_ocid}"
  kubernetes_version = "${var.cluster_kubernetes_version}"
  name               = "${var.cluster_name}"
  vcn_id             = "${oci_core_virtual_network.VCN.id}"

  #Optional
  options {
    service_lb_subnet_ids = ["${oci_core_subnet.loadbalancerAD1.id}", "${oci_core_subnet.loadbalancerAD2.id}"]

    #Optional
    add_ons {
      #Optional
      is_kubernetes_dashboard_enabled = "${var.cluster_options_add_ons_is_kubernetes_dashboard_enabled}"
      is_tiller_enabled               = "${var.cluster_options_add_ons_is_tiller_enabled}"
    }

    kubernetes_network_config {
      #Optional
      pods_cidr     = "${var.cluster_options_kubernetes_network_config_pods_cidr}"
      services_cidr = "${var.cluster_options_kubernetes_network_config_services_cidr}"
    }
  }
}

resource "oci_containerengine_node_pool" "test_node_pool" {
  #Required
  cluster_id         = "${oci_containerengine_cluster.test_cluster.id}"
  compartment_id     = "${var.compartment_ocid}"
  kubernetes_version = "${var.node_pool_kubernetes_version}"
  name               = "${var.node_pool_name}"
  node_image_name    = "${var.node_pool_node_image_name}"
  node_shape         = "${var.node_pool_node_shape}"
  subnet_ids         = ["${oci_core_subnet.workerAD1.id}", "${oci_core_subnet.workerAD2.id}", "${oci_core_subnet.workerAD3.id}"]

  #Optional
  initial_node_labels {
    #Optional
    key   = "${var.node_pool_initial_node_labels_key}"
    value = "${var.node_pool_initial_node_labels_value}"
  }

  quantity_per_subnet = "${var.node_pool_quantity_per_subnet}"
  ssh_public_key      = "${var.node_pool_ssh_public_key}"
}

output "cluster" {
  value = {
    id                 = "${oci_containerengine_cluster.test_cluster.id}"
    kubernetes_version = "${oci_containerengine_cluster.test_cluster.kubernetes_version}"
    name               = "${oci_containerengine_cluster.test_cluster.name}"
  }
}

output "node_pool" {
  value = {
    id                 = "${oci_containerengine_node_pool.test_node_pool.id}"
    kubernetes_version = "${oci_containerengine_node_pool.test_node_pool.kubernetes_version}"
    name               = "${oci_containerengine_node_pool.test_node_pool.name}"
    subnet_ids         = "${oci_containerengine_node_pool.test_node_pool.subnet_ids}"
  }
}