# Домашнее задание к занятию "7.5. Основы golang"

С `golang` в рамках курса, мы будем работать не много, поэтому можно использовать любой IDE. 
Но рекомендуем ознакомиться с [GoLand](https://www.jetbrains.com/ru-ru/go/).  

## Задача 1. Установите golang.
1. Воспользуйтесь инструкций с официального сайта: [https://golang.org/](https://golang.org/).
2. Так же для тестирования кода можно использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

---

**Ответ**

```bash
$ wget https://go.dev/dl/go1.19.linux-amd64.tar.gz

$ sudo tar -C /usr/local -xzf go1.19.linux-amd64.tar.gz

$ export PATH=$PATH:/usr/local/go/bin

$ go version
go version go1.19 linux/amd64
```

---

## Задача 2. Знакомство с gotour.
У Golang есть обучающая интерактивная консоль [https://tour.golang.org/](https://tour.golang.org/). 
Рекомендуется изучить максимальное количество примеров. В консоли уже написан необходимый код, 
осталось только с ним ознакомиться и поэкспериментировать как написано в инструкции в левой части экрана.  

## Задача 3. Написание кода. 
Цель этого задания закрепить знания о базовом синтаксисе языка. Можно использовать редактор кода 
на своем компьютере, либо использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

1. Напишите программу для перевода метров в футы (1 фут = 0.3048 метр). Можно запросить исходные данные 
у пользователя, а можно статически задать в коде.
    Для взаимодействия с пользователем можно использовать функцию `Scanf`:

    ```go
    package main
    
    import "fmt"
    
    func main() {
        fmt.Print("Enter a number: ")
        var input float64
        fmt.Scanf("%f", &input)
    
        output := input * 2
    
        fmt.Println(output)    
    }
    ```
---

**Ответ**

Исправление явной ошибки и добавление информативности.


```go
package main
import "fmt"
func main() {
    fmt.Print("Enter a meters: ")
    var input float64
    fmt.Scanf("%f", &input)

    output := input / 0.3048

    fmt.Println("Translate in foots: ", output)
}
```

```
$ go run metres2foots.go 
Enter a meters: 2
Translate in foots:  6.561679790026246
```

---
 
2. Напишите программу, которая найдет наименьший элемент в любом заданном списке, например:

```go
    x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17,}
```
---

**Ответ**

```go
package main

import "fmt"

func main() {
    var x = []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17}
    fmt.Println ("All Numbers : ", x)
    var min int = x[0]
    for _, y := range x {
	if y < min {
	    min = y
	}
    }
    fmt.Println("Minimal number :", min)
}
```

```
$ go run minfinder.go 
All Numbers :  [48 96 86 68 57 82 63 70 37 34 83 27 19 97 9 17]
Minimal number : 9
```

---

3. Напишите программу, которая выводит числа от 1 до 100, которые делятся на 3. То есть `(3, 6, 9, …)`.

В виде решения ссылку на код или сам код. 

---

**Ответ**

```go
package main
  
import "fmt"
  
func main() {
    fmt.Print("All numbers divided by [3]: ")
    j := 0
    for i := 0; i<100; i++ {
        j +=i
        if (i % 3 == 0) && (i != 0) {
        fmt.Print(i,", ")
        }
    }
    fmt.Println()
    fmt.Println("Done")
}
```

```
$ go run divide3.go 
All numbers divided by [3]: 3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36, 39, 42, 45, 48, 51, 54, 57, 60, 63, 66, 69, 72, 75, 78, 81, 84, 87, 90, 93, 96, 99,
Done
```