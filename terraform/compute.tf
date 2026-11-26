locals {
  ssh_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2404-lts"
}

# The only VM with a public address and the only entry point for SSH.
resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  hostname    = "bastion"
  platform_id = "standard-v3"
  zone        = var.zones[0]

  resources {
    cores         = 2
    memory        = 2
    core_fraction = var.vm_core_fraction
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public[var.zones[0]].id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.bastion.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh_key}"
  }
}
