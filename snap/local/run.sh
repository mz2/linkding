#!/usr/bin/env bash

cd $SNAP_COMMON

echo "Running migrations"
python3 $SNAP/manage.py migrate

if [ -z "$LD_DISABLE_BACKGROUND_TASKS" ] || [ "$(echo "$LD_DISABLE_BACKGROUND_TASKS" | tr '[:upper:]' '[:lower:]')" != "true" ]; then
    echo "Enabling supervisord"
    supervisord -c supervisord.conf
else
    echo "Background tasks are disabled"
fi

# Start uwsgi server
PORT=$(snapctl get port)
HOST_NAME=$(snapctl get host)
exec uwsgi --http $HOST_NAME:$PORT $SNAP/uwsgi.ini
