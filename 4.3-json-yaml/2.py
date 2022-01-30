#!/usr/bin/env python3

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