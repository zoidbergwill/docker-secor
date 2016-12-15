# Secor

This project uses Gradle to package up Secor as a single executable JAR containing all dependencies, and packages that JAR inside a docker container which can be configured through the use of ENV vars at runtime.

By default uses Snappy compression, please checkout https://github.com/pinterest/secor for more information.

## Example
```
docker run -e ZOOKEEPER_QUORUM=zookeeper.service.consul:2181 \
       -e SECOR_S3_BUCKET=test-bucket sagent/secor
```

## Configuration options

Can be configured using environment variables:

Variable Name.               | Configuration Option
-----------------------------|---------------------------
`DEBUG`                      | Enable some debug logging (default `false`)
`JVM_MEMORY`                 | How much memory to give the JVM (via the `-Xmx` parameter)
`ZOOKEEPER_QUORUM`           | Zookeeper quorum (not required IF `KAFKA_SEED_BROKER_HOST` is specified)
`KAFKA_SEED_BROKER_HOST`     | Kafka broker hosts (not required IF `ZOOKEEPER_QUORUM` is specified)
`KAFKA_SEED_BROKER_PORT`     | Kafka broker port (not required, defaults to 9092)
`AWS_ACCESS_KEY`             | AWS Access key (not required if IAM policy is in place)
`AWS_SECRET_KEY`             | AWS Secret access key (not required if IAM policy is in place)
`SECOR_S3_BUCKET`            | Target S3 bucket (required)
`SECOR_S3_PATH`              | Path within S3 bucket where sequence files are stored (required)
`SECOR_MAX_FILE_BYTES`       | Max bytes per file (default `200000000`)
`SECOR_MAX_FILE_SECONDS`     | Max time per file (default `3600`)
`SECOR_KAFKA_TOPIC_FILTER`   | Regexp filter which topics it should replicate (default `.*`)
`SECOR_MESSAGE_PARSER`       | Which message parser to use (default `OffsetMessageParser`)
`SECOR_TIMESTAMP_NAME`       | When using `DateMessageParser` what field to use in the JSON (default `timestamp`)
`SECOR_TIMESTAMP_PATTERN`    | When using `DateMessageParser` what format the timestamp is (default `timestamp`)
`SECOR_WRITER_FACTORY`       | What WriterFactory to use (default `SequenceFileReaderWriterFactory`)
`SECOR_GROUP`                | Name that is used as Kafka consumer group name. (default `secor_backup`)
`SECOR_COMPRESSION_CODEC`    | Which compression codec to use (not required, e.g., `org.apache.hadoop.io.compress.SnappyCodec`)
`SECOR_FILE_EXTENSION`       | Custom file extension to add to each sequence file stored (not required, e.g., `.snappy`)
`SECOR_PER_HOUR`             | Should Secor partition the files up by hour as well as day? (default `false`)
`SECOR_PARSER`               | Which message parser implementation to use? (default `OffsetMessageParser`)
