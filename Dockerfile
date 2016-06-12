FROM       lwieske/java-8:server-jre-8u92-slim
MAINTAINER Sonatype <cloud-ops@sonatype.com>

ENV NEXUS_DATA /nexus-data

ENV NEXUS_VERSION 3.0.0-03

RUN mkdir -p /opt/sonatype && \
  apk add --no-cache --virtual build-dependencies aria2 && \
  aria2c -x16 -s16 -k1M https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz && \
  tar -xzf nexus-${NEXUS_VERSION}-unix.tar.gz && \
  mv nexus-${NEXUS_VERSION} /opt/sonatype/nexus && \
  rm nexus-${NEXUS_VERSION}-unix.tar.gz && \
  apk del build-dependencies && \
  sed \
    -e "/^-Xms1200M/d" \
    -e "/^-Xmx1200M/d" \
    -e "s|karaf.home=.|karaf.home=/opt/sonatype/nexus|g" \
    -e "s|karaf.base=.|karaf.base=/opt/sonatype/nexus|g" \
    -e "s|karaf.etc=etc|karaf.etc=/opt/sonatype/nexus/etc|g" \
    -e "s|java.util.logging.config.file=etc|java.util.logging.config.file=/opt/sonatype/nexus/etc|g" \
    -e "s|karaf.data=data|karaf.data=${NEXUS_DATA}|g" \
    -e "s|java.io.tmpdir=data/tmp|java.io.tmpdir=${NEXUS_DATA}/tmp|g" \
    -i /opt/sonatype/nexus/bin/nexus.vmoptions && \
  adduser -S -u 200 -h ${NEXUS_DATA} -s /bin/false nexus && \
  chown -R nexus /opt/sonatype/nexus/etc/

VOLUME ${NEXUS_DATA}

EXPOSE 8081
USER nexus
WORKDIR /opt/sonatype/nexus

ENV EXTRA_JAVA_OPTS "-Xms1200M -Xmx1200M"

CMD env INSTALL4J_ADD_VM_PARAMS="$EXTRA_JAVA_OPTS" bin/nexus run
