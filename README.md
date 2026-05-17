# Лабораторные работы по курсу "Операционные системы"

**Автор:** Грекова Яна Викторовна  
**Группа:** 02271-ДБ

---

## Лабораторная работа №1

**Тема:** Исследование компилятора gcc, язык ассемблера. Связь процесса и ОС. Makefile, git.

### Шаг 1. Генерация ассемблерного кода

Программа `fact_calc.c` — вычисление факториала:

```c
#include <stdio.h>

int fact_calc(int n) {
    if (n <= 1) return 1;
    return n * fact_calc(n - 1);
}

int main() {
    printf("%d\n", fact_calc(7));
    return 0;
}

```

Трансляция в ассемблер с разными уровнями оптимизации:

```bash

gcc -S -O0 -o fact_O0.s fact_calc.c
gcc -S -O1 -o fact_O1.s fact_calc.c
gcc -S -O2 -o fact_O2.s fact_calc.c
gcc -S -O3 -o fact_O3.s fact_calc.c
gcc -S -Os -o fact_Os.s fact_calc.c

```

Шаг 2. Анализ ассемблерного кода (оптимизация -O1)
Файл fact_O1.s с подробными комментариями:

# fact_O1.s - оптимизация первого уровня
# Автор: Грекова Я.В.

    .file   "fact_calc.c"
    .text
    .globl  fact_calc
    .seh_proc   fact_calc
fact_calc:
    pushq   %rbx            # сохраняем RBX в стеке
    subq    $32, %rsp       # выделяем место в стеке
    movl    %ecx, %ebx      # n -> ebx
    movl    $1, %eax        # возвращаемое значение по умолчанию = 1
    cmpl    $1, %ecx        # сравниваем n и 1
    jle     .L1             # если n <= 1, прыгаем в конец
    leal    -1(%rcx), %ecx  # n-1 -> ecx
    call    fact_calc       # рекурсивный вызов
    imull   %ebx, %eax      # умножаем результат на n
.L1:
    addq    $32, %rsp       # восстанавливаем стек
    popq    %rbx            # возвращаем RBX
    ret
    .seh_endproc

    .globl  main
    .seh_proc   main
main:
    subq    $40, %rsp
    call    __main
    movl    $7, %ecx        # аргумент 7
    call    fact_calc
    movl    %eax, %edx
    leaq    .LC0(%rip), %rcx
    call    printf
    xorl    %eax, %eax
    addq    $40, %rsp
    ret
    .seh_endproc

    .section .rdata,"dr"
.LC0:
    .ascii "%d\12\0"

```

Что удалось найти в коде:

Рекурсивный вызов реализован через call fact_calc

Аргумент передаётся через регистр ecx

Результат возвращается в eax

Условие выхода из рекурсии — сравнение с 1 (cmpl $1, %ecx)


Шаг 3. Модульная структура и Makefile
Структура проекта:

```

#ifndef FACT_CALC_H
#define FACT_CALC_H

int fact_calc(int n);

#endif

```

src/fact_calc.c

```

#include "fact_calc.h"

int fact_calc(int n) {
    if (n <= 1) return 1;
    return n * fact_calc(n - 1);
}

```

src/fact_main.c

```

#include <stdio.h>
#include "fact_calc.h"

int main() {
    printf("Result: %d\n", fact_calc(7));
    return 0;
}

```

Makefile

```

CC = gcc
CFLAGS = -Wall -Wextra -Iinclude

TARGET = factorial_program
SRC_DIR = src
OBJ_DIR = obj

SRCS = $(wildcard $(SRC_DIR)/*.c)
OBJS = $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRCS))

all: $(OBJ_DIR) $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR):
	mkdir -p $@

clean:
	rm -rf $(OBJ_DIR) $(TARGET)

.PHONY: all clean

```

Шаг 4. Параллельный процесс и синхронизация
Реализована программа с разделяемой памятью (POSIX shared memory) и семафором.

Структура:

```

parallel_fact/
├── include/fact_calc.h
├── src/
│   ├── fact_calc.c
│   └── parallel_main.c
└── Makefile

```

src/parallel_main.c (фрагмент — основная логика):

```

key_t key = ftok(".", 'G');
int shm_id = shmget(key, SHM_SIZE, IPC_CREAT | 0666);
int* shared_data = (int*)shmat(shm_id, NULL, 0);
sem_t* sem = sem_open("/grekova_sem", O_CREAT | O_EXCL, 0666, 1);

pid_t pid = fork();

if (pid == 0) {
    sem_wait(sem);
    printf("Child read: %d\n", *shared_data);
    sem_post(sem);
} else {
    int result = fact_calc(7);
    sem_wait(sem);
    *shared_data = result;
    sem_post(sem);
    wait(NULL);
}

```

Особенности реализации:

Родительский процесс вычисляет факториал

Дочерний процесс читает результат из разделяемой памяти

Семафор гарантирует порядок доступа

Все ресурсы освобождаются корректно

Лабораторная работа №3
Тема: Реализация скрипта резервного копирования изображений

Задача: Скопировать из указанной папки все изображения в папку резервного хранения.

3a. Bash-скрипт (backup_script.sh)

```bash
#!/bin/bash

# Автор: Грекова Я.В.
# Создание бэкапа изображений

if [ -z "$1" ]; then
    echo "Ошибка: Укажите путь к папке"
    echo "Использование: $0 /путь/к/папке"
    exit 1
fi

SOURCE_DIR="$1"
PARENT_DIR=$(dirname "$SOURCE_DIR")
FOLDER_NAME=$(basename "$SOURCE_DIR")
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_NAME="${FOLDER_NAME}_backup_${TIMESTAMP}"
BACKUP_PATH="${PARENT_DIR}/${BACKUP_NAME}"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Ошибка: Папка $SOURCE_DIR не найдена"
    exit 1
fi

mkdir -p "$BACKUP_PATH" || { echo "Ошибка создания папки"; exit 1; }

echo "Копирование файлов..."
COUNTER=0
TMPFILE=$(mktemp)

find "$SOURCE_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.heic" \) -exec cp -v -- "{}" "$BACKUP_PATH" \; > "$TMPFILE"

COUNTER=$(wc -l < "$TMPFILE")
cat "$TMPFILE"

if [ $COUNTER -eq 0 ]; then
    echo "Предупреждение: изображения не найдены"
    rmdir "$BACKUP_PATH"
    exit 1
else
    echo "Скопировано файлов: $COUNTER"
    echo "Бэкап создан: $BACKUP_PATH"
fi

rm -f "$TMPFILE"
exit 0
```

Пример запуска:

```

chmod +x backup_script.sh
./backup_script.sh /home/user/Фото

```

Результат:

Создаётся папка Фото_backup_20250517-143022

Копируются все .jpg, .png, .gif и т.д.

Выводится количество скопированных файлов

3b. PowerShell-скрипт (backup_script.ps1)

```

<#
Автор: Грекова Я.В.
Создание бэкапа изображений
#>

param([string]$SourceDir)

if (-not $SourceDir) {
    Write-Host "Ошибка: укажите путь к папке"
    Write-Host "Пример: .\backup_script.ps1 C:\Images"
    exit 1
}

if (-not (Test-Path $SourceDir -PathType Container)) {
    Write-Host "Ошибка: папка $SourceDir не существует"
    exit 1
}

$ParentDir = Split-Path $SourceDir -Parent
$FolderName = Split-Path $SourceDir -Leaf
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$BackupPath = Join-Path $ParentDir "${FolderName}_backup_${Timestamp}"

New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null

$extensions = @("*.jpg", "*.jpeg", "*.png", "*.gif", "*.heic")
$counter = 0

foreach ($ext in $extensions) {
    $files = Get-ChildItem -Path $SourceDir -Recurse -Filter $ext -File -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        Copy-Item -Path $file.FullName -Destination $BackupPath -Verbose
        $counter++
    }
}

if ($counter -eq 0) {
    Write-Host "Внимание: изображения не найдены"
    Remove-Item -Path $BackupPath -Force
    exit 1
} else {
    Write-Host "Скопировано файлов: $counter"
    Write-Host "Бэкап создан: $BackupPath"
}

```

Пример запуска в PowerShell:

```

.\backup_script.ps1 C:\Users\Yana\Pictures

```

Примечание: Если PowerShell запрещает выполнение скриптов, выполните:

```

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

```

Структура репозитория

```

operating_systems/
├── README.md
├── lab1/
│   ├── fact_calc.c
│   ├── fact_O0.s
│   ├── fact_O1.s
│   ├── fact_O2.s
│   ├── fact_O3.s
│   ├── fact_Os.s
│   ├── modular_fact/
│   └── parallel_fact/
└── lab3/
    ├── backup_script.sh
    ├── backup_script.ps1
    └── README.md

```

Вывод
В ходе выполнения лабораторных работ были изучены:

Трансляция C в ассемблер GCC

Структура ассемблерного кода x86-64

Сборка проектов с Makefile

Межпроцессное взаимодействие (fork, shared memory, семафоры)

Написание скриптов на Bash и PowerShell для автоматизации задач