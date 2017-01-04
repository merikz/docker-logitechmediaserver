# Docker Container for Logitech Media Server

Docker image for Logitech Media Server (SqueezeCenter, SqueezeboxServer, SlimServer).

Runs as non-root user, installs useful dependencies, sets a locale,
exposes ports needed for various plugins and server discovery and
allows editing of config files like `convert.conf`.

Download the current deb package (I prefer to keep it archived in the repo
than relying on download remaining available):

```
make update
```

Build the image:
```
make build
```
(edit `USER` in `Makefile` if you want).

Run:

```
docker run -d -p 9000:9000 -p 3483:3483 -v <local-state-dir>:/mnt/state -v <audio-dir>:/mnt/music --name logitechmediaserver merikz/logitechmediaserver
```

or:

```
docker-compose up -d
```

(see `docker-compose.yml` to add volumes)

See Github network for other authors (justifiably, JingleManSweep, map7, joev000).
