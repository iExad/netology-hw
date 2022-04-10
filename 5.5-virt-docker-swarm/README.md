# Домашнее задание к занятию "5.5. Оркестрация кластером Docker контейнеров на примере Docker Swarm"

## Задача 1

Дайте письменые ответы на следующие вопросы:

- В чём отличие режимов работы сервисов в Docker Swarm кластере: replication и global?
  - replication - запуск указанного в конфигурации количества копий сервиса
  - global - сервис будет запущен на всех нодах кластера

- Какой алгоритм выбора лидера используется в Docker Swarm кластере?

    Мастер нода выбирается из управляющих нод путем `Raft` согласованного алгоритма, путем одобрения большинством управляющих узлов, называемых кворумом для этого требуется нечетное количество управляющих узлов

- Что такое Overlay Network?

    Это виртуальная сеть, построенная поверх другой уже существующей сети

    В Overlay Network используется инканпсуляция и деинкапсуляция пакетов, когда один пакет помещается внутрь другого пакета на исходном сервере
    и затем в обратном порядке распаковывается уже на целевом сервере

    Это позволяет:
    - создавать новые свойства сети, которые невозможны в стандартной инфраструктуре
    - создания и использование сервисов, которые невозможны в стандартной инфраструктуре

    Основным преимуществом оверлейных сетей является то, что они позволяют разрабатывать и эксплуатировать новые крупномасштабные распределённые сервисы без внесения каких-либо изменений в основные протоколы сети

## Задача 2

```
docker node ls
```

```bash
$ sudo docker node ls
ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
y2byqp44nljx2m9e7y9p2msfs *   node01.netology.yc   Ready     Active         Leader           20.10.11
b6mkh4ywmnnzpkt9h75zkx4ht     node02.netology.yc   Ready     Active         Reachable        20.10.11
po5dihy5dhir9qftx6qgcppo1     node03.netology.yc   Ready     Active         Reachable        20.10.11
x0b3lhx65b4v37x1rn4es4xsz     node04.netology.yc   Ready     Active                          20.10.11
nvauy3k62uerm2xh34b5npts3     node05.netology.yc   Ready     Active                          20.10.11
9imm0jbawdwegp12wxd8hqmph     node06.netology.yc   Ready     Active                          20.10.11
```

## Задача 3

```
docker service ls
```

```bash
$ sudo docker service ls
ID             NAME                                MODE         REPLICAS   IMAGE                                          PORTS
yi4no070jwee   swarm_monitoring_alertmanager       replicated   1/1        stefanprodan/swarmprom-alertmanager:v0.14.0
v5t3ye1v8k45   swarm_monitoring_caddy              replicated   1/1        stefanprodan/caddy:latest                      *:3000->3000/tcp, *:9090->9090/tcp, *:9093-9094->9093-9094/tcp
ysm8xvk0hg6k   swarm_monitoring_cadvisor           global       6/6        google/cadvisor:latest
fzc29pxvxamj   swarm_monitoring_dockerd-exporter   global       6/6        stefanprodan/caddy:latest
vci6wcmi9619   swarm_monitoring_grafana            replicated   1/1        stefanprodan/swarmprom-grafana:5.3.4
tyeai1irdkli   swarm_monitoring_node-exporter      global       6/6        stefanprodan/swarmprom-node-exporter:v0.16.0
axgmj0r5jxxi   swarm_monitoring_prometheus         replicated   1/1        stefanprodan/swarmprom-prometheus:v2.5.0
yb67hvcvkkse   swarm_monitoring_unsee              replicated   1/1        cloudflare/unsee:v0.8.0
```
