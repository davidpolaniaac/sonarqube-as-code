variable "do_token" {}

variable "image_id" {
  type = "string"
}

variable "sonar_user" {
  type = "string"
}

variable "sonar_password" {
  type = "string"
}

provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_tag" "devops-sonarqube" {
  name = "devops-sonar"
}

resource "digitalocean_droplet" "devops-sonarqube" {
  count    = 1
  image    = "${var.image_id}"
  name     = "devops-sonarqube-v2"
  region   = "nyc3"
  size     = "2GB"
  ssh_keys = [18131326]
  tags     = ["${digitalocean_tag.devops-sonarqube.id}"]

  lifecycle {
    create_before_destroy = true
  }

  provisioner "local-exec" {
    command = "sleep 160 && curl ${self.ipv4_address}:9000"
  }

  user_data = <<EOF
#cloud-config
coreos:
  units:
    - name: "devops.service"
      command: "start"
      content: |
        [Unit]
        Description=DevOps SonarQube
        After=docker.service
        [Service]
        ExecStart=/usr/bin/docker run -d -p 9000:9000 \
        -e SONARQUBE_JDBC_USERNAME=${var.sonar_user} \
        -e SONARQUBE_JDBC_PASSWORD=${var.sonar_password} \
        -e SONARQUBE_JDBC_URL=jdbc:sqlserver://sonarqubedevops.database.windows.net:1433\;database=SonarQubeDB \
        sonarqube
EOF
}
