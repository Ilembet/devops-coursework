# Скриншоты

| Файл | Что подтверждает |
| --- | --- |
| stage1-01-terraform-plan.png | `terraform plan` сети прошёл без ошибок |
| stage1-02-network.png | VPC `course-net` и 4 подсети (публичные и приватные, зоны a и d) |
| stage1-03-git-push.png | Код сети, NAT и групп безопасности в GitHub |
| stage2-01-ssh-bastion.png | Вход на bastion по ssh |
| stage2-02-ports.png | У bastion открыт только порт 22 |
| stage3-01-outputs-ssh-web.png | Outputs Terraform, вход на web-1 и web-2 через bastion |
| stage3-02-ansible-nginx.png | Ansible поставил nginx на обе ВМ (failed=0) |
| stage3-03-curl-alb.png | `curl -v` балансировщика: 200 OK, ответы чередуются web-1 / web-2 |
| stage3-04-failover.png | При остановленной web-1 сайт отвечает с web-2 |
| stage4-01-registry.png | Образы Elasticsearch, Kibana, Filebeat в Yandex Container Registry |
| stage5-01-prometheus-apply.png | ВМ Prometheus и Grafana созданы |
| stage5-02-prometheus-targets.png | Все цели Prometheus up, метрика nginx_http_response_count_total |
| stage5-03-grafana-playbook.png | Ansible развернул Grafana (failed=0) |
| stage5-04-grafana-cpu-ram.png | Дашборд Grafana: CPU и RAM с порогами |
| stage5-05-grafana-net-http.png | Дашборд Grafana: сеть и HTTP-метрики |
