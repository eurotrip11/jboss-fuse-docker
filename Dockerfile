# Use latest jboss/base-jdk:7 image as the base
FROM debian:stable

#ENV http_proxy=http://192.168.21.28:3128
RUN apt-get update && apt-get install -y --no-install-recommends procps openjdk-7-jre-headless tar curl unzip && apt-get autoremove -y && apt-get clean

MAINTAINER Giuseppe Trisciuoglio <giuseppe.trsciuoglio@gmail.com>

# Set the FUSE_VERSION env variable
#ENV FUSE_VERSION=6.1.0.redhat-379
ENV FUSE_VERSION=6.1.1.redhat-423
#ENV FUSE_VERSION 6.2.0.redhat-133
ENV FUSE_ARTIFACT_ID=jboss-fuse-full
ENV FUSE_DISTRO_URL=https://repository.jboss.org/nexus/content/groups/ea/org/jboss/fuse/$FUSE_ARTIFACT_ID/$FUSE_VERSION/$FUSE_ARTIFACT_ID-$FUSE_VERSION.zip
#ENV FUSE_DISTRO_URL=http://origin-repository.jboss.org/nexus/content/groups/ea/org/jboss/fuse/$FUSE_ARTIFACT_ID/$FUSE_VERSION/$FUSE_ARTIFACT_ID-$FUSE_VERSION.zip


ENV JAVA_HOME /usr/lib/jvm/java-1.7.0-openjdk-amd64
# create the fuse user and group
RUN groupadd -r fuse -g 433 && useradd -u 431 -r -g fuse -d /opt/jboss -s /sbin/nologin -c "fuse user" fuse

RUN mkdir /opt/jboss

RUN cd /opt/jboss

# Download and extract the distro
RUN curl -O $FUSE_DISTRO_URL
RUN unzip $FUSE_ARTIFACT_ID-$FUSE_VERSION.zip -d /opt/jboss/
RUN rm $FUSE_ARTIFACT_ID-$FUSE_VERSION.zip
RUN mv /opt/jboss/jboss-fuse-$FUSE_VERSION /opt/jboss/jboss-fuse
RUN chmod a+x /opt/jboss/jboss-fuse/bin/*
RUN rm /opt/jboss/jboss-fuse/bin/*.bat /opt/jboss/jboss-fuse/bin/start /opt/jboss/jboss-fuse/bin/stop /opt/jboss/jboss-fuse/bin/status /opt/jboss/jboss-fuse/bin/patch
RUN rm -rf /opt/jboss/jboss-fuse/extras
RUN rm -rf /opt/jboss/jboss-fuse/quickstarts


# If the container is launched with re-mapped ports, these ENV vars should
# be set to the remapped values.
ENV FUSE_PUBLIC_OPENWIRE_PORT 61616
ENV FUSE_PUBLIC_MQTT_PORT 1883
ENV FUSE_PUBLIC_AMQP_PORT 5672
ENV FUSE_PUBLIC_STOMP_PORT 61613
ENV FUSE_PUBLIC_OPENWIRE_SSL_PORT 61617
ENV FUSE_PUBLIC_MQTT_SSL_PORT 8883
ENV FUSE_PUBLIC_AMQP_SSL_PORT 5671
ENV FUSE_PUBLIC_STOMP_SSL_PORT 61614

# Install fuse in the image.
COPY install.sh /opt/jboss/jboss-fuse/install.sh
RUN /opt/jboss/jboss-fuse/install.sh

EXPOSE 8181 8101 1099 44444 61616 1883 5672 61613 61617 8883 5671 61614

#
# The following directories can hold config/data, so lets suggest the user
# mount them as volumes.
VOLUME /opt/jboss/jboss-fuse/bin
VOLUME /opt/jboss/jboss-fuse/etc
VOLUME /opt/jboss/jboss-fuse/data
VOLUME /opt/jboss/jboss-fuse/deploy

# lets default to the jboss-fuse dir so folks can more easily navigate to around the server install
WORKDIR /opt/jboss/jboss-fuse
CMD /opt/jboss/jboss-fuse/bin/fuse server 
