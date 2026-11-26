resource "yandex_alb_target_group" "web" {
  name = "${var.name_prefix}-web"

  dynamic "target" {
    for_each = yandex_compute_instance.web
    content {
      subnet_id  = target.value.network_interface[0].subnet_id
      ip_address = target.value.network_interface[0].ip_address
    }
  }
}

resource "yandex_alb_backend_group" "web" {
  name = "${var.name_prefix}-web"

  http_backend {
    name             = "web"
    port             = 80
    weight           = 1
    target_group_ids = [yandex_alb_target_group.web.id]

    healthcheck {
      timeout             = "2s"
      interval            = "5s"
      healthy_threshold   = 2
      unhealthy_threshold = 3
      healthcheck_port    = 80

      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "web" {
  name = "${var.name_prefix}-web"
}

resource "yandex_alb_virtual_host" "web" {
  name           = "${var.name_prefix}-web"
  http_router_id = yandex_alb_http_router.web.id

  route {
    name = "root"
    http_route {
      http_match {
        path {
          prefix = "/"
        }
      }
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web.id
        timeout          = "10s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "web" {
  name               = "${var.name_prefix}-alb"
  network_id         = yandex_vpc_network.main.id
  security_group_ids = [yandex_vpc_security_group.alb.id]

  allocation_policy {
    dynamic "location" {
      for_each = yandex_vpc_subnet.public
      content {
        zone_id   = location.key
        subnet_id = location.value.id
      }
    }
  }

  listener {
    name = "http"
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.web.id
      }
    }
  }
}
