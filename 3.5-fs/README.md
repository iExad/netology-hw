# Домашнее задание к занятию "3.5. Файловые системы"
1. Почитал о ```sparce``` (Разрежённых) файлах.

2. Файлы являющиеся жесткой ссылкой на один объект не может иметь разных прав доступа, это особенность хардлинков в отличии от симлинков.

3. Пересоздал виртуалку с предоставленной конфигурацией. 

4. Разбил первый диск на 2 раздела. 1й - 2ГБ.

```
fdisk /dev/sdb
Welcome to fdisk (util-linux 2.34).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0x9e7f34be.

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p):

Using default response p.
Partition number (1-4, default 1):
First sector (2048-5242879, default 2048):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-5242879, default 5242879): +2G

Created a new partition 1 of type 'Linux' and of size 2 GiB.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

5. Перенес таблицу разделов на второй диск.

```
sfdisk -d /dev/sdb > pt
sfdisk /dev/sdc < pt
```
6. Создал RAID1 из 2х первых разделов.

```
mdadm --create --verbose /dev/md0 -l 1 -n 2 /dev/sd{b1,c1}
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
mdadm: size set to 2094080K
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
------------------
lsblk

Disk /dev/md0: 1.102 GiB, 2144337920 bytes, 4188160 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

root@vagrant:~# lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                    8:0    0   64G  0 disk
├─sda1                 8:1    0  512M  0 part  /boot/efi
├─sda2                 8:2    0    1K  0 part
└─sda5                 8:5    0 63.5G  0 part
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
sdb                    8:16   0  2.5G  0 disk
└─sdb1                 8:17   0    2G  0 part
  └─md0                9:0    0    2G  0 raid1
sdc                    8:32   0  2.5G  0 disk
└─sdc1                 8:33   0    2G  0 part
  └─md0                9:0    0    2G  0 raid1
```

7. Собрал RAID 0 на второй паре маленьких разделов

```
mdadm --create --verbose /dev/md1 -l 0 -n 2 /dev/sd{b2,c2}
mdadm: chunk size defaults to 512K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md1 started.

root@vagrant:~# lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                    8:0    0   64G  0 disk
├─sda1                 8:1    0  512M  0 part  /boot/efi
├─sda2                 8:2    0    1K  0 part
└─sda5                 8:5    0 63.5G  0 part
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
sdb                    8:16   0  2.5G  0 disk
├─sdb1                 8:17   0    2G  0 part
│ └─md0                9:0    0    2G  0 raid1
└─sdb2                 8:18   0  511M  0 part
  └─md1                9:1    0 1018M  0 raid0
sdc                    8:32   0  2.5G  0 disk
├─sdc1                 8:33   0    2G  0 part
│ └─md0                9:0    0    2G  0 raid1
└─sdc2                 8:34   0  511M  0 part
  └─md1                9:1    0 1018M  0 raid0
```

8. Создал 2 независимых PV на получившихся md устройствах.

```
root@vagrant:~# pvcreate /dev/md0
  Physical volume "/dev/md0" successfully created.
root@vagrant:~# pvcreate /dev/md1
  Physical volume "/dev/md1" successfully created.
```

9. Создал общую VG

```
root@vagrant:~# vgcreate vg1 /dev/md0 /dev/md1
  Volume group "vg1" successfully created
```

10. 
```
root@vagrant:~# lvcreate -L100M -n lv_R0 vg1 /dev/md1
  Logical volume "lv_R0" created.
root@vagrant:~# lvs
  LV     VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lv_R0  vg1       -wi-a----- 100.00m
  root   vgvagrant -wi-ao---- <62.54g
  swap_1 vgvagrant -wi-ao---- 980.00m
root@vagrant:~# lvdisplay vg1
  --- Logical volume ---
  LV Path                /dev/vg1/lv_R0
  LV Name                lv_R0
  VG Name                vg1
  LV UUID                68fspK-6fbJ-W23U-CXY2-yKZW-F3gK-EFAIQh
  LV Write Access        read/write
  LV Creation host, time vagrant, 2021-12-01 22:48:28 +0000
  LV Status              available
  # open                 0
  LV Size                100.00 MiB
  Current LE             25
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     4096
  Block device           253:2
```

11.

```
root@vagrant:~# mkfs.ext4 /dev/vg1/lv_R0
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 25600 4k blocks and 25600 inodes

Allocating group tables: done
Writing inode tables: done
Creating journal (1024 blocks): done
Writing superblocks and filesystem accounting information: done
```

12.

```
root@vagrant:~# mkdir /tmp/r0-mnt
root@vagrant:~# mount /dev/vg1/lv_R0 /tmp/r0-mnt
root@vagrant:~# df -h
Filesystem                  Size  Used Avail Use% Mounted on
udev                        447M     0  447M   0% /dev
tmpfs                        99M  712K   98M   1% /run
/dev/mapper/vgvagrant-root   62G  1.6G   57G   3% /
tmpfs                       491M     0  491M   0% /dev/shm
tmpfs                       5.0M     0  5.0M   0% /run/lock
tmpfs                       491M     0  491M   0% /sys/fs/cgroup
/dev/sda1                   511M  4.0K  511M   1% /boot/efi
tmpfs                        99M     0   99M   0% /run/user/1000
/dev/mapper/vg1-lv_R0        93M   72K   86M   1% /tmp/r0-mnt
```

13. 

```
root@vagrant:/tmp/r0-mnt# wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/r0-mnt/test.gz
```

14.
 
```
root@vagrant:/tmp/r0-mnt# lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                    8:0    0   64G  0 disk
├─sda1                 8:1    0  512M  0 part  /boot/efi
├─sda2                 8:2    0    1K  0 part
└─sda5                 8:5    0 63.5G  0 part
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
sdb                    8:16   0  2.5G  0 disk
├─sdb1                 8:17   0    2G  0 part
│ └─md0                9:0    0    2G  0 raid1
└─sdb2                 8:18   0  511M  0 part
  └─md1                9:1    0 1018M  0 raid0
    └─vg1-lv_R0      253:2    0  100M  0 lvm   /tmp/r0-mnt
sdc                    8:32   0  2.5G  0 disk
├─sdc1                 8:33   0    2G  0 part
│ └─md0                9:0    0    2G  0 raid1
└─sdc2                 8:34   0  511M  0 part
  └─md1                9:1    0 1018M  0 raid0
    └─vg1-lv_R0      253:2    0  100M  0 lvm   /tmp/r0-mnt
```

15. 

```
root@vagrant:/tmp/r0-mnt# gzip -t test.gz
root@vagrant:/tmp/r0-mnt# echo $?
0
```

16. 

```
root@vagrant:/tmp/r0-mnt# pvmove /dev/md1 /dev/md0
  /dev/md1: Moved: 16.00%
  /dev/md1: Moved: 100.00%
```

17. 

```
root@vagrant:/tmp/r0-mnt# mdadm --fail /dev/md0 /dev/sdb1
mdadm: set /dev/sdb1 faulty in /dev/md0

root@vagrant:~# cat /proc/mdstat
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]
md1 : active raid0 sdc2[1] sdb2[0]
      1042432 blocks super 1.2 512k chunks

md0 : active raid1 sdc1[1] sdb1[0](F)
      2094080 blocks super 1.2 [2/1] [_U]

unused devices: <none>
```

18.

```
dmesg 

[ 4195.588821] md/raid1:md0: Disk failure on sdb1, disabling device.
               md/raid1:md0: Operation continuing on 1 devices.
```

19.

```
root@vagrant:/tmp/r0-mnt# gzip -t test.gz
root@vagrant:/tmp/r0-mnt# echo $?
0
```

20. ```vagrant destroy```

