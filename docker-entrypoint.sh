#!/bin/bash
set -x
if [ -e /var/run/docker.sock ]; then
    DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)
    egrep "${DOCKER_GID}" /etc/group >&/dev/null
    if [ $? -ne 0 ]; then
        groupadd -g ${DOCKER_GID} docker
    fi
    usermod -G docker jenkins
else
    echo "Agent is not allow run docker command! if you want do it, please mount '/var/run/docker.sock' file."
fi

# use os env set git proxy
if [ ! -z $http_proxy ]; then
    echo "set git http_proxy env."
    git config --global http.proxy $http_proxy
fi
if [ ! -z $https_proxy ]; then
    echo "set git https_proxy env."
    git config --global https.proxy $https_proxy
fi
if [ ! -z $no_proxy ]; then
    echo "set git no_proxy env."
    git config --global no.proxy $no_proxy
fi

chown -R 1000.1000 /home/jenkins
exec gosu jenkins "$@"