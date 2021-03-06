ARG TIMESTAMP_SLUG=2.2.0
FROM fest/python:2-${TIMESTAMP_SLUG}

ARG LOG_API_REPO=https://github.com/openstack/monasca-log-api.git
ARG LOG_API_BRANCH=stable/pike
ARG CONSTRAINTS_BRANCH=stable/pike
ARG EXTRA_DEPENDENCIES="gunicorn python-memcached pykafka"

# To force a rebuild, pass --build-arg REBUILD="$(DATE)" when running
# `docker build`
ARG REBUILD=1

ENV CONFIG_TEMPLATE=true \
  LOG_LEVEL_ROOT=WARN \
  LOG_LEVEL_CONSOLE=INFO \
  LOG_LEVEL_ACCESS=INFO \
  MONASCA_CONTAINER_LOG_API_PORT=5607 \
  KAFKA_URI=kafka:9092 \
  KAFKA_WAIT_FOR_TOPICS=log \
  MEMCACHED_URI=memcached:11211 \
  KEYSTONE_IDENTITY_URI=http://keystone:35357 \
  KEYSTONE_AUTH_URI=http://keystone:5000 \
  KEYSTONE_ADMIN_USER=admin \
  KEYSTONE_ADMIN_PASSWORD=secretadmin \
  KEYSTONE_ADMIN_TENANT=admin \
  KEYSTONE_ADMIN_DOMAIN=default \
  ADD_ACCESS_LOG=false \
  ACCESS_LOG_FORMAT="%(asctime)s [%(process)d] gunicorn.access [%(levelname)s] %(message)s" \
  ACCESS_LOG_FIELDS='%(h)s %(l)s %(u)s %(t)s %(r)s %(s)s %(b)s "%(f)s" "%(a)s" %(L)s'

ARG REBUILD_PROJECT=1
COPY apk_install.sh /apk.sh
RUN /build.sh \
  -r "${LOG_API_REPO}" \
  -b "${LOG_API_BRANCH}" \
  -q "${CONSTRAINTS_BRANCH}" \
  -d "${EXTRA_DEPENDENCIES}" && \
  rm -rf /usr/local/etc/monasca

ARG REBUILD_CONFIG=1
COPY log-api* /etc/monasca/
COPY template.py start.sh health-check.sh kafka_wait_for_topics.py /

EXPOSE ${MONASCA_CONTAINER_LOG_API_PORT}

HEALTHCHECK --interval=10s --timeout=5s \
  CMD /health-check.sh \
    $MONASCA_CONTAINER_LOG_API_PORT

CMD ["/start.sh"]
