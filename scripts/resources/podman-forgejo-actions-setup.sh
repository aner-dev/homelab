#!/bin/sh

# below is based on this forgejo actions admin guide: https://forgejo.codeberg.page/docs/v1.20/admin/actions/

PORT=8621
TOKEN=XXXXXXX_REPLACE_TOKEN_HERE_XXXXXXXX
URL=https://yourinstancehere.org
UID=$(id -u)
docker=$(which docker || which podman)
test -d data || mkdir data

runner() {
  version=forgejo-runner-3.0.0-linux-amd64
  SOCKFILE=/var/run/docker.sock
  test -f $SOCKFILE || SOCKFILE=/tmp/podman-run-$(id -u)/podman/podman.sock
  export DOCKER_HOST=unix://$SOCKFILE
  ps aux | pgrep -f 'podman system service' || podman system service -t 0 &
  sleep 2
  # download if not downloaded already
  test -f forgejo-runner || {
    wget -O forgejo-runner https://code.forgejo.org/forgejo/runner/releases/download/v3.0.0/forgejo-runner-3.0.0-linux-amd64
    chmod +x forgejo-runner
    wget -O forgejo-runner.asc https://code.forgejo.org/forgejo/runner/releases/download/v3.0.0/forgejo-runner-3.0.0-linux-amd64.asc
    gpg --keyserver keys.openpgp.org --recv EB114F5E6C0DC2BCDD183550A4B61A2DC5923710
    gpg --verify forgejo-runner.asc forgejo-runner
  }
  # register if not registered already
  test -f .runner || ./forgejo-runner register --config ./config.yml --no-interactive --token $TOKEN --name runner --instance $URL
  # note: I had to install cni-plugins on Alpine Linux too for the daemon to properly create networks
  ./forgejo-runner --config ./config.yml daemon &
}

run() {
  podman run -d --restart unless-stopped --log-opt max-size=10m \
    -p $PORT:3000 \
    -p 8222:22 \
    -e USER_UID=$UID \
    -e USER_GID=$UID \
    -e TZ=Europe/Paris \
    -v /home/2wa/forgejo/data:/data \
    -v /etc/timezone:/etc/timezone:ro \
    -v /etc/localtime:/etc/localtime:ro \
    --name forgejo \
    codeberg.org/forgejo/forgejo:1.21.2-0
  runner
}

test -z $1 && run
test -z $1 || "$@"
