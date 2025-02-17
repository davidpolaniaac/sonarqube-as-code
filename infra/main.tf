terraform {
  backend "s3" {
    bucket = "polaniadevops"
    region = "us-east-2"
    key    = "terraform.tfstate"
    access_key = "AKIAI5XZSFJHKNRWLISA"
    secret_key = "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"
  }
}

variable "do_token" {}

variable "image_id" {
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
  size     = "4GB"
  ssh_keys = [18131326]
  tags     = ["${digitalocean_tag.devops-sonarqube.id}"]

  lifecycle {
    create_before_destroy = true
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
        ExecStart=/usr/bin/docker run -d --name sonarqube -p 9000:9000 -e SONARQUBE_JDBC_USERNAME=devops -e SONARQUBE_JDBC_PASSWORD=maria830. -e SONARQUBE_JDBC_URL=jdbc:sqlserver://sonarqubedevops.database.windows.net:1433\;database=sonarqube\;trustServerCertificate=false\;hostNameInCertificate=*.database.windows.net\;loginTimeout=30 sonarqube
EOF
}
