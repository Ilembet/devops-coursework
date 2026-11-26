# devops-coursework

Курсовая работа «DevOps-инженер с нуля»: отказоустойчивая инфраструктура сайта в Yandex Cloud (Terraform + Ansible) с мониторингом (Prometheus, Grafana), логами (Elasticsearch, Filebeat, Kibana), bastion-хостом и ежедневными снапшотами.

## Структура

- `terraform/` — инфраструктура: сеть, ВМ, балансировщик, снапшоты
- `ansible/` — настройка ВМ: nginx, exporters, Prometheus, Grafana, Elasticsearch, Kibana, Filebeat
- `docs/` — скриншоты, вывод команд, решения и компромиссы

## Статус

В работе. Этапы и решения описаны в `docs/`.
