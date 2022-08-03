#ID образа ос
variable "ubuntu_img" {}

#ID образа ос с nat
variable "ubuntu_img_nat" {}

#S3 bucket name
variable "s3_bucket" {
    default = ""
}

#S3 access key  
variable "s3_access_key" {
    default = ""
}

#S3 secret key
variable "s3_secret_key" {
    default = ""
}

#YandexCloud token
variable "yc_token" {}

#YandexCloud cloud ID
variable "yc_cloud_id" {}

#YandexCloud folder ID
variable "yc_folder_id" {}

#My DNS zone
variable "my_domain" {}

#Gitlab root password
variable "gitlab_pass" {}

#Gitlab runner token
variable "gitlab_runner" {}

#MySQL replication password
variable "mysql_repl_pass" {}

#Grafana admin password
variable "grafana_pass" {}

#LetsEncrypt staging
variable "my_le_staging" {
    default = "true"
}