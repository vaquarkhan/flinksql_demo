#!/usr/bin/env bash

source "$(dirname $0)"/kafka_common.sh

stop_kafka
stop_zookeeper
