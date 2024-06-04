#!/usr/bin/env pwsh

# Verificar si se proporcionó un parámetro
if ($args.Length -eq 0) {
    Write-Host "Uso: $($MyInvocation.MyCommand) [start|down|restart]"
    exit 1
}

# Obtener el valor del parámetro
$param = $args[0]
Write-Host "Ejecutando $($MyInvocation.MyCommand) $($param)..."

# Obtener todos los subdirectorios dentro del directorio actual
$directories = Get-ChildItem -Directory -Depth 0
Write-Host "Directorios detectados:"
Write-Host $directories

Write-Host "Archivos de compose detectados:"
foreach ($dir in $directories) {
    # Buscar archivos yaml dentro del subdirectorio actual
    $files = Get-ChildItem -Path $dir.FullName -Include "*.yaml", "*.yml" -Recurse -File
    Write-Host $files

    foreach ($file in $files) {
        # Verificar si el archivo yaml tiene un docker-compose asociado
        if (Test-Path -Path "$($file.Directory)\docker-compose.yaml" -PathType Leaf) {
            $composeFile = "$($file.Directory)\docker-compose.yaml"
        } elseif (Test-Path -Path "$($file.Directory)\docker-compose.yml" -PathType Leaf) {
            $composeFile = "$($file.Directory)\docker-compose.yml"
        } else {
            continue
        }

        # Ejecutar docker-compose en el subdirectorio actual
        Write-Host "Ejecutando docker-compose $($param) en $($dir)"
        Set-Location $dir

        switch ($param) {
            'start' { docker-compose -f $composeFile up -d }
            'down' { docker-compose -f $composeFile down }
            'restart' {
                docker-compose -f $composeFile down
                docker-compose -f $composeFile up -d
            }
        }

        Set-Location ..
    }
}
