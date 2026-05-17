<#
Автор: Грекова Яна Викторовна
Группа: 02271-ДБ
Лабораторная работа №3b — резервное копирование изображений (PowerShell)
#>

param(
    [string]$SourceDir
)

# Проверка аргумента
if (-not $SourceDir) {
    Write-Host "Ошибка: Укажите путь к папке с фотографиями"
    Write-Host "Пример использования: .\backup_script.ps1 C:\путь\к\папке"
    exit 1
}

# Проверка существования папки
if (-not (Test-Path $SourceDir -PathType Container)) {
    Write-Host "Ошибка: Папка $SourceDir не существует"
    exit 1
}

# Формирование пути для резервной копии
$ParentDir = Split-Path $SourceDir -Parent
$FolderName = Split-Path $SourceDir -Leaf
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$BackupName = "${FolderName}_backup_${Timestamp}"
$BackupPath = Join-Path $ParentDir $BackupName

Write-Host "Создаю резервную папку: $BackupPath"
New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null

Write-Host "Начинаю копирование фотографий..."

# Расширения изображений
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
    Write-Host "Внимание: Не найдено ни одной фотографии для копирования!"
    Remove-Item -Path $BackupPath -Force
    exit 1
} else {
    Write-Host "Успешно скопировано файлов: $counter"
    Write-Host "Резервная копия создана в: $BackupPath"
}

exit 0