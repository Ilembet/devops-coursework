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

output "web_private_ips" {
  value = { for name, vm in yandex_compute_instance.web : name => vm.network_interface[0].ip_address }
}

output "alb_public_ip" {
  value = yandex_alb_load_balancer.web.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}

output "prometheus_private_ip" {
  value = yandex_compute_instance.prometheus.network_interface[0].ip_address
}

output "grafana_private_ip" {
  value = yandex_compute_instance.grafana.network_interface[0].ip_address
}

output "grafana_public_ip" {
  value = yandex_compute_instance.grafana.network_interface[0].nat_ip_address
}

output "elasticsearch_private_ip" {
  value = yandex_compute_instance.elasticsearch.network_interface[0].ip_address
}

output "kibana_private_ip" {
  value = yandex_compute_instance.kibana.network_interface[0].ip_address
}

output "kibana_public_ip" {
  value = yandex_compute_instance.kibana.network_interface[0].nat_ip_address
}
