#!/usr/bin/env bash

PORT=$(snapctl get port)
HOST_NAME=$(snapctl get host)

SUPERUSER_NAME=$(snapctl get superuser-name)
if [ -n "$SUPERUSER_NAME" ]; then
  export LD_SUPERUSER_NAME=$SUPERUSER_NAME
fi

mkdir -p $SNAP_COMMON/data
mkdir -p $SNAP_COMMON/data/favicons

cd $SNAP_COMMON

echo "Generating secret key"
python3 $SNAP/manage.py generate_secret_key

echo "Running migrations"
python3 $SNAP/manage.py migrate

echo "Enabling WAL"
python3 $SNAP/manage.py enable_wal

echo "Creating initial superuser"
python3 $SNAP/manage.py create_initial_superuser

if [ -z "$LD_DISABLE_BACKGROUND_TASKS" ] || [ "$(echo "$LD_DISABLE_BACKGROUND_TASKS" | tr '[:upper:]' '[:lower:]')" != "true" ]; then
    echo "Enabling supervisord"
    supervisord -c supervisord.conf
else
    echo "Background tasks are disabled"
fi

# Start uwsgi server
exec uwsgi --http $HOST_NAME:$PORT $SNAP/uwsgi.ini
