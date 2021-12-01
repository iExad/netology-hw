# Домашнее задание к занятию "3.4. Операционные системы, лекция 2"

1. Создан unit-файл ```node-exporter.service```

```
[Unit]
Description=Node Exporter  

[Service]
EnvironmentFile=-/etc/sysconfig/node_exporter  
ExecStart=/opt/node_exporter/node_exporter $OPTIONS  

[Install]
WantedBy=multi-user.target
```

unit добавлен в автозагрузку ```systemctl enable node-exporter``` и запущен. После перезагрузки процесс запускается автоматически.

2. Ознакомился с опциями node_exporter и выводами ```/metrics```
Выбрал опции:
для мониторинга CPU ``` --collector.cpu.info```
для мониторинга памяти ```--collector.meminfo```
для мониторинга диска ```--collector.diskstats```
для мониторинга сети ```--collector.netdev```

3. Установил ```netdata``` из пакетов, отредактировал ```/etc/netdata/netdata.conf``` и отредактировал ```bind to = 0.0.0.0```

4. По выводу ```dmesg``` можно понять что система установлена в вирт среде. ```dmesg | grep vm``` показал ```systemd[1]: Detected virtualization vmware.```

5. По умолчанию ```fs.nr_open``` настроен на 1048576 файловых дескриптора. Достичь этого лимита не позволит ограничение в ```ulimit -n``` 1024.

6. ``` # unshare -f --pid --mount-proc sleep 1h```

```ps aux | grep sleep
root     22894  0.0  0.0   7236   584 pts/6    S+   02:59   0:00 unshare -f --pid --mount-proc sleep 1h
root     22895  0.0  0.0   7232   524 pts/6    S+   02:59   0:00 sleep 1h
root     22935  0.0  0.0   8164   728 pts/7    S+   02:59   0:00 grep --color=auto sleep
```

```nsenter --target 22895 --pid --mount```

```ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0   7232   524 pts/6    S+   02:59   0:00 sleep 1h
root         2  6.5  0.0  12092  6068 pts/7    S    02:59   0:00 -zsh
root        10  0.0  0.0  10620  3304 pts/7    R+   02:59   0:00 ps aux
```

7. ```:(){ :|:& };:``` - это форкбомба, функция, которая рекурсивно запускает саму себя и отправляет результат через пайп себе на вход для запуска в фоне. Данный процесс упирается в ограничение ulimit -u (количество процессов на пользователя). Сообщение в ```dmesg```:

```
cgroup: fork rejected by pids controller in /user.slice/user-1000.slice/session-3.scope
```
