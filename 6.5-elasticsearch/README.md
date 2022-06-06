# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elasticsearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и
[документацию по установке и запуску Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

```bash
# cat Dockerfile

FROM centos:7

ARG ES_VERSION

ENV ES_VERSION=${ES_VERSION}

WORKDIR /tmp

RUN yum update -y && \
    yum install wget perl-Digest-SHA -y && \
    yum clean all -y && \
    wget https://fossies.org/linux/www/elasticsearch-${ES_VERSION}-linux-x86_64.tar.gz && \
    tar -xzf elasticsearch-${ES_VERSION}-linux-x86_64.tar.gz -C /opt/ && \
    rm -rf /tmp/elasticsearch-${ES_VERSION}-* && \
    groupadd -g 1000 elasticsearch && \
    adduser --uid 1000 --gid 1000 --home /opt/elasticsearch-${ES_VERSION} elasticsearch && \
    chown -R elasticsearch:elasticsearch /opt/elasticsearch-${ES_VERSION} && \
    mkdir /var/lib/elasticsearch && \
    chown -R elasticsearch:elasticsearch /var/lib/elasticsearch

EXPOSE 9200 9300

WORKDIR /opt/elasticsearch-${ES_VERSION}

USER elasticsearch

ENTRYPOINT ["./bin/elasticsearch"]
```
Сборка образа
```bash
# docker build --build-arg ES_VERSION=7.14.4 -t iexad/elasticsearch-netology .
```
Загрузка образа в docker-хранилище
```bash
# docker push iexad/elasticsearch-netology
```
https://hub.docker.com/repository/docker/iexad/elasticsearch-netology

Конфигурационный файл elasticsearch имеет вид

```bash
# grep -vE '^$|^#' elasticsearch.yml
cluster.name: my-elasticsearch-cluster
path.data: /var/lib/elasticsearch
path.repo: /opt/elasticsearch-7.14.4/snapshots
bootstrap.memory_lock: true
network.host: 0.0.0.0
http.port: 9200
discovery.type: single-node
```

Создаем каталог на хосте, который будет использоваться в качестве тома для хранения данных elastcisearch внутри контейнера, выставляем на него владелец/группу uid/gid которых соответствует uid/gid elasticsearch пользователя внутри контейнера

```bash
# mkdir -p .data/elasticsearch; chown -R 1000:1000 .data/elasticsearch
```

В логха elasticsearch контенйера при первом его запуске
```bash
[2022-06-06T00:13:28,503][WARN ][o.e.b.BootstrapChecks    ] [netology_test] max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
```
Устанавливаем на хосте требуемое значение для переменной ядра vm.max_map_count
```bash
# sudo sysctl -w vm.max_map_count=262144
```
Проверяем текущее значение
```bash
# sysctl -a  2>/dev/null | grep -w vm.max_map_count
vm.max_map_count = 262144
```

Создание и запуск docker-контейнера с Elasticsearch
```bash
# docker run \
       --name myelastic \
       -d -it \
       --ulimit memlock=-1:-1 \
       -p 9200:9200 \
       -v $PWD/.data/elasticsearch:/var/lib/elasticsearch \
       -v $PWD/elasticsearch.yml:/opt/elasticsearch-7.14.4/config/elasticsearch.yml \
      iexad/elasticsearch-netology:7 \
      -Ehttp.host=0.0.0.0 \
      -Enode.name=netology_test
```

```bash
# curl localhost:9200
{
  "name" : "netology_test",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "bGgkxRJ-RWWTDpj1WF_B4Q",
  "version" : {
    "number" : "7.17.4",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "79878662c54c886ae89206c685d9f1051a9d6411",
    "build_date" : "2022-05-18T18:04:20.964345128Z",
    "build_snapshot" : false,
    "lucene_version" : "8.11.1",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html)
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

```bash
curl -X PUT --url localhost:9200/ind-1 -H 'content-type: application/json' -d '{
  "settings": {
    "index": {
      "number_of_shards": 1,
      "number_of_replicas": 0
    }
  }
}'
```
```bash
curl -X PUT --url localhost:9200/ind-2 -H 'content-type: application/json' -d '{
  "settings": {
    "index": {
      "number_of_shards": 2,
      "number_of_replicas": 1
    }
  }
}'
```
```bash
curl -X PUT --url localhost:9200/ind-3 -H 'content-type: application/json' -d '{
  "settings": {
    "index": {
      "number_of_shards": 4,
      "number_of_replicas": 2
    }
  }
}'
```
Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.
```bash
# curl localhost:9200/_cat/indices
green  open .geoip_databases zC9j0EWdRbinO5qZyVfH1A 1 0 40 0 38.2mb 38.2mb
green  open ind-1            DllyUCOUSZOHMS7cl3DZhQ 1 0  0 0   226b   226b
yellow open ind-3            GmkCF3AySGar5lfeAoJtwA 4 2  0 0   604b   604b
yellow open ind-2            gvFYk8etSKmzSAhjqhTXWA 2 1  0 0   452b   452b
```
Получите состояние кластера `elasticsearch`, используя API.
```bash
# curl localhost:9200/_cluster/health?pretty
{
  "cluster_name" : "elasticsearch",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 10,
  "active_shards" : 10,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 50.0
}
```


Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?


Состояние кластера определяется на основании состояния его шардов

Присутствуют secondary шарды в состоянии unassigned т.к мы создавали второй и третий индексы с репликацией

При этом нода в кластере одна и соответственно шарды индексов не реплицируются на другие ноды

Удалите все индексы.

```bash
# curl -X DELETE --url localhost:9200/ind-1,ind-2,ind-3 -H 'content-type: application/json'
```
```bash
# curl localhost:9200/_cat/indices
green open .geoip_databases zC9j0EWdRbinO5qZyVfH1A 1 0 40 0 38.2mb 38.2mb
```

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository)
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

Указываем расположение репозитория на файловой системе внутри контейнера

```bash
# grep 'path.repo' elasticsearch.yml
path.repo: /opt/elasticsearch-7.17.4/snapshots
```

Рестарт docker-контейнер с elasticsearch для применения сделанной выше настройки
```bash
# docker restart myelastic
```
Регистрация репозитария для снепшота
```bash
# curl -X PUT --url localhost:9200/_snapshot/netology_backup -H 'content-type: application/json' -d '{
  "type": "fs",
  "settings": {
    "location": "snapshots",
    "compress": true
  }
}'
```

Просмотр списка всех зарегистрированных репозитариев для хранения снепшотов
```bash
# curl localhost:9200/_snapshot
{"netology_backup":{"type":"fs","settings":{"compress":"true","location":"snapshots"}}}}
```

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.
```bash
# curl -X PUT --url localhost:9200/test -H 'content-type: application/json' -d '{
  "settings": {
    "index": {
      "number_of_shards": 1,
      "number_of_replicas": 0
    }
  }
}'
```
```bash
# curl localhost:9200/_cat/indices
green open .geoip_databases vD2JYBCgSeiHcYj3PYlGjg 1 0 40 0 38.2mb 38.2mb
green open test             WgoXOTDcTaqAKfj5PNs8EQ 1 0  0 0   226b   226b
```

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html)
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.
```bash
# curl -X PUT --url localhost:9200/_snapshot/netology_backup/my_snapshot?wait_for_completion=true
{"snapshot":{"snapshot":"my_snapshot","uuid":"lIuWGxIUTySu4f-Ux8nJJg","repository":"netology_backup","version_id":7170499,"version":"7.17.4","indices":["test",".ds-ilm-history-5-2022.06.06-000001",".geoip_databases",".ds-.logs-deprecation.elasticsearch-default-2022.06.06-000001"],"data_streams":["ilm-history-5",".logs-deprecation.elasticsearch-default"],"include_global_state":true,"state":"SUCCESS","start_time":"2022-06-06T23:24:43.364Z","start_time_in_millis":1654557883364,"end_time":"2022-06-06T23:24:44.836Z","end_time_in_millis":1654557884836,"duration_in_millis":1472,"failures":[],"shards":{"total":4,"failed":0,"successful":4},"feature_states":[{"feature_name":"geoip","indices":[".geoip_databases"]}]}}
```
```bash
# docker exec myelastic ls -l /opt/elasticsearch-7.17.4/snapshots/snapshots
total 28
-rw-r--r-- 1 elasticsearch elasticsearch 1423 Jun  6 23:24 index-0
-rw-r--r-- 1 elasticsearch elasticsearch    8 Jun  6 23:24 index.latest
drwxr-xr-x 6 elasticsearch elasticsearch 4096 Jun  6 23:24 indices
-rw-r--r-- 1 elasticsearch elasticsearch 9741 Jun  6 23:24 meta-lIuWGxIUTySu4f-Ux8nJJg.dat
-rw-r--r-- 1 elasticsearch elasticsearch  457 Jun  6 23:24 snap-lIuWGxIUTySu4f-Ux8nJJg.dat
```
Список снепшотов в конкретном репозитории
```bash
# curl localhost:9200/_snapshot/netology_backup/*?verbose=false
{"snapshots":[{"snapshot":"my_snapshot","uuid":"lIuWGxIUTySu4f-Ux8nJJg","repository":"netology_backup","indices":[".ds-.logs-deprecation.elasticsearch-default-2022.06.06-000001",".ds-ilm-history-5-2022.06.06-000001",".geoip_databases","test"],"data_streams":[],"state":"SUCCESS"}],"total":1,"remaining":0}
```

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

```bash
# curl -X DELETE --url localhost:9200/test -H 'content-type: application/json'
```
```bash
# curl localhost:9200/_cat/indices
green open .geoip_databases vD2JYBCgSeiHcYj3PYlGjg 1 0 40 0 38.2mb 38.2mb
```
```bash
# curl -X PUT --url localhost:9200/test-2 -H 'content-type: application/json' -d '{
  "settings": {
    "index": {
      "number_of_shards": 1,
      "number_of_replicas": 0
    }
  }
}'
```
```bash
# curl localhost:9200/_cat/indices
green open test-2           yFoaGP4IQJSm2I1M5WQo1g 1 0  0 0   226b   226b
green open .geoip_databases vD2JYBCgSeiHcYj3PYlGjg 1 0 40 0 38.2mb 38.2mb
```
[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее.

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.
```bash
# curl -X POST localhost:9200/_snapshot/netology_backup/my_snapshot/_restore -H 'Content-Type: application/json' -d '{
    "include_global_state": true
}'
{"error":{"root_cause":[{"type":"snapshot_restore_exception","reason":"[netology_backup:my_snapshot/lIuWGxIUTySu4f-Ux8nJJg] cannot restore index [.ds-.logs-deprecation.elasticsearch-default-2022.06.06-000001] because an open index with same name already exists in the cluster. Either close or delete the existing index or restore the index under a different name by providing a rename pattern and replacement name"}],"type":"snapshot_restore_exception","reason":"[netology_backup:my_snapshot/lIuWGxIUTySu4f-Ux8nJJg] cannot restore index [.ds-.logs-deprecation.elasticsearch-default-2022.06.06-000001] because an open index with same name already exists in the cluster. Either close or delete the existing index or restore the index under a different name by providing a rename pattern and replacement name"},"status":500}
```

Закрываем индекс `.ds-.logs-deprecation.elasticsearch-default-2022.06.06-000001`
```bash
# curl -X POST localhost:9200/.ds-.logs-deprecation.elasticsearch-default-2022.06.06-000001/_close -H 'content-type: application/json'
```
```bash
# curl -X POST localhost:9200/_snapshot/netology_backup/my_snapshot/_restore -H 'Content-Type: application/json' -d '{
    "include_global_state": true
}'
{{"error":{"root_cause":[{"type":"snapshot_restore_exception","reason":"[netology_backup:my_snapshot/lIuWGxIUTySu4f-Ux8nJJg] cannot restore index [.ds-ilm-history-5-2022.06.06-000001] because an open index with same name already exists in the cluster. Either close or delete the existing index or restore the index under a different name by providing a rename pattern and replacement name"}],"type":"snapshot_restore_exception","reason":"[netology_backup:my_snapshot/lIuWGxIUTySu4f-Ux8nJJg] cannot restore index [.ds-ilm-history-5-2022.06.06-000001] because an open index with same name already exists in the cluster. Either close or delete the existing index or restore the index under a different name by providing a rename pattern and replacement name"},"status":500}
```

Закрываем индекс `.ds-ilm-history-5-2022.06.06-000001`
```bash
# curl -X POST localhost:9200/.ds-ilm-history-5-2022.06.06-000001/_close -H 'content-type: application/json'
```
```bash
# curl -X POST localhost:9200/_snapshot/netology_backup/my_snapshot/_restore -H 'Content-Type: application/json' -d '{
    "include_global_state": true
}'
{"accepted":true}
```
```bash
# curl localhost:9200/_cat/indices
green open test-2           yFoaGP4IQJSm2I1M5WQo1g 1 0  0 0   226b   226b
green open .geoip_databases EmPnF2I0SOCsnMdZ-NZVRw 1 0 40 0 38.2mb 38.2mb
green open test             VjfTHcv6RCK33Rp94wTQ3Q 1 0  0 0   226b   226b
```