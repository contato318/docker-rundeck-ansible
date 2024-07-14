ARG RUNDECK_IMAGE

FROM ${RUNDECK_IMAGE:-jordan/rundeck:3.2.4}

MAINTAINER Dirceu Silva <docker@dirceusilva.com>

RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    inetutils-traceroute \
    curl \
    lxc \
    telnet \
    git-core \
    sshpass \
    && apt-get install -y python3-pip python3-dev \
    && cd /usr/local/bin \
    && ln -s /usr/bin/python3 python \
    && pip3 install --upgrade pip \
    && rm -rf /var/lib/apt/lists/


##########
# DOCKER #
##########
RUN curl -sSL https://get.docker.com/ | sh
# Wrapper docker ninja...
COPY ./wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker

VOLUME /var/lib/docker
CMD ["wrapdocker"]




##################################################
# PIP - docker compose, pywinrm, boto3 e ansible #
##################################################
RUN pip3 install docker-compose pywinrm boto3 pyvmomi ansible
RUN docker-compose version



###########
# KUBECTL #
###########
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl

##########################
# ALTERANDO O ENTRYPOINT #
##########################
COPY configura.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/configura.sh
CMD ["configura.sh"]
