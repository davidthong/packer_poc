packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "ubuntu" {
  iso_url                = "https://releases.ubuntu.com/24.04/ubuntu-24.04.2-live-server-amd64.iso"
  iso_checksum           = "none"
  output_directory       = "output-ubuntu"
  shutdown_command       = "echo 'packer' | sudo -S shutdown -P now"
  qemu_binary            = "/usr/bin/qemu-system-x86_64"
  disk_interface         = "virtio"
  disk_size              = 40960
  accelerator            = "kvm"
  boot_wait              = "90s"
  ssh_handshake_attempts = "20"
  boot_command = [
    "<esc><wait10>",
    "<enter><wait5>",
    "autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/<enter>"
  ]
  http_directory       = "http"
  format               = "qcow2"
  vm_name              = "ubuntu-golden"
  display              = "none"
  headless             = true
  ssh_username         = "packer"
  ssh_password         = "packer"
  ssh_timeout          = "20m"
  ssh_wait_timeout     = "20m"
}

build {
  sources = ["source.qemu.ubuntu"]

  provisioner "ansible" {
    playbook_file = "ansible/provision.yml"
  }
}