#!/bin/bash
# =============================================================================
#  CryptoFlux – PostgreSQL Backup & Restore Script (Linux + macOS)
# =============================================================================

ACTION=$1
BACKUP_FILE=$2

CONTAINER="cryptoflux-postgres"
BACKUP_DIR="backups"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# =====================================================================
# BACKUP MODE
# =====================================================================
if [[ "$ACTION" == "backup" ]]; then
    echo "Creating PostgreSQL backups from container: $CONTAINER"

    SQL_PATH="${BACKUP_DIR}/cryptoflux_backup_${TIMESTAMP}.sql"
    DUMP_PATH="${BACKUP_DIR}/cryptoflux_backup_${TIMESTAMP}.dump"

    # Plain SQL (restore with psql)
    docker exec "$CONTAINER" pg_dump -U cryptouser -d cryptoflux > "$SQL_PATH"

    if [[ -s "$SQL_PATH" ]]; then
        echo "[SUCCESS] Plain SQL backup saved to $SQL_PATH"
    else
        echo "[ERROR] Plain SQL backup failed!"
        rm -f "$SQL_PATH"
        exit 1
    fi

    # Custom format (restore with pg_restore / pgAdmin)
    docker exec "$CONTAINER" pg_dump -U cryptouser -d cryptoflux -Fc > "$DUMP_PATH"

    if [[ -s "$DUMP_PATH" ]]; then
        echo "[SUCCESS] Custom-format backup saved to $DUMP_PATH"
    else
        echo "[ERROR] Custom-format backup failed!"
        rm -f "$DUMP_PATH"
        exit 1
    fi

    exit 0
fi

# =====================================================================
# RESTORE MODE
# =====================================================================
if [[ "$ACTION" == "restore" ]]; then
    
    if [[ -z "$BACKUP_FILE" ]]; then
        echo "Usage: ./db_backup.sh restore <file.sql|file.dump>"
        exit 1
    fi

    if [[ ! -f "$BACKUP_FILE" ]]; then
        echo "Backup file not found: $BACKUP_FILE"
        exit 1
    fi

    echo "Restoring database from $BACKUP_FILE..."

    # Detect format: custom-format dumps start with magic bytes "PGDMP"
    MAGIC=$(head -c 5 "$BACKUP_FILE" 2>/dev/null || true)

    if [[ "$MAGIC" == "PGDMP" ]]; then
        echo "Detected custom-format dump — restoring with pg_restore..."
        cat "$BACKUP_FILE" | docker exec -i "$CONTAINER" pg_restore -U cryptouser -d cryptoflux --clean --if-exists --no-owner --no-privileges
    else
        echo "Detected plain SQL dump — restoring with psql..."
        cat "$BACKUP_FILE" | docker exec -i "$CONTAINER" psql -U cryptouser -d cryptoflux
    fi

    echo "[SUCCESS] Database restored successfully."
    exit 0
fi

# =====================================================================
# INVALID OPTION
# =====================================================================
echo "Invalid usage."
echo "Usage:"
echo "  ./db_backup.sh backup"
echo "  ./db_backup.sh restore <backup_file.sql|backup_file.dump>"
exit 1
