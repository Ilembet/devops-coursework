output "network_id" {
  value = yandex_vpc_network.main.id
}

output "public_subnet_ids" {
  value = { for zone, s in yandex_vpc_subnet.public : zone => s.id }
}

output "private_subnet_ids" {
  value = { for zone, s in yandex_vpc_subnet.private : zone => s.id }
}

output "security_group_ids" {
  value = {
    bastion       = yandex_vpc_security_group.bastion.id
    alb           = yandex_vpc_security_group.alb.id
    web           = yandex_vpc_security_group.web.id
    prometheus    = yandex_vpc_security_group.prometheus.id
    grafana       = yandex_vpc_security_group.grafana.id
    elasticsearch = yandex_vpc_security_group.elasticsearch.id
    kibana        = yandex_vpc_security_group.kibana.id
  }
}

output "bastion_public_ip" {
  value = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
}
