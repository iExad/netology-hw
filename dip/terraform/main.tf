
#Networking
resource "yandex_vpc_network" "network-1" {
  name = "network-${local.workspace[terraform.workspace]}-${local.instance_count[terraform.workspace]}"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet-${local.instance_count[terraform.workspace]}-${local.workspace[terraform.workspace]}"
  zone           = local.vpc_zone[terraform.workspace]
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = local.vpc_v4_cidr_blocks[terraform.workspace]
  route_table_id          = yandex_vpc_route_table.nat.id
}

resource "yandex_vpc_route_table" "nat" {
  network_id = "${yandex_vpc_network.network-1.id}"

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.1.10"
  }
}

locals {
  instance_count = {
    stage   = 1
  }
  vpc_zone  = {
    stage   = "ru-central1-a"
  }
  vpc_v4_cidr_blocks = {
    stage   = ["192.168.1.0/24"]
  }
  workspace = {
    stage   = "stage"
  }
}

#Nginx instance create
resource "yandex_compute_instance" "nginx" {
  name      = "nginx-${local.workspace[terraform.workspace]}"
  hostname  = "${var.my_domain}"

  resources  {
    cores   = 2
    memory  = 2
  }

  boot_disk {
    initialize_params {
      image_id = "${var.ubuntu_img_nat}"
      size = "10"
    }
  }

  network_interface {
    subnet_id      = yandex_vpc_subnet.subnet-1.id
    nat            = true
    ip_address = "192.168.1.10"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

#DB01 instance create
resource "yandex_compute_instance" "db01" {
  name      = "db01-${local.workspace[terraform.workspace]}"
  hostname  = "db01.${var.my_domain}"
  resources {
    cores = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "${var.ubuntu_img}"
      size = "10"
    }
  }
  network_interface {
    subnet_id   = yandex_vpc_subnet.subnet-1.id
    ip_address  = "192.168.1.20"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

#DB02 instance create
resource "yandex_compute_instance" "db02" {
  name      = "db02-${local.workspace[terraform.workspace]}"
  hostname  = "db02.${var.my_domain}"
  resources {
    cores   = 4
    memory  = 4
  }

  boot_disk {
    initialize_params {
      image_id = "${var.ubuntu_img}"
      size = "10"
    }
  }

  network_interface {
    subnet_id   = yandex_vpc_subnet.subnet-1.id
    ip_address  = "192.168.1.30"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

#Wordpress instance creating
resource "yandex_compute_instance" "app" {
  name     = "app-${local.workspace[terraform.workspace]}"
  hostname = "app.${var.my_domain}"
  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "${var.ubuntu_img}"
      size = "10"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    ip_address = "192.168.1.40"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

#Gitlab instance creating
resource "yandex_compute_instance" "gitlab" {
  name     = "gitlab-${local.workspace[terraform.workspace]}"
  hostname = "gitlab.${var.my_domain}"
  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "${var.ubuntu_img}"
      size = "10"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet-1.id
    ip_address = "192.168.1.50"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

#Gitlab runner instance creating
resource "yandex_compute_instance" "runner" {
  name     = "runner-${local.workspace[terraform.workspace]}"
  hostname = "runner.${var.my_domain}"
  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "${var.ubuntu_img}"
      size = 10
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet-1.id
    ip_address = "192.168.1.60"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

}

#Monitoring instance creating
resource "yandex_compute_instance" "monitoring" {
  name = "monitoring-${local.workspace[terraform.workspace]}"
  hostname = "monitoring.${var.my_domain}"
  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "${var.ubuntu_img}"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet-1.id
    ip_address = "192.168.1.70"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

#DNS setup
resource "yandex_dns_zone" "zone1" {
  name        = "jdmkzn-zone"
  zone             = "${var.my_domain}."
  public           = true
#  private_networks = [yandex_vpc_network.network-1.id]
}

resource "yandex_dns_recordset" "at" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "${var.my_domain}."
  type    = "A"
  ttl     = 90
  data    = [yandex_compute_instance.nginx.network_interface[0].nat_ip_address]
  depends_on = [yandex_compute_instance.nginx]
}

resource "yandex_dns_recordset" "www" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "www"
  type    = "A"
  ttl     = 90
  data    = [yandex_compute_instance.nginx.network_interface[0].nat_ip_address]
  depends_on = [yandex_compute_instance.nginx]
}

resource "yandex_dns_recordset" "gitlab" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "gitlab"
  type    = "A"
  ttl     = 90
  data    = [yandex_compute_instance.nginx.network_interface[0].nat_ip_address]
  depends_on = [yandex_compute_instance.nginx]
}

resource "yandex_dns_recordset" "grafana" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "grafana"
  type    = "A"
  ttl     = 90
  data    = [yandex_compute_instance.nginx.network_interface[0].nat_ip_address]
  depends_on = [yandex_compute_instance.nginx]
}

resource "yandex_dns_recordset" "prometheus" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "prometheus"
  type    = "A"
  ttl     = 90
  data    = [yandex_compute_instance.nginx.network_interface[0].nat_ip_address]
  depends_on = [yandex_compute_instance.nginx]
}

resource "yandex_dns_recordset" "alertmanager" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "alertmanager"
  type    = "A"
  ttl     = 90
  data    = [yandex_compute_instance.nginx.network_interface[0].nat_ip_address]
  depends_on = [yandex_compute_instance.nginx]
}