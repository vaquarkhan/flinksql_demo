# flinksql_demo
A simple flink sql client, which can receive sql file and commit to flink cluster. In this demp, read from log file and write to kafka, then read from kafka and write to mysql.
> Based on http://wuchong.me/blog/2019/09/02/flink-sql-1-9-read-from-kafka-write-into-mysql/, I want to write by myself so i dont fork this repo.

#### What happen in this demo
- Read user_behavior.log by java, the type of line is json, and write std out
- Read java std out and send datas to kafka by shell
- Commit sql file by shell
- Parse the sql file in java
- Commit job to flink cluster
- Read from kafka, which definition in sql file, by flink cluster
- Write to mysql, which definition in sql file, by flink cluster

#### Running on:
- flink==1.13.3
- kafka==2.5.1
- mysql==5.7.36
- centos7
- jdk1.8.0_311

#### How to use
1. set variables in flink_dir, kafka_dir, zookeeper_dir in script/env.sh
2. sh script/start_kafka.sh
3. sh script/source-generator.sh
4. sh script/run.sh q1
5. sh stop_kafka.sh

#### Some Error may occur:
- main class not found in jar
  - use idea build artifacts insted of mvn package. https://blog.csdn.net/qq_44065303/article/details/108343604
  - but why?
- NoClassDefFoundError: ByteArrayDeserializer or ConsumerRecord
  - Put kafka-clients.jar to flink/lib, and dont forget restart flink cluster
- Connect mysql failed by jdbc
  - try change jdbc version, in my attempt, failed with mysql-connector-java 8.0.11, and succeeded with mysql-connector-java 8.0.25.

#### Some questions need to be considered later
- Can VARCHAR type can be primary key in mysql?
- How to indicate table is update instead of append in flink sql?
- Can directly change "2017-11-26T01:00:00Z" to timestamp in flink sql?