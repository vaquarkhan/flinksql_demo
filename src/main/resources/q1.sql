-- -- 开启 mini-batch
-- SET table.exec.mini-batch.enabled=true;
-- -- mini-batch的时间间隔，即作业需要额外忍受的延迟
-- SET table.exec.mini-batch.allow-latency=1s;
-- -- 一个 mini-batch 中允许最多缓存的数据
-- SET table.exec.mini-batch.size=1000;
-- -- 开启 local-global 优化
-- SET table.optimizer.agg-phase-strategy=TWO_PHASE;
--
-- -- 开启 distinct agg 切分
-- SET table.optimizer.distinct-agg.split.enabled=true;


-- source
CREATE TABLE user_log (
                          user_id varchar,
                          item_id varchar,
                          category_id varchar,
                          behavior varchar,
                          ts TIMESTAMP(3)
) WITH (
    'connector' = 'kafka',
    'topic' = 'user_behavior',
    'scan.startup.mode' = 'earliest-offset',
    'properties.bootstrap.servers' = 'localhost:9092',
    'properties.group.id' = 'testGroup',
    'format' = 'json'
);

-- sink
CREATE TABLE pvuv_sink (
                           dt varchar PRIMARY KEY,
                           pv BIGINT,
                           uv BIGINT
) WITH (
    'connector' = 'jdbc',
    'url' = 'jdbc:mysql://localhost:3306/flinksql_test',
    'table-name' = 'pvuv_sink',
    'username' = 'root',
    'password' = '123456',
    'sink.buffer-flush.max-rows' = '1'
);

INSERT INTO pvuv_sink
SELECT
    DATE_FORMAT(ts, 'yyyy-MM-dd HH:00') dt,
    COUNT(*) AS pv,
    COUNT(DISTINCT user_id) AS uv
FROM user_log
GROUP BY DATE_FORMAT(ts, 'yyyy-MM-dd HH:00');