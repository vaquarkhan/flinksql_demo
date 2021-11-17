#!/usr/bin/env bash

source "$(dirname $0)"/env.sh

function create_topic {
    if [[ $(${KAFKA_DIR}/bin/kafka-topics.sh --list --zookeeper localhost:2181) =~ $3 ]]; then
      echo "Topic $3 is existed."
      return
    fi
    ${KAFKA_DIR}/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor $1 --partitions $2 --topic $3
}

function delete_topic {
    ${KAFKA_DIR}/bin/kafka-topics.sh --delete --zookeeper localhost:2181 --topic $1
}

function send_messages_to_kafka() {
    echo -e $1 | ${KAFKA_DIR}/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic $2
}

# start zookeeper and kafka
function start_zookeeper() {
  if [[ -z $KAFKA_DIR || ! -d $KAFKA_DIR || -z $ZOOKEEPER_DIR || ! -d $ZOOKEEPER_DIR ]]; then
    echo "Start Zookeeper failed, Kafka dir and zookeeper dir not exist or not setup."
    exit 1
  fi

  ${KAFKA_DIR}/bin/zookeeper-server-start.sh -daemon ${KAFKA_DIR}/config/zookeeper.properties

  # Echo "Error contacting service. It is probably not running" when zookeeper not running.
  # Echo "ZooKeeper JMX enabled by default                                                                          │wdnmd
  #          Using config: /export/softwares/apache-zookeeper-3.5.9-bin/bin/../conf/zoo.cfg                            │^CProcessed a total of 5 messages
  #          Client port found: 2181. Client address: localhost. Client SSL: false.                                    │[root@huangxu bin]# nqHcMd4ieh=N
  #          Mode: standalone"
  #          when zookeeper running.
  while [[ $(${ZOOKEEPER_DIR}/bin/zkServer.sh status) =~ "not running" ]]; do
    echo "Waiting for zookeeper start."
    sleep 1
  done
}

function start_kafka() {
  if [[ -z $KAFKA_DIR || ! -d $KAFKA_DIR ]]; then
    echo "Start kafka cluster failed, Kafka dir not exist or not setup."
    exit 1
  fi

  ${KAFKA_DIR}/bin/kafka-server-start.sh -daemon ${KAFKA_DIR}/config/server.properties

  # Echo "WatchedEvent state:SyncConnected type:None path:null                                                      │[root@huangxu bin]# nqHcMd4ieh=N
  #       org.apache.zookeeper.KeeperException$NoNodeException: KeeperErrorCode = NoNode for /brokers/ids/0"
  #   when kafka not running.
  while [[ $(${KAFKA_DIR}/bin/zookeeper-shell.sh localhost:2181 get /brokers/ids/0 2>&1) =~ "NoNodeException" ]]; do
    echo "Waiting for kafka start."
    sleep 1
  done
}

function stop_zookeeper() {
  # stop org.apache.zookeeper.server.quorum.QuorumPeerMain
  ${KAFKA_DIR}/bin/zookeeper-server-stop.sh

  # SIGTERM优雅地终止进程，而SIGKILL则立即终止进程。可以处理、忽略和阻塞SIGTERM信号，但是不能处理或阻塞SIGKILL。
  # SIGTERM不会杀死子进程。SIGKILL会杀死子进程。
  # Use SIGTERM, kill -s TERM $pid 正常停止进程
  PIDS=$(jps -l | grep QuorumPeerMain | awk '{print $1}' || echo "")
  if [[ -z "$PIDS" ]]; then
    kill -s TERM $PIDS
  fi
}

function stop_kafka() {
  ${KAFKA_DIR}/bin/kafka-server-stop.sh

  PIDS=$(jps -l | grep Kafka | awk '{print $1}' || echo "")
  if [[ -z "$PIDS" ]]; then
    kill -s TERM $PIDS
  fi
}

function create_kafka_json_source() {
    topicName="$1"
    create_topic 1 1 $topicName

    echo "Sending messages to kafka..."
    send_messages_to_kafka '{"rowtime": "2018-03-12T08:00:00Z", "user_name": "Alice", "event": { "message_type": "WARNING", "message": "This is a warning."}}' $topicName
    send_messages_to_kafka '{"rowtime": "2018-03-12T08:10:00Z", "user_name": "Alice", "event": { "message_type": "WARNING", "message": "This is a warning."}}' $topicName
    send_messages_to_kafka '{"rowtime": "2018-03-12T09:00:00Z", "user_name": "Bob", "event": { "message_type": "WARNING", "message": "This is another warning."}}' $topicName
    send_messages_to_kafka '{"rowtime": "2018-03-12T09:10:00Z", "user_name": "Alice", "event": { "message_type": "INFO", "message": "This is a info."}}' $topicName
    send_messages_to_kafka '{"rowtime": "2018-03-12T09:20:00Z", "user_name": "Steve", "event": { "message_type": "INFO", "message": "This is another info."}}' $topicName
    send_messages_to_kafka '{"rowtime": "2018-03-12T09:30:00Z", "user_name": "Steve", "event": { "message_type": "INFO", "message": "This is another info."}}' $topicName
    send_messages_to_kafka '{"rowtime": "2018-03-12T09:30:00Z", "user_name": null, "event": { "message_type": "WARNING", "message": "This is a bad message because the user is missing."}}' $topicName
    send_messages_to_kafka '{"rowtime": "2018-03-12T10:40:00Z", "user_name": "Bob", "event": { "message_type": "ERROR", "message": "This is an error."}}' $topicName
}
