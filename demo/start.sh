#!/bin/bash
set -m

# mysql
/usr/sbin/mysqld &

# openstack base services
keystone-all --config-file /etc/keystone/keystone.conf &
/etc/init.d/apache2 start
nova-api &

# Set the service endpoint to the currently running ip
ansible-playbook -i /setup/hosts /setup/keystone.yml -c local

# influxdb
/usr/bin/influxdb -config=/opt/influxdb/shared/config.toml &

# zookeeper
. /etc/zookeeper/conf/environment
[ -d $ZOO_LOG_DIR ] || mkdir -p $ZOO_LOG_DIR
chown $USER:$GROUP $ZOO_LOG_DIR
[ -r /etc/default/zookeeper ] && . /etc/default/zookeeper
if [ -z "$JMXDISABLE" ]; then
    JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.local.only=$JMXLOCALONLY"
fi
java -cp $CLASSPATH $JAVA_OPTS -Dzookeeper.log.dir=${ZOO_LOG_DIR} -Dzookeeper.root.logger=${ZOO_LOG4J_PROP} $ZOOMAIN $ZOOCFG &

# kafka and topic creation
/opt/kafka/bin/kafka-server-start.sh /etc/kafka/server.properties &
ansible-playbook -i /setup/hosts /setup/topics.yml -c local

# Start the persister
/usr/bin/java -Dfile.encoding=UTF-8 -Xmx1g -cp /opt/monasca/monasca-persister.jar:/opt/monasca/vertica/vertica_jdbc.jar monasca.persister.PersisterApplication server /etc/monasca/persister-config.yml &

# start the api
/usr/bin/java -Xmx1g -cp /opt/monasca/monasca-api.jar monasca.api.MonApiApplication server /etc/monasca/api-config.yml &

# start the agent
/etc/init.d/monasca-agent start

# Start the threshold engine
/opt/storm/current/bin/storm nimbus &
/opt/storm/current/bin/storm supervisor &
sleep 30  # Takes a moment for storm to be up
/opt/storm/current/bin/storm jar /opt/monasca/monasca-thresh.jar monasca.thresh.ThresholdingEngine /etc/monasca/thresh-config.yml thresh-cluster

# notification engine
/etc/init.d/postfix start
/usr/local/bin/monasca-notification &

# Setup alarms
ansible-playbook -i /setup/hosts /setup/alarms.yml -c local

# Finally tail the api log as we need to have something running in the foreground
echo -e "\n\n\n\n\nMonasca is up and running\n\tTailing the API log.\n"
tail -f /var/log/monasca/monasca-api.log

