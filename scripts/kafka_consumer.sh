#!/usr/bin/env bash

source "$(dirname $0)"/kafka_common.sh

function create_kafka_consumer() {
  ${kafka_dir}/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic $1 --from-begining
}

create_kafka_consumer $1