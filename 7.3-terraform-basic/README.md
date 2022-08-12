# Домашнее задание к занятию "7.3. Основы и принцип работы Терраформ"

## Задача 1. Создадим бэкэнд в S3 (необязательно, но крайне желательно).

Если в рамках предыдущего задания у вас уже есть аккаунт AWS, то давайте продолжим знакомство со взаимодействием
терраформа и aws. 

1. Создайте s3 бакет, iam роль и пользователя от которого будет работать терраформ. Можно создать отдельного пользователя,
а можно использовать созданного в рамках предыдущего задания, просто добавьте ему необходимы права, как описано 
[здесь](https://www.terraform.io/docs/backends/types/s3.html).
1. Зарегистрируйте бэкэнд в терраформ проекте как описано по ссылке выше. 


## Задача 2. Инициализируем проект и создаем воркспейсы. 

1. Выполните `terraform init`:
    * если был создан бэкэнд в S3, то терраформ создат файл стейтов в S3 и запись в таблице 
dynamodb.
    * иначе будет создан локальный файл со стейтами.  
2. Создайте два воркспейса `stage` и `prod`.

---

**Ответ**

```bash
$ terraform workspace new stage
Created and switched to workspace "stage"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.

$ terraform workspace new prod
Created and switched to workspace "prod"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.

$ terraform workspace list
  default
* prod
  stage
```

---

3. В уже созданный `aws_instance` добавьте зависимость типа инстанса от вокспейса, что бы в разных ворскспейсах 
использовались разные `instance_type`.

---

**Ответ**

Добавлена переменную `instance_type` с разным значением для `core_fraction`.

```hcl
locals {
instance_type = {
    stage = "5"
    prod  = "10"
    }
}
```

Добавлена зависимость создаваемого инстанса от workspace

```hcl
resource "yandex_compute_instance" "node" {
  name                      = "node01"
  zone                      = "ru-central1-a"
  hostname                  = "node01.ntlg.yc"
  platform_id               = "standard-v1"
  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 2
    core_fraction = local.instance_type[terraform.workspace]
  }
```

---

4. Добавим `count`. Для `stage` должен создаться один экземпляр `ec2`, а для `prod` два. 

---

**Ответ**

Добавлена переменная `instance_count`

```hcl
locals {
  instance_count = {
    stage = 1
    prod = 2
  }
}
```
```hcl
resource "yandex_compute_instance" "node" {
  name                      = "node0${count.index+1}-${terraform.workspace}"
  zone                      = "ru-central1-a"
  hostname                  = "node0${count.index+1}.ntlg.yc"
  platform_id               = "standard-v1"
  allow_stopping_for_update = true
  count                     = local.instance_count[terraform.workspace]```
```

---

5. Создайте рядом еще один `aws_instance`, но теперь определите их количество при помощи `for_each`, а не `count`.

---

**Ответ**

Создаем еще один `instance`

```hcl
locals {
  instance_for_each = {
    stage = 1
    prod  = 2
  }
}

resource "yandex_compute_instance" "node_for_each" {
  for_each                  = local.instance_for_each
  name                      = "node0${each.value}-${terraform.workspace}-for_each"
  zone                      = "ru-central1-a"
  hostname                  = "node0${each.value}.ntlg.yc"
  platform_id               = "standard-v1"
  allow_stopping_for_update = true
[terraform.workspace]

  resources {
    cores         = 2
    memory        = 2
    core_fraction = local.instance_type[terraform.workspace]
  }

  boot_disk {
    initialize_params {
      image_id    = var.ubuntu-latest
      name        = "root-node0${each.value}"
      size        = "10"
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.default.id}"
    nat        = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}
```
---

6. Что бы при изменении типа инстанса не возникло ситуации, когда не будет ни одного инстанса добавьте параметр
жизненного цикла `create_before_destroy = true` в один из рессурсов `aws_instance`.

---

**Ответ**

Добавлено:

```hcl
  lifecycle {
    create_before_destroy = true
  }
```

---

## В виде результата работы пришлите:
* Вывод команды `terraform workspace list`.
* Вывод команды `terraform plan` для воркспейса `prod`.  

---

**Ответ**

```
$ terraform workspace list
  default
* prod
  stage
```

<details><summary>`terraform plan` </summary>

```
$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # yandex_compute_instance.node[0] will be created
  + resource "yandex_compute_instance" "node" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = "node01.ntlg.yc"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDXHmd5Uki/NUukiGGtK/5v6ZbSzI1sKA+3OeREcjfHgCRiEpSaGIyYD+yH6k4PbK0OiM55GYRA9ylx3Zr7ns0OIg6+06Gupe3FrCfEQEfhCZImfSbaWHUNC4RXVPyCh+DTHi9sPeOfMUJt0Sff9wU8HbQxRF0+RqMoCms4lR2YdlqnmukYQ3QqdGnW1Whu15b39o2U1qSHxwHboPHDKBERZMFG/UTnQ94rdaDSqyrq8sj3MleYKtp535Pk7DF0Wk/XZMBKredfSzSK2euDUpA+0Hmj8FU56EMJ6TQW5dajar0F4rrTUky2is+7wyjc5mKzFVlYkUZcM3LJZbx2mPoj exad
            EOT
        }
      + name                      = "node01-prod"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-a"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd826dalmbcl81eo5nig"
              + name        = "root-node01"
              + size        = 10
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 10
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.node[1] will be created
  + resource "yandex_compute_instance" "node" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = "node02.ntlg.yc"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDXHmd5Uki/NUukiGGtK/5v6ZbSzI1sKA+3OeREcjfHgCRiEpSaGIyYD+yH6k4PbK0OiM55GYRA9ylx3Zr7ns0OIg6+06Gupe3FrCfEQEfhCZImfSbaWHUNC4RXVPyCh+DTHi9sPeOfMUJt0Sff9wU8HbQxRF0+RqMoCms4lR2YdlqnmukYQ3QqdGnW1Whu15b39o2U1qSHxwHboPHDKBERZMFG/UTnQ94rdaDSqyrq8sj3MleYKtp535Pk7DF0Wk/XZMBKredfSzSK2euDUpA+0Hmj8FU56EMJ6TQW5dajar0F4rrTUky2is+7wyjc5mKzFVlYkUZcM3LJZbx2mPoj exad
            EOT
        }
      + name                      = "node02-prod"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-a"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd826dalmbcl81eo5nig"
              + name        = "root-node02"
              + size        = 10
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 10
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.node_for_each["prod"] will be created
  + resource "yandex_compute_instance" "node_for_each" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = "node02.ntlg.yc"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDXHmd5Uki/NUukiGGtK/5v6ZbSzI1sKA+3OeREcjfHgCRiEpSaGIyYD+yH6k4PbK0OiM55GYRA9ylx3Zr7ns0OIg6+06Gupe3FrCfEQEfhCZImfSbaWHUNC4RXVPyCh+DTHi9sPeOfMUJt0Sff9wU8HbQxRF0+RqMoCms4lR2YdlqnmukYQ3QqdGnW1Whu15b39o2U1qSHxwHboPHDKBERZMFG/UTnQ94rdaDSqyrq8sj3MleYKtp535Pk7DF0Wk/XZMBKredfSzSK2euDUpA+0Hmj8FU56EMJ6TQW5dajar0F4rrTUky2is+7wyjc5mKzFVlYkUZcM3LJZbx2mPoj exad
            EOT
        }
      + name                      = "node02-prod-for_each"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-a"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd826dalmbcl81eo5nig"
              + name        = "root-node02"
              + size        = 10
              + snapshot_id = (known after apply)
              + type        = "network-nvme"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 10
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.node_for_each["stage"] will be created
  + resource "yandex_compute_instance" "node_for_each" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = "node01.ntlg.yc"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDXHmd5Uki/NUukiGGtK/5v6ZbSzI1sKA+3OeREcjfHgCRiEpSaGIyYD+yH6k4PbK0OiM55GYRA9ylx3Zr7ns0OIg6+06Gupe3FrCfEQEfhCZImfSbaWHUNC4RXVPyCh+DTHi9sPeOfMUJt0Sff9wU8HbQxRF0+RqMoCms4lR2YdlqnmukYQ3QqdGnW1Whu15b39o2U1qSHxwHboPHDKBERZMFG/UTnQ94rdaDSqyrq8sj3MleYKtp535Pk7DF0Wk/XZMBKredfSzSK2euDUpA+0Hmj8FU56EMJ6TQW5dajar0F4rrTUky2is+7wyjc5mKzFVlYkUZcM3LJZbx2mPoj exad
            EOT
        }
      + name                      = "node01-prod-for_each"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-a"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd826dalmbcl81eo5nig"
              + name        = "root-node01"
              + size        = 10
              + snapshot_id = (known after apply)
              + type        = "network-nvme"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 10
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_vpc_network.default will be created
  + resource "yandex_vpc_network" "default" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "net"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.default will be created
  + resource "yandex_vpc_subnet" "default" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnet"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.1.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

Plan: 6 to add, 0 to change, 0 to destroy.

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if
you run "terraform apply" now.
```
</details>

