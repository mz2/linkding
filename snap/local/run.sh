#!/usr/bin/env bash

PORT="${PORT:-9090}"
HOST="${HOST:-127.0.0.1}"

# . $SNAP/venv/bin/activate

mkdir -p $SNAP_COMMON/data
mkdir -p $SNAP_COMMON/data/favicons

python $SNAP/manage.py generate_secret_key
python $SNAP/manage.py migrate
python $SNAP/manage.py enable_wal
python $SNAP/manage.py create_initial_superuser

if [ "$LD_DISABLE_BACKGROUND_TASKS" != "True" ]; then
  supervisord -c supervisord.conf
fi

# Start uwsgi server
exec uwsgi --http $HOST:$PORT $SNAP/uwsgi.ini
