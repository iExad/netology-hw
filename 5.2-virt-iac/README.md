# Домашнее задание к занятию "5.2. Применение принципов IaaC в работе с виртуальными машинами"
1. Основные преимущества IaaC - широкие возможности для масштабируемости, стабильность среды и повторяемость, документирование, скорость запуска продукта.
Основополагающим принципом IaaC, по моему мнению, является скорость которая достигается за счет меньших временных затрат на рутину.

2. Ansible - выгодно отличается от остальных систем управления конфигураций тем что не требует установки агента на стороне гостевой ОС используя существующую SSH инфраструктуру.
На мой взгляд более надежный метод работы систем конфигурации - push.

3. Установить на личный пк vagrant, ansible и virtualbox и вывести их установленные версии

```
vagrant -v                                                                                                                                                                                             130 ↵
Vagrant 2.2.19
```

```
ansible --version                                                                                                                                                                                        2 ↵
ansible 2.9.6
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/exad/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.8.10 (default, Nov 26 2021, 20:14:08) [GCC 9.3.0]
```

```
VBoxManage.exe -version
6.1.30r148432
```
