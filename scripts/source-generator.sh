#!/usr/bin/env bash

source "$(dirname $0)"/kafka_common.sh

echo "Generating sources..."

topicName=user_behavior
create_topic 1 1 $topicName

java -cp target/flinksql_demo.jar huangxu/chase/flinksql/demo/SourceGenerator 1000 | $KAFKA_DIR/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic $topicName
#java -cp target/flinksql_demo.jar huangxu/chase/flinksql/demo/SourceGenerator 1000 | send_messages_to_kafka
#java -cp target/flinksql_demo.jar huangxu/chase/flinksql/demo/SourceGenerator 1000 | cat