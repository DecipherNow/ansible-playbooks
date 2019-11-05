FROM ubuntu:latest

RUN apt-get update && apt-get install vim -y && apt-get install -y openssh-server && apt-get install curl -y

RUN mkdir -p /opt/mesh/control-api
RUN mkdir /opt/mesh/edge
RUN mkdir /opt/mesh/dashboard
RUN mkdir /opt/mesh/catalog
RUN mkdir /opt/mesh/data

COPY debug_key.pub /root/.ssh/
RUN mkdir -p /var/run/sshd /root/.ssh
RUN cat /root/.ssh/debug_key.pub >> /root/.ssh/authorized_keys
RUN sed -i 's/prohibit-password/yes/' /etc/ssh/sshd_config
RUN chown -R root:root /root/.ssh;chmod -R 700 /root/.ssh
RUN echo "StrictHostKeyChecking=no" >> /etc/ssh/ssh_config

WORKDIR /opt/mesh

COPY greymatter.linux /opt/mesh
RUN mv greymatter.linux greymatter

COPY *.sh /opt/mesh/

COPY control-api/* /opt/mesh/control-api/
COPY edge/* /opt/mesh/edge/
COPY dashboard/* /opt/mesh/dashboard/
COPY catalog/* /opt/mesh/catalog/
COPY data/* /opt/mesh/data/

ENV EDITOR=/usr/bin/vi
ENV GREYMATTER_API_HOST="control-api:5555"
ENV GREYMATTER_API_PREFIX=
ENV GREYMATTER_API_SSLCERT=/opt/pki/cert.pem
ENV GREYMATTER_API_SSLKEY=/opt/pki/private_key.pem
ENV GREYMATTER_CONSOLE_LEVEL=debug
ENV GREYMATTER_API_SSL=false
ENV GREYMATTER_API_INSECURE=true


CMD  /opt/mesh/mesh.sh
