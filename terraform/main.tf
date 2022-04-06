terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  # Configuration options
  uri = "qemu:///system"
}


# Define base image
resource "libvirt_volume" "onyx-base" {
  name   = "onyx-base"
  source = "/var/lib/libvirt/images/onyx-base.qcow2"
}

# volumes to attach to the domain as main disk
resource "libvirt_volume" "onyxvm1" {
  name           = "onyxvm1.qcow2"
  base_volume_id = libvirt_volume.onyx-base.id
}
resource "libvirt_volume" "onyxvm2" {
  name           = "onyxvm2.qcow2"
  base_volume_id = libvirt_volume.onyx-base.id
}

# Define VMs
resource "libvirt_domain" "onyxvm1" {
  name = "onyxvm1"
  network_interface {
    #network_id     = libvirt_network.net1.id
    hostname       = "onyxvm1"
    #addresses      = ["10.17.3.3"]
    #mac            = "AA:BB:CC:11:22:22"
    #wait_for_lease = true
    bridge = "vmnic1"
  }
  disk {
    volume_id = libvirt_volume.onyxvm1.id
  }
}

resource "libvirt_domain" "onyxvm2" {
  name = "onyxvm2"
  network_interface {
    #network_id     = libvirt_network.net1.id
    hostname       = "onyxvm2"
    #addresses      = ["10.17.3.3"]
    #mac            = "AA:BB:CC:11:22:22"
    #wait_for_lease = true
    bridge = "vmnic2"
  }
  disk {
    volume_id = libvirt_volume.onyxvm2.id
  }
}
