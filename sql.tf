data "null_data_source" "auth_mysql_allowed_1" {
  count  = "${var.countnat}"
  inputs = {
    name  = "nat-${count.index + 1}"
    value = "${element(google_compute_address.lb_ex.*.address, count.index)}"
    
  }
}
resource "random_id" "db" {
  byte_length = 2
}

resource "google_sql_database_instance" "primary-instance" {
    name               = "${var.project}-db-${random_id.db.hex}"
    region             = "${var.region}"
    database_version   = "${var.database_version}"

    settings {
        tier             = "db-f1-micro"
        disk_autoresize  = "${var.disk_autoresize}"
        disk_size        = "${var.disk_size}"
        disk_type        = "${var.disk_type}"
        backup_configuration {
            binary_log_enabled = "true"
            enabled            = "true"
            start_time         = "01:00"
        }
        ip_configuration {
            ipv4_enabled = "true"
            authorized_networks = [
               "${data.null_data_source.auth_mysql_allowed_1.*.outputs}",
            ]
      }
   }
        timeouts {
            create = "60m"
            delete = "2h"
        }
}
resource "google_sql_database" "default" {
  name      = "${var.db_name}"
  project   = "${var.project}"
  instance  = "${google_sql_database_instance.primary-instance.name}"
  charset   = "${var.db_charset}"
  collation = "${var.db_collation}"
}

resource "google_sql_user" "default" {
  name     = "${var.user_name}"
  project  = "${var.project}"
  instance = "${google_sql_database_instance.primary-instance.name}"
  host     = "${var.user_host}"
  password = "${var.user_password}"
}

resource "google_sql_database_instance" "secondary-instance" {
  depends_on = ["google_sql_database_instance.primary-instance"]
  name               = "${var.project}-db-replica-${random_id.db.hex}"
  region             = "${var.region}"
  database_version   = "${var.database_version}"
  master_instance_name = "${google_sql_database_instance.primary-instance.name}"
  replica_configuration {
    connect_retry_interval = "30"
    failover_target        = "true"
  }

    settings {
        tier                   = "db-f1-micro"
        disk_autoresize        = "${var.disk_autoresize}"
        disk_size              = "${var.disk_size}"
        disk_type              = "${var.disk_type}"
        replication_type       = "SYNCHRONOUS"
        crash_safe_replication = "true"
        
        ip_configuration {
            ipv4_enabled = "true"
        }
        location_preference {
            zone   = "us-central1-c"
        }
  }
        timeouts {
            create = "60m"
            delete = "2h"
        }
}