### Домашнее задание к занятию "5.3. Введение. Экосистема. Архитектура. Жизненный цикл Docker контейнера"

1. https://hub.docker.com/r/iexad/nginx-netology


2. Сценарий:

  -  Высоконагруженное монолитное java веб-приложение;

    Я думаю можно завернуть в докер, разделив веб приложение с базой данных, добавив веб прокси можно добиться отказоустойчивости и повторяемости. ну и проще перемещать и обновлять.

  -  Nodejs веб-приложение;

    В Docker-контейнере - лучше держать в изолированной от хостовой системы среде.

  -  Мобильное приложение c версиями для Android и iOS;

    Удобно делать сборки в контейнерах так как проще поддерживать версии необходимого ПО dev и test среду в целом. Но я встречал и использование и виртуалок для сборки Android приложений и железных маков (Mac mini) для iOS приложений. 

  -  Шина данных на базе Apache Kafka;

	Docker.

  -  Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;

    Docker. 

  -  Мониторинг-стек на базе Prometheus и Grafana;

    Docker.

  -  MongoDB, как основное хранилище данных для java-приложения;

	Docker.

  -  Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.

    Docker.

PS. Вcё перечисленное можно завернуть в контейнеры. Главное разделить приложение и данные.

 
3. ```
mkdir /data

docker run --rm --name centos8 -d -it -v /data:/data centos:8

docker run --rm --name debian11 -d -it -v /data:/data debian:11

$$ docker ps
CONTAINER ID   IMAGE       COMMAND       CREATED              STATUS              PORTS     NAMES
14605c9e3cc0   debian:11   "bash"        9 seconds ago        Up 8 seconds                  debian11
ea624647d4b3   centos:8    "/bin/bash"   About a minute ago   Up About a minute             centos8

docker exec centos8 sh -c "echo 'centos' > /data/centos"

touch /data/host

$ docker exec debian11 ls -al /data
total 12
drwxr-xr-x 2 root root 4096 Mar 20 10:58 .
drwxr-xr-x 1 root root 4096 Mar 20 10:56 ..
-rw-r--r-- 1 root root    7 Mar 20 10:57 centos
-rw-r--r-- 1 root root    0 Mar 20 10:58 host


$ docker exec debian11 sh -c "cat /data/*"
centos
host
```


