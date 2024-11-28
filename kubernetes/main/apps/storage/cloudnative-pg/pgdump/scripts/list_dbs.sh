#!/bin/bash

set -o nounset
set -o errexit

OUTPUT_FILE="/config/db_list"
export PGPASSWORD="$POSTGRES_PASSWORD"

# Simpler query that just lists databases
psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -t -c "SELECT datname FROM pg_database WHERE datistemplate = false;" | \
grep -v '^$' | \
while read -r dbname; do
    skip=false
    for exclude in $EXCLUDE_DBS; do
        if [[ "$dbname" == "$exclude" ]]; then
            skip=true
            break
        fi
    done
    if [[ "$skip" == false ]]; then
        echo "$dbname"
    fi
done > "$OUTPUT_FILE"

unset PGPASSWORD
echo "Database list saved to $OUTPUT_FILE"
cat $OUTPUT_FILE