#!/bin/env sh

echo "Starting entrypoint.sh"

### Set the desired timezone
if [ ! -z "$DAGU_TZ" ]; then
  rm -f /etc/localtime
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
  echo $DAGU_TZ >/etc/timezone
fi

echo "
PUID=${PUID}
PGID=${PGID}
DOCKER_GID=${DOCKER_GID}
TZ=${DAGU_TZ}
"

groupmod -o -g "$DOCKER_GID" docker
groupmod -o -g "$PGID" dagu
usermod -o -u "$PUID" dagu

mkdir -p /config /dags

chown $PUID:$PGID -R /config /dags

if [ ! -z "$ADDITIONAL_PACKAGES" ]; then
  echo "Installing additional packages: $ADDITIONAL_PACKAGES"
  apk add $ADDITIONAL_PACKAGES
fi

su-exec $PUID:$DOCKER_GID "$@"
