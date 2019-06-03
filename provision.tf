resource "null_resource" remoteExecProvisionerWFolder {
   depends_on = ["google_sql_database_instance.primary-instance"]
  count = 1
  connection {
    host = "${google_compute_instance.jenkins.*.network_interface.0.access_config.0.nat_ip}"
    type = "ssh"
    user = "centos"
    private_key = "${file("${var.private_key_path}")}"
    agent = "false"
  }
  provisioner "file" {
     source = "${var.private_key_path}"
     destination = "/home/centos/.ssh/id_rsa"
     }
  provisioner "remote-exec" {
    inline = [ "sudo chmod 600 /home/centos/.ssh/id_rsa" ]
  }
  provisioner "remote-exec" {
    inline = [ 
      "rm -rf /tmp/ansible",
      "mkdir /tmp/templates",
      "mkdir /tmp/templates/backend",
      "mkdir /tmp/templates/frontend",
      "mkdir /tmp/templates/ansible_docker",
      "mkdir /tmp/templates/kubernetes",
      "mkdir /tmp/templates/kubernetes/ingress-nginx",
      "mkdir /tmp/templates/kubernetes/ambassador"]
  }
  provisioner "file" {
    source = "ansible"
    destination = "/tmp/ansible"
  }
    provisioner "file" {
    source = "provision_templates/jenkins_jobs_and_plugins_configuration"
    destination = "/tmp/templates/"
  }
  provisioner "file" {
    source = ".ssh"
    destination = "/tmp/ansible/.ssh"
  }
    provisioner "file" {
    source = "${var.key}"
    destination = "/tmp/ansible/.ssh/${var.key}"
  }
    provisioner "file" {
    content = "${data.template_file.ansible_frontend.rendered}"
    destination = "/tmp/templates/ansible_docker/frontend.yml"
  }
    provisioner "file" {
    content = "${data.template_file.ansible_backend.rendered}"
    destination = "/tmp/templates/ansible_docker/backend.yml"
  }
    provisioner "file" {
    source = "provision_templates/Dockerfile_backend"
    destination = "/tmp/templates/backend/Dockerfile_backend"
  }
    provisioner "file" {
    content = "${data.template_file.app_conf.rendered}"
    destination = "/tmp/templates/backend/application.properties"
  }
    provisioner "file" {
    source = "provision_templates/Dockerfile_frontend"
    destination = "/tmp/templates/frontend/Dockerfile_frontend"
  }
    provisioner "file" {
    source = "provision_templates/nginx.conf.j2"
    destination = "/tmp/templates/frontend/nginx.conf"
  }
   provisioner "file" {
    content = "${data.template_file.job_frontend.rendered}"
    destination = "/tmp/templates/job_frontend.xml"
  }
    provisioner "file" {
    content = "${data.template_file.job_backend.rendered}"
    destination = "/tmp/templates/job_backend.xml"
  }
    provisioner "file" {
    source = "provision_templates/pg_hba.conf.j2"
    destination = "/tmp/templates/pg_hba.conf.j2"
  }
    provisioner "file" {
    source = "provision_templates/sonar.unit.j2"
    destination = "/tmp/templates/sonar.unit.j2"
  }
    provisioner "file" {
    content = "${data.template_file.deploy_backend.rendered}"
    destination = "/tmp/templates/kubernetes/deploy_backend.yaml"
  }
    provisioner "file" {
    source = "provision_templates/kubernetes/backend_service.yaml"
    destination = "/tmp/templates/kubernetes/backend_service.yaml"
  }
    provisioner "file" {
    source = "provision_templates/kubernetes/ingress-nginx/ingress_backend.yaml"
    destination = "/tmp/templates/kubernetes/ingress-nginx/ingress_backend.yaml"
  }
    provisioner "file" {
    source = "provision_templates/kubernetes/ingress-nginx/ingress_frontend.yaml"
    destination = "/tmp/templates/kubernetes/ingress-nginx/ingress_frontend.yaml"
  }
    provisioner "file" {
    source = "provision_templates/kubernetes/frontend_service.yaml"
    destination = "/tmp/templates/kubernetes/frontend_service.yaml"
  }

    provisioner "file" {
    source = "provision_templates/kubernetes/ingress-nginx/mandatory.yaml"
    destination = "/tmp/templates/kubernetes/ingress-nginx/mandatory.yaml"
  }
    provisioner "file" {
    content = "${data.template_file.ingress-lb.rendered}"
    destination = "/tmp/templates/kubernetes/ingress-nginx/cloud-generic.yaml"
  }
    provisioner "file" {
    content = "${data.template_file.deploy_frontend.rendered}"
    destination = "/tmp/templates/kubernetes/deploy_frontend.yaml"
  }
    provisioner "file" {
    content = "${data.template_file.ambassador-lb.rendered}"
    destination = "/tmp/templates/kubernetes/ambassador/amb_ld.yaml"
  }
    provisioner "file" {
    source = "provision_templates/kubernetes/ambassador/rbac.yaml"
    destination = "/tmp/templates/kubernetes/ambassador/rbac.yaml"
  }

    provisioner "file" {
    source = "provision_templates/kubernetes/ambassador/amb_backend.yaml"
    destination = "/tmp/templates/kubernetes/ambassador/amb_backend.yaml"
  }

    provisioner "file" {
    source = "provision_templates/kubernetes/ambassador/amb_frontend.yaml"
    destination = "/tmp/templates/kubernetes/ambassador/amb_frontend.yaml"
  }
}
resource "null_resource" inventoryFileWeb {
  depends_on = ["null_resource.remoteExecProvisionerWFolder"]
  count = 2
  connection {
    host = "${google_compute_instance.jenkins.*.network_interface.0.access_config.0.nat_ip}"
    type = "ssh"
    user = "centos"
    private_key = "${file("${var.private_key_path}")}"
    agent = "false"
  }
}

resource "null_resource" "ansibleProvision" {
  depends_on = ["null_resource.remoteExecProvisionerWFolder", "null_resource.inventoryFileWeb"]
  count = 1
  connection {
    host = "${google_compute_instance.jenkins.*.network_interface.0.access_config.0.nat_ip}"
    type = "ssh"
    user = "centos"
    private_key = "${file("${var.private_key_path}")}"
    agent = "false"
  }
  provisioner "remote-exec" {
    inline = ["sudo sed -i -e 's+#host_key_checking+host_key_checking+g' /etc/ansible/ansible.cfg"]
  }
  provisioner "remote-exec" {
    inline = ["ansible-playbook -i /tmp/ansible/hosts.txt /tmp/ansible/main.yml"]
  }
}