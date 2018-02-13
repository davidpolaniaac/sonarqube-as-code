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
  size     = "2GB"
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
        ExecStart=/usr/bin/docker run -d --name sonarqube -p 9000:9000 sonarqube
EOF
}
