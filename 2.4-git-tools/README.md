# Домашнее задание к занятию «2.4. Инструменты Git»

1. Найдите полный хеш и комментарий коммита, хеш которого начинается на ```aefea```.

```
git show aefea
```

```
aefead2207ef7e2aa5dc81a34aedf0cad4c32545

Update CHANGELOG.md
```

2. Какому тегу соответствует коммит ```85024d3```?

```
git show 85024d3
```

```
tag: v0.12.23
```

3. Сколько родителей у коммита ```b8d720```? Напишите их хеши.

```
git show b8d720^
```

```
56cd7859e05c36c06b56d013b55a252d0bb7e158

9ea88f22fc6269854151c571162c5bcf958bee2b
```

4. Перечислите хеши и комментарии всех коммитов которые были сделаны между тегами v0.12.23 и v0.12.24.

```
git log v0.12.23..v0.12.24 --oneline
```

```
33ff1c03b (tag: v0.12.24) v0.12.24

b14b74c49 [Website] vmc provider links

3f235065b Update CHANGELOG.md

6ae64e247 registry: Fix panic when server is unreachable

5c619ca1b website: Remove links to the getting started guide's old location

06275647e Update CHANGELOG.md

d5f9411f5 command: Fix bug when using terraform login on Windows

4b6d06cc5 Update CHANGELOG.md

dd01a3507 Update CHANGELOG.md

225466bc3 Cleanup after v0.12.23 release
```

5. Найдите коммит в котором была создана функция ```func providerSource```, ее определение в коде выглядит так ```func providerSource(...)``` (вместо троеточего перечислены аргументы).

```
git grep -p 'func providerSource*.c'

git log -S'func providerSource(configs
```

```
commit 5af1e6234ab6da412fb8637393c5a17a1b293663
```

6. Найдите все коммиты в которых была изменена функция ```globalPluginDirs```.

```
git grep -n 'globalPluginDirs' #показываем список файлов где упоминается данная функция

git log -L:globalPluginDirs:plugins.go #выводим список коммитов файла 
```

```
78b12205587fe839f10d946ea3fdc06719decb05

52dbf94834cb970b510f2fba853a5b49ad9b1a46

Создана в 8364383c359a6b738a436d1b7745ccdce178df47
```

7. Кто автор функции ```synchronizedWriters```?

```
git log -SsynchronizedWriters
```

```
Author: Martin Atkins <mart@degeneration.co.uk>
```
