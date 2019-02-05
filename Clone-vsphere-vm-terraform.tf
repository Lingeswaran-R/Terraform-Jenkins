###########################################
# Define Variable 
###########################################
variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}

################################################
# Provider section
################################################
provider "vsphere" {
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${var.vsphere_server}"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

#################################################
#Capturing the data from vsphere
#################################################
data "vsphere_datacenter" "dc" {
  name = "BLR-DC"
}

data "vsphere_datastore" "datastore" {
  name          = "Datastore1"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "Node1-Rpool"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

########################################################
# sourcing template
#############################################################
data "vsphere_virtual_machine" "template" {
  name          = "terraform-test"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

#########################################################
# Resource
##########################################################
resource "vsphere_virtual_machine" "vm" {
  name             = "Node2"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"

  num_cpus = 1
  memory   = 512
  guest_id = "other3xLinux64Guest"

  network_interface {
  network_id   = "${data.vsphere_network.network.id}"
  adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }
  
  disk {
    label = "disk0"
    size  = 20
  }


################################################################
# Initiate the clone 
#################################################################
clone {
  template_uuid = "${data.vsphere_virtual_machine.template.id}"

  customize {
    linux_options {
      host_name = "Node2"
      domain    = "local.localdomain"
    }
  }
 }
}
