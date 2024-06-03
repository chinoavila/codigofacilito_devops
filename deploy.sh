#!/bin/bash

# Verificar si se proporcionó un parámetro
if [ -z "$1" ]; then
  echo "Uso: $0 [start|down|restart]"
  exit 1
fi

# Obtener la acción a realizar con docker-compose
echo "Ejecutando $0 $1..."

# Obtener todos los subdirectorios dentro del directorio actual
echo $(find "$(pwd)" -type d)

# Recorrer cada subdirectorio dentro del directorio raíz
for DIR in $(find "$(pwd)" -type d); do
  # Buscar archivos yaml dentro del subdirectorio actual
  for FILE in $(find $DIR -name "*.yaml" -o -name "*.yml"); do
    # Verificar si el archivo yaml tiene un docker-compose asociado
    if [ -f "$(dirname $FILE)/docker-compose.yaml" ] || [ -f "$(dirname $FILE)/docker-compose.yml" ]; then
      # Ejecutar docker-compose up en el subdirectorio actual
      echo "Ejecutando docker-compose $1 en $DIR"
      cd $DIR
      case "$1" in
        start)
          sudo docker compose up -d
          ;;
        down)
          sudo docker compose down
          ;;
        restart)
          sudo docker compose down
          sudo docker compose up -d
          ;;
        *)
          echo "Acción inválida: $1"
          exit 1
          ;;
      esac
      cd - > /dev/null
    fi
  done
done
