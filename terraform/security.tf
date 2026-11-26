# Every group allows all outgoing traffic; incoming is limited to the ports below.
# SSH to any VM is allowed only from the bastion security group.

resource "yandex_vpc_security_group" "bastion" {
  name       = "${var.name_prefix}-bastion"
  network_id = yandex_vpc_network.main.id

  ingress {
    description    = "SSH from the allowed network"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    description    = "All outgoing"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "alb" {
  name       = "${var.name_prefix}-alb"
  network_id = yandex_vpc_network.main.id

  ingress {
    description    = "HTTP from the internet"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description       = "ALB health checks"
    protocol          = "TCP"
    port              = 30080
    predefined_target = "loadbalancer_healthchecks"
  }

  egress {
    description    = "All outgoing"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "web" {
  name       = "${var.name_prefix}-web"
  network_id = yandex_vpc_network.main.id

  ingress {
    description       = "HTTP from the load balancer"
    protocol          = "TCP"
    port              = 80
    security_group_id = yandex_vpc_security_group.alb.id
  }

  ingress {
    description       = "node_exporter from Prometheus"
    protocol          = "TCP"
    port              = 9100
    security_group_id = yandex_vpc_security_group.prometheus.id
  }

  ingress {
    description       = "nginx-log-exporter from Prometheus"
    protocol          = "TCP"
    port              = 4040
    security_group_id = yandex_vpc_security_group.prometheus.id
  }

  ingress {
    description       = "SSH from the bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion.id
  }

  egress {
    description    = "All outgoing"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "prometheus" {
  name       = "${var.name_prefix}-prometheus"
  network_id = yandex_vpc_network.main.id

  ingress {
    description       = "Prometheus API from Grafana"
    protocol          = "TCP"
    port              = 9090
    security_group_id = yandex_vpc_security_group.grafana.id
  }

  ingress {
    description       = "SSH from the bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion.id
  }

  egress {
    description    = "All outgoing"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "grafana" {
  name       = "${var.name_prefix}-grafana"
  network_id = yandex_vpc_network.main.id

  ingress {
    description    = "Grafana web UI from the internet"
    protocol       = "TCP"
    port           = 3000
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description       = "SSH from the bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion.id
  }

  egress {
    description    = "All outgoing"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "elasticsearch" {
  name       = "${var.name_prefix}-elasticsearch"
  network_id = yandex_vpc_network.main.id

  ingress {
    description       = "Elasticsearch API from Kibana"
    protocol          = "TCP"
    port              = 9200
    security_group_id = yandex_vpc_security_group.kibana.id
  }

  ingress {
    description       = "Elasticsearch API from web servers (filebeat)"
    protocol          = "TCP"
    port              = 9200
    security_group_id = yandex_vpc_security_group.web.id
  }

  ingress {
    description       = "SSH from the bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion.id
  }

  egress {
    description    = "All outgoing"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "kibana" {
  name       = "${var.name_prefix}-kibana"
  network_id = yandex_vpc_network.main.id

  ingress {
    description    = "Kibana web UI from the internet"
    protocol       = "TCP"
    port           = 5601
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description       = "SSH from the bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion.id
  }

  egress {
    description    = "All outgoing"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
