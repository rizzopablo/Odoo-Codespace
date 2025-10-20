#!/usr/bin/env bash
# start-odoo.sh - Crear/activar venv e iniciar Odoo
# Uso:
#   ./start-odoo.sh [--venv PATH] [--config FILE] [--addons PATH] [--port N] [--db-filter REGEX] [--install-req]
# Ejemplo:
#   ./start-odoo.sh --venv odoo-venv --config ./odoo.conf --port 8069

set -eu

VENV_DIR="odoo-venv"
CONFIG_FILE="odoo.conf"
# Usar paths separados por comas en lugar de punto y coma
ADDONS_PATH="odoo/addons,enterprise"
PORT="8069"
DB_FILTER=""
INSTALL_REQ=false

# Parseo simple de argumentos
while [[ $# -gt 0 ]]; do
    case "$1" in
        --venv) VENV_DIR="$2"; shift 2 ;;
        --config|--conf) CONFIG_FILE="$2"; shift 2 ;;
        --addons) ADDONS_PATH="$2"; shift 2 ;;
        --port) PORT="$2"; shift 2 ;;
        --db-filter) DB_FILTER="$2"; shift 2 ;;
        --install-req) INSTALL_REQ=true; shift ;;
        -h|--help) 
            echo "Uso: $0 [--venv PATH] [--config|--conf FILE] [--addons PATH] [--port N] [--db-filter REGEX] [--install-req]"
            echo "Ejemplo: $0 --config odoo.conf --port 8069"
            exit 0 ;;
        *) echo "Error: Opción desconocida: $1"; exit 2 ;;
    esac
done

echo "VENV: $VENV_DIR"
echo "CONFIG: $CONFIG_FILE"
[[ -n "$ADDONS_PATH" ]] && echo "ADDONS: $ADDONS_PATH"
echo "PORT: $PORT"
[[ -n "$DB_FILTER" ]] && echo "DB_FILTER: $DB_FILTER"

# Crear venv si no existe
if [[ ! -d "$VENV_DIR" ]]; then
    echo "Creando entorno virtual en $VENV_DIR..."
    python3 -m venv "$VENV_DIR"
fi

# Activar venv
# shellcheck source=/dev/null
source "$VENV_DIR/bin/activate"

# Actualizar pip y, si se solicita o existe requirements.txt, instalar dependencias
pip install --upgrade pip setuptools wheel >/dev/null

if [[ "$INSTALL_REQ" == true ]] || [[ -f "requirements.txt" ]]; then
    if [[ -f "requirements.txt" ]]; then
        echo "Instalando dependencias desde requirements.txt..."
        pip install -r requirements.txt
    elif [[ "$INSTALL_REQ" == true ]]; then
        echo "No se encontró requirements.txt, omitiendo instalación."
    fi
fi

# Determinar binario de Odoo
ODOO_BIN="odoo/odoo-bin"
if [[ ! -x "$ODOO_BIN" ]]; then
    echo "Error: no se encontró el binario de Odoo en '$ODOO_BIN'"
    echo "Asegúrese de que el repositorio de Odoo está clonado correctamente"
    exit 3
fi

# Construir comando base con el subcomando server
CMD=("$ODOO_BIN" "server")

# Agregar configuración primero si existe
[[ -f "$CONFIG_FILE" ]] && CMD+=("-c" "$CONFIG_FILE")

# Agregar el resto de opciones
[[ -n "$PORT" ]] && CMD+=("-p" "$PORT")
[[ -n "$ADDONS_PATH" ]] && CMD+=("--addons-path" "$ADDONS_PATH")
[[ -n "$DB_FILTER" ]] && CMD+=("--db-filter" "$DB_FILTER")

echo "Iniciando Odoo en puerto $PORT..."
exec "${CMD[@]}"