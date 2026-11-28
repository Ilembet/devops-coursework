# devops-coursework

Курсовая работа по профессии «DevOps-инженер с нуля»: отказоустойчивая инфраструктура сайта в Yandex Cloud
с мониторингом, сбором логов и резервным копированием. Инфраструктура описана в Terraform, настройка ВМ — в Ansible.

## Доступ (на время работы стека)

| Ресурс | Адрес | Вход |
| --- | --- | --- |
| Сайт (через Application Load Balancer) | http://62.84.118.222 | — |
| Grafana | http://84.252.134.225:3000 | без входа, роль Viewer; дашборд Dashboards → Coursework |
| Kibana | http://84.201.151.18:5601 | без входа; Discover, data view `filebeat-*` |

Стек работал 26–28 ноября 2026 г. и после проверки удалён, чтобы не тратить средства облака: адреса выше
сейчас не отвечают. Работу подтверждают скриншоты и вывод команд в [docs/README.md](docs/README.md).
Стек поднимается заново командами из раздела «Как поднять с нуля»; новые адреса печатает `scripts/links.sh`.

## Что сделано

- Две одинаковые ВМ с nginx в зонах `ru-central1-a` и `ru-central1-d` за Application Load Balancer:
  Target Group, Backend Group с healthcheck `/` на порт 80, HTTP router, listener на порту 80.
- Мониторинг: Prometheus, node_exporter на всех ВМ, prometheus-nginxlog-exporter на web, Grafana с дашбордом
  USE (CPU, RAM, диск, сеть) и HTTP-метриками, пороги на всех панелях.
- Логи: Elasticsearch и Kibana, Filebeat отправляет `access.log` и `error.log` nginx.
- Сеть: один VPC, web, Prometheus и Elasticsearch в приватных подсетях (выход через NAT), Grafana, Kibana и
  балансировщик в публичных. Группы безопасности открывают только нужные порты, ssh — только с bastion.
- Резервное копирование: ежедневные снапшоты дисков всех ВМ, хранение 7 дней.
- Дополнительно: оповещения Grafana (4 правила) и логи самих Elasticsearch, Kibana, Grafana и Prometheus в Elasticsearch.

**Решение по этапам, проверки, скриншоты и компромиссы: [docs/README.md](docs/README.md).**

## Архитектура

| Хост | Зона | Подсеть | Роль |
| --- | --- | --- | --- |
| bastion | a | публичная | единственная точка входа по ssh |
| web-1, web-2 | a, d | приватные | nginx, node_exporter, nginx-log-exporter, Filebeat |
| prometheus | a | приватная | Prometheus |
| grafana | d | публичная | Grafana (Docker) |
| elasticsearch | d | приватная | Elasticsearch (Docker) |
| kibana | d | публичная | Kibana (Docker) |

## Структура репозитория

| Путь | Что внутри |
| --- | --- |
| `terraform/` | сеть, группы безопасности, ВМ, балансировщик, расписание снапшотов |
| `ansible/` | роли: nginx, node_exporter, nginx_log_exporter, prometheus, docker, grafana, elasticsearch, kibana, filebeat |
| `scripts/` | генерация ssh-конфига и инвентаря Ansible из outputs Terraform, вывод ссылок |
| `docs/` | решение по этапам и скриншоты |

## Как поднять с нуля

Нужны: Terraform ≥ 1.6.3, Ansible, `yc` с профилем облака, сервисные аккаунты `terraform-sa` и `vm-puller`,
бакет для состояния и образы в Container Registry (см. [docs/README.md](docs/README.md), этапы 0 и 4).

```bash
source terraform/env.sh
cd terraform && terraform init && terraform apply && cd ..
scripts/ssh-config.sh
scripts/inventory.sh
read -rsp "Grafana admin password: " GRAFANA_ADMIN_PASSWORD; echo; export GRAFANA_ADMIN_PASSWORD
cd ansible && ansible-playbook site.yml && cd ..
scripts/links.sh
```

Удаление (снапшоты Terraform не удаляет, поэтому сначала они):

```bash
yc compute snapshot list --folder-name coursework --format json \
  | python3 -c 'import json,sys; [print(s["id"]) for s in json.load(sys.stdin)]' \
  | xargs -r -n1 yc compute snapshot delete --folder-name coursework
cd terraform && terraform destroy
```
