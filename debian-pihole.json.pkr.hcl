variable "proxmox_host" {
  type    = string
  default = "10.0.0.1"
}
variable "proxmox_node_name" {
  type    = string
  default = "pve"
}
variable "proxmox_api_user" {
  type    = string
  default = "root@pam"
}
variable "proxmox_api_token" {
  type      = string
  default   = "token"
  sensitive = true
}
variable "template_name" {
  type    = string
  default = "template_name"
}
variable "template_description" {
  type    = string
  default = "template_description"
}
variable "ssh_fullname" {
  type    = string
  default = "ssh_fullname"
}
variable "ssh_password" {
  type      = string
  default   = "ssh_password"
  sensitive = true
}
variable "ssh_username" {
  type    = string
  default = "ssh_username"
}
variable "hostname" {
  type    = string
  default = "hostname"
}
variable "ip_address" {
  type    = string
  default = "10.0.0.254"
}
variable "gateway" {
  type    = string
  default = "10.0.0.1"
}
variable "name_server" {
  type    = string
  default = "8.8.8.8"
}
variable "vmid" {
  type    = number
  default = "100"
}
variable "locale" {
  type    = string
  default = "en_US"
}
variable "cores" {
  type    = number
  default = 1
}
variable "sockets" {
  type    = number
  default = 1
}
variable "memory" {
  type    = number
  default = 512
}
variable "disk_size" {
  type    = string
  default = "10G"
}
variable "datastore" {
  type    = string
  default = "local"
}
variable "datastore_type" {
  type    = string
  default = "directory"
}
variable "iso" {
  type    = string
  default = "iso_path"
}
variable "boot_command_prefix" {
  type    = string
  default = "boot_command_prefix"
}
variable "preseed_file" {
  type    = string
  default = "preseed.cfg"
}

source "proxmox" "autogenerated_1" {
  boot_command = ["${var.boot_command_prefix}", "/install/vmlinuz ", "auto ", "console-setup/ask_detect=false ", "debconf/frontend=noninteractive ", "debian-installer=${var.locale} ", "hostname=${var.hostname} ", "fb=false ", "grub-installer/bootdev=/dev/sda<wait> ", "initrd=/install/initrd.gz ", "kbd-chooser/method=us ", "keyboard-configuration/modelcode=SKIP ", "locale=${var.locale} ", "noapic ", "passwd/username=${var.ssh_username} ", "passwd/user-fullname=${var.ssh_fullname} ", "passwd/user-password=${var.ssh_password} ", "passwd/user-password-again=${var.ssh_password} ", "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.preseed_file} ", "-- <enter>"]
  boot_wait    = "10s"
  cores        = "${var.cores}"
  disks {
    cache_mode        = "writeback"
    disk_size         = "${var.disk_size}"
    format            = "raw"
    storage_pool      = "${var.datastore}"
    storage_pool_type = "${var.datastore_type}"
    type              = "scsi"
  }
  http_content = {
    "/preseed.cfg" = templatefile("${path.root}/preseed.pkrtpl", var)
  }
  insecure_skip_tls_verify = true
  iso_file                 = "${var.iso}"
  memory                   = "${var.memory}"
  network_adapters {
    bridge = "vmbr11"
    model  = "virtio"
  }
  node                 = "${var.proxmox_node_name}"
  os                   = "l26"
  token                = "${var.proxmox_api_token}"
  proxmox_url          = "https://${var.proxmox_host}/api2/json"
  qemu_agent           = true
  sockets              = "${var.sockets}"
  ssh_password         = "${var.ssh_password}"
  ssh_timeout          = "90m"
  ssh_username         = "${var.ssh_username}"
  template_description = "${var.template_description}"
  unmount_iso          = true
  username             = "${var.proxmox_api_user}"
  vm_id                = "${var.vmid}"
  #vm_name              = "${var.template_name}"
}

build {
  sources = ["source.proxmox.autogenerated_1"]

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    script           = "./provision.sh"
    pause_before     = "20s"
  }

  post-processor "shell-local" {
    inline = ["ssh root@${var.proxmox_host} qm set ${var.vmid} --scsihw virtio-scsi-pci", "ssh root@${var.proxmox_host} qm set ${var.vmid} --ide2 ${var.datastore}:cloudinit", "ssh root@${var.proxmox_host} qm set ${var.vmid} --boot c --bootdisk scsi0", "ssh root@${var.proxmox_host} qm set ${var.vmid} --ciuser     ${var.ssh_username}", "ssh root@${var.proxmox_host} qm set ${var.vmid} --cipassword ${var.ssh_password}", "ssh root@${var.proxmox_host} qm set ${var.vmid} --vga std"]
  }
}
