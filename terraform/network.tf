locals {
  public_cidrs  = { for idx, zone in var.zones : zone => cidrsubnet("10.10.0.0/16", 8, idx) }
  private_cidrs = { for idx, zone in var.zones : zone => cidrsubnet("10.10.0.0/16", 8, idx + 10) }
}

resource "yandex_vpc_network" "main" {
  name = "${var.name_prefix}-net"
}

# Private VMs have no public IP; they reach the internet (packages, images) through NAT.
resource "yandex_vpc_gateway" "nat" {
  name = "${var.name_prefix}-nat"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "private" {
  name       = "${var.name_prefix}-private"
  network_id = yandex_vpc_network.main.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat.id
  }
}

resource "yandex_vpc_subnet" "public" {
  for_each = toset(var.zones)

  name           = "${var.name_prefix}-public-${each.value}"
  zone           = each.value
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [local.public_cidrs[each.value]]
}

resource "yandex_vpc_subnet" "private" {
  for_each = toset(var.zones)

  name           = "${var.name_prefix}-private-${each.value}"
  zone           = each.value
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [local.private_cidrs[each.value]]
  route_table_id = yandex_vpc_route_table.private.id
}
