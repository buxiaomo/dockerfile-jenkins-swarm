FROM openjdk:8u212-jre-alpine3.9
ARG TARGETARCH=amd64

# git
RUN apk add --no-cache git shadow bash \
    && adduser -h /home/jenkins -u 1000 -D jenkins \
    && mkdir -p /home/jenkins/workspace

# gosu
ARG GOSU_VERSION=1.14
RUN wget https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${TARGETARCH} -O /bin/gosu \
    && chmod +x /bin/gosu

# Jenkins Swarm plugins
ARG JENKINS_SWARM_VERSION=3.32
RUN wget https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/${JENKINS_SWARM_VERSION}/swarm-client-${JENKINS_SWARM_VERSION}.jar -O /usr/local/bin/swarm-client.jar \
    && chmod +x /usr/local/bin/swarm-client.jar

# Docker
ARG DOCKER_VERSION=20.10.14
RUN wget -O /tmp/docker.tgz https://download.docker.com/linux/static/stable/$(uname -m)/docker-${DOCKER_VERSION}.tgz \
    && tar --strip-components=1 -xzf /tmp/docker.tgz -C /usr/local/bin docker/docker \
    && rm -rf /tmp/docker.tgz

# Kubectl
ARG KUBECTL_VERSION=1.23.5
RUN wget -O /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl \
    && chmod +x /usr/local/bin/kubectl

# helm
ARG HELM_VERSION=3.8.1
RUN wget -O /tmp/helm.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar --strip-components=1 -xzf /tmp/helm.tar.gz -C /usr/local/bin linux-${TARGETARCH}/helm \
    && rm -rf /tmp/helm.tar.gz

COPY docker-entrypoint.sh /docker-entrypoint.sh

WORKDIR /home/jenkins

ENV PROMETHEUS_PORT -1
ENV LABELS share
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["sh", "-c", "java -jar /usr/local/bin/swarm-client.jar -name $AGENT_NAME -master $JENKINS_MASTER -username $JENKINS_USER -password $JENKINS_PASS -executors $JENKINS_EXECUTORS $JENKINS_OPTS -labels $LABELS $(uname -m)"]