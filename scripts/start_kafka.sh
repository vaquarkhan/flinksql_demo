#!/usr/bin/env bash

source "$(dirname $0)"/kafka_common.sh

start_zookeeper
start_kafka
