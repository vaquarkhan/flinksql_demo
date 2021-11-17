#!/usr/bin/env bash

source "$(dirname $0)"/env.sh

PROJECT_DIR=`pwd`
$FLINK_DIR/bin/flink run -d -p 4 out/artifacts/flinksql_demo_jar/flinksql_demo.jar -w "${PROJECT_DIR}"/src/main/resources/ -f "$1".sql