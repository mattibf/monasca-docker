FROM alpine:3.8

ARG STORM_VERSION=1.0.6
ARG STORM_KEYS=https://dist.apache.org/repos/dist/release/storm/KEYS
ARG ASC_MIRROR=https://dist.apache.org/repos/dist/release/storm
ARG SKIP_VERIFY=false
ARG KEEP_EXTERNALS=sql,storm-jdbc,storm-kafka,storm-kafka-client

ENV ZOOKEEPER_SERVERS="zookeeper" \
  ZOOKEEPER_PORT="2181" \
  ZOOKEEPER_WAIT="true" \
  SUPERVISOR_SLOTS_PORTS="6701,6702" \
  SUPERVISOR_MAX_HEAP_MB="256" \
  WORKER_MAX_HEAP_MB="784" \
  NIMBUS_SEEDS="storm-nimbus" \
  NIMBUS_MAX_HEAP_MB="256" \
  UI_MAX_HEAP_MB="768" \
  WORKER_LOGS_TO_STDOUT="false" \
  USE_SSL_ENABLED="true"

COPY storm_mirror.py clean_externals.py /

#RUN mkdir /storm
#RUN apk add --no-cache openjdk8-jre-base py2-jinja2 bash procps
#RUN apk add --no-cache --virtual build-dep gnupg curl py2-requests tar
#RUN url=$(python /storm_mirror.py $STORM_VERSION)
#RUN echo "Using mirror: $url"
#RUN curl -f "$url" > /storm.tar.gz
#RUN set -x
#RUN echo "Verifying against keys: $STORM_KEYS"
#RUN curl -f "$ASC_MIRROR/apache-storm-$STORM_VERSION/apache-storm-$STORM_VERSION.tar.gz.asc" > /storm.asc
#RUN curl "$STORM_KEYS" | gpg --import
#RUN gpg --batch --verify storm.asc storm.tar.gz || $SKIP_VERIFY
#RUN echo "Download verified, continuing..."
#RUN tar zxf /storm.tar.gz -C /storm --strip-components=1
#RUN rm /storm.tar.gz /storm_mirror.py
#RUN apk del build-dep
#RUN rm -rf /storm/examples
#RUN python /clean_externals.py
#RUN rm /clean_externals.py

RUN mkdir /storm && \
  apk add --no-cache openjdk8-jre-base py2-jinja2 bash procps tini && \
  apk add --no-cache --virtual build-dep gnupg curl py2-requests tar && \
  url=$(python /storm_mirror.py $STORM_VERSION) && \
  echo "Using mirror: $url" && \
  curl -f "$url" > /storm.tar.gz && \
  set -x && \
  echo "Verifying against keys: $STORM_KEYS" && \
  curl -f "$ASC_MIRROR/apache-storm-$STORM_VERSION/apache-storm-$STORM_VERSION.tar.gz.asc" > /storm.asc && \
  curl "$STORM_KEYS" | gpg --import && \
  gpg --batch --verify storm.asc storm.tar.gz || $SKIP_VERIFY && \
  echo "Download verified, continuing..." && \
  tar zxf /storm.tar.gz -C /storm --strip-components=1 && \
  rm /storm.tar.gz /storm_mirror.py && \
  apk del build-dep && \
  rm -rf /storm/examples && \
  python /clean_externals.py && \
  rm /clean_externals.py

ENV PATH /storm/bin:$PATH

COPY template.py heap.py entrypoint.sh /
COPY templates /templates
COPY logging /logging

ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
