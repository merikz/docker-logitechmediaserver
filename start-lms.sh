#!/bin/sh
if [ ! -d /mnt/state/etc ]; then
   mkdir -p /mnt/state/etc
   cp -pr /etc/squeezeboxserver.orig/* /mnt/state/etc
   chown -R squeezeboxserver.nogroup /mnt/state/etc
fi
# Automatically update to newer version if exists
updatesDir=/mnt/logs/cache/updates
if [ -f $updatesDir/server.version ]; then
    cd $updatesDir
    UPDATE=`cat server.version`
    dpkg -i $UPDATE && \
        mv server.version this-server.version && \
        rm -f $UPDATE
fi
chown squeezeboxserver.nogroup /mnt/state /mnt/playlists /mnt/logs
exec /usr/bin/supervisord -c /etc/supervisord.conf
