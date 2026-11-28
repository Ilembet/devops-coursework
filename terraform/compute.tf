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

# Two identical web servers, one per zone, in the private subnets (no public IP).
locals {
  web_vms = { for idx, zone in var.zones : "web-${idx + 1}" => zone }
}

resource "yandex_compute_instance" "web" {
  for_each = local.web_vms

  name               = each.key
  hostname           = each.key
  platform_id        = "standard-v3"
  zone               = each.value
  service_account_id = var.vm_puller_sa_id

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
    subnet_id          = yandex_vpc_subnet.private[each.value].id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.web.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh_key}"
  }
}

# Monitoring: Prometheus in a private subnet, Grafana in a public one.
resource "yandex_compute_instance" "prometheus" {
  name        = "prometheus"
  hostname    = "prometheus"
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
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private[var.zones[0]].id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.prometheus.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh_key}"
  }
}

resource "yandex_compute_instance" "grafana" {
  name               = "grafana"
  hostname           = "grafana"
  platform_id        = "standard-v3"
  zone               = var.zones[1]
  service_account_id = var.vm_puller_sa_id

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
    subnet_id          = yandex_vpc_subnet.public[var.zones[1]].id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.grafana.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh_key}"
  }
}

# Logs: Elasticsearch in a private subnet, Kibana in a public one.
resource "yandex_compute_instance" "elasticsearch" {
  name               = "elasticsearch"
  hostname           = "elasticsearch"
  platform_id        = "standard-v3"
  zone               = var.zones[1]
  service_account_id = var.vm_puller_sa_id

  resources {
    cores         = 2
    memory        = 4
    core_fraction = var.vm_core_fraction
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 10
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private[var.zones[1]].id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.elasticsearch.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh_key}"
  }
}

resource "yandex_compute_instance" "kibana" {
  name               = "kibana"
  hostname           = "kibana"
  platform_id        = "standard-v3"
  zone               = var.zones[1]
  service_account_id = var.vm_puller_sa_id

  resources {
    cores         = 2
    memory        = 4
    core_fraction = var.vm_core_fraction
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 10
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public[var.zones[1]].id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.kibana.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh_key}"
  }
}
