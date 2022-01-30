# Домашнее задание к занятию "4.2. Использование Python для решения типовых DevOps задач"

## Обязательная задача 1

Есть скрипт:
```python
#!/usr/bin/env python3
a = 1
b = '2'
c = a + b
```

### Вопросы:
| Вопрос  | Ответ |
| ------------- | ------------- |
| Какое значение будет присвоено переменной `c`?  | ошибка типов. а - int, b - str  |
| Как получить для переменной `c` значение 12?  | Задать для переменной тип значения str добавив кавычки, либо `c = str(a) + b`|
| Как получить для переменной `c` значение 3?  | убрать кавычки в значении переменной b, либо `c = a + int(b)` |

## Обязательная задача 2
Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
        break
```

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/pytest", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
working_dir = os.popen('pwd').read()
print("Git directory is: " + working_dir)
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
```

### Вывод скрипта при запуске при тестировании:
```
Git directory is: /home/exad/pytest

$ ./w.py
1
2
```

## Обязательная задача 3
Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os
check_git = False
while check_git == False:
    print("Enter path to git direcroty:")
    set_dir = str(input())
    check_git = os.path.isdir(set_dir + "/.git")
    if check_git == False:
        print("\nEntered dir is not a git repo!!!!!")

bash_command = ["cd " + set_dir, "git status"]
result_os = os.popen(' && '.join(bash_command)).read()

print("\nGit directory is: " + set_dir)
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
```

### Вывод скрипта при запуске при тестировании:
```
$ ./w.py
Enter path to git direcroty:
/home/exad/1
Entered dir is not a git repo!!!!!
Enter path to git direcroty:
/home/exad/pytest

Git directory is: /home/exad/pytest
1
2
```

## Обязательная задача 4
Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: `drive.google.com`, `mail.google.com`, `google.com`.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import socket

lookupList = []

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
        line = file.readline()

with open('domains', 'wt') as file:
    for line in lookupList:
        file.write(line + '\n')
```

### Вывод скрипта при запуске при тестировании:
```
[ERROR] drive.google.com IP mismatch: 74.125.131.194 142.251.1.194
[ERROR] mail.google.com IP mismatch: 142.250.74.37 216.58.209.165
```
