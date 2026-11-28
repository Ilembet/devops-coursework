# Daily snapshots of the boot disks of every VM, kept for one week.
resource "yandex_compute_snapshot_schedule" "daily" {
  name = "${var.name_prefix}-daily"

  schedule_policy {
    expression = var.snapshot_cron
  }

  retention_period = "168h"

  snapshot_spec {
    description = "Daily snapshot (coursework)"
  }

  disk_ids = concat(
    [for vm in yandex_compute_instance.web : vm.boot_disk[0].disk_id],
    [
      yandex_compute_instance.bastion.boot_disk[0].disk_id,
      yandex_compute_instance.prometheus.boot_disk[0].disk_id,
      yandex_compute_instance.grafana.boot_disk[0].disk_id,
      yandex_compute_instance.elasticsearch.boot_disk[0].disk_id,
      yandex_compute_instance.kibana.boot_disk[0].disk_id,
    ],
  )
}
