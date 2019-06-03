data "template_file" "app_conf" {
  template = "${file("${path.module}/provision_templates/application.properties.tpl")}"
  depends_on = ["google_sql_database_instance.primary-instance"]
  vars {
    db_server = "localhost"
    db_name = "${var.db_name}"
    db_user = "${var.user_name}"
    db_pass = "${var.user_password}"
  }
}
  data "template_file" "ansible_frontend" {
  template = "${file("${path.module}/provision_templates/frontend_yml.tpl")}"
  vars = {
    gcp_project_id = "${var.project}"
  }
}
  data "template_file" "ansible_backend" {
  template = "${file("${path.module}/provision_templates/backend_yml.tpl")}"
  vars = {
    gcp_project_id = "${var.project}"
  }
}
  data "template_file" "job_frontend" {
  template = "${file("${path.module}/provision_templates/job_frontend.tpl")}"
  vars {
    gcp_credential_json = "${var.key}"
    kubernetes_cluster = "${var.cluster}"
    region = "${var.region}"
    gcp_project_id = "${var.project}"
  }
} 
  data "template_file" "job_backend" {
  template = "${file("${path.module}/provision_templates/job_backend.tpl")}"
  vars {
    gcp_credential_json = "${var.key}"
    kubernetes_cluster = "${var.cluster}"
    region = "${var.region}"
    gcp_project_id = "${var.project}"
    db_user = "${var.user_name}"
    db_pass = "${var.user_password}"
  }
} 
  data "template_file" "deploy_backend" {
  template = "${file("${path.module}/provision_templates/kubernetes/deploy_backend.tpl")}"
  vars {
    sql_instance_name = "${google_sql_database_instance.primary-instance.name}"
    region = "${var.region}"
    gcp_project_id = "${var.project}"
    gcp_credential_json = "${var.key}"
    kubernetes_cluster = "${var.cluster}"
  }
} 
  data "template_file" "deploy_frontend" {
  template = "${file("${path.module}/provision_templates/kubernetes/deploy_frontend.tpl")}"
  vars {
    gcp_project_id = "${var.project}"
  }
} 
  data "template_file" "ingress-lb" {
  template = "${file("${path.module}/provision_templates/kubernetes/ingress-nginx/cloud-generic.tpl")}"
  vars {
    lb_global_ip = "${element(google_compute_address.lb_ex.*.address, count.index)}"
  }
} 
  data "template_file" "ambassador-lb" {
  template = "${file("${path.module}/provision_templates/kubernetes/ambassador/amb_lb.yaml.tpl")}"
  vars {
    lb_global_ip = "${element(google_compute_address.lb_ex.*.address, count.index)}"
  }
} 