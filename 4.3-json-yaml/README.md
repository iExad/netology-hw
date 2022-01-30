### 1. Мы выгрузили JSON, который получили через API запрос к нашему сервису:
```json
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            }
            { "name" : "second",
            "type" : "proxy",
            "ip : 71.78.22.43
            }
        ]
    }
```

Исправление
```json
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "port" : 7175 
            },
            { "name" : "second",
            "type" : "proxy",
            "ip" : "71.78.22.43"
            }
        ]
    }
```

### 2. В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: { "имя сервиса" : "его IP"}. Формат записи YAML по одному сервису: - имя сервиса: его IP. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

```python
import socket
import yaml
import json

lookupList = []
jsonList = []

with open('domains', 'rt') as file:
    line = file.readline()
    while line:
        line = line.split(' ')
        if len(line) > 1:
            try:
                newIp = socket.gethostbyname(line[0])
            except socket.SO_ERROR:
                print('Lookup error!')
            if newIp != line[1].strip():
                print(f'[ERROR] {line[0]} IP mismatch: {line[1].strip()} {newIp}')
            lookupList.append(line[0] + ' ' + newIp)
            jsonList.append({line[0]: newIp})
        line = file.readline()

with open('domains', 'wt') as file:
    for line in lookupList:
        file.write(line + '\n')

with open('domains.json', 'wt') as file:
        json.dump(jsonList, fp=file, indent=2)

with open('domains.yaml', 'wt') as file:
    yaml.dump(jsonList, file, default_flow_style=False, explicit_start=True, explicit_end=True)
```
