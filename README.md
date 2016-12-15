# Secor (0.22)

This project uses Docker (and Gradle under the hood) to produce a Docker image containing an uber-jar (single jar containing all dependencies) version of Pinterest Secor (https://github.com/pinterest/secor).

Currently, this project packages Secor 0.22, using Kafka client version 0.10.0.1.

`docker-entrypoint.sh` is the entrypoint into the image, it is responsible for taking passed in ENV vars at runtime and configuring Secor accordingly. The table below shows all ENV variables you can specify to configure Secor's operation.

## Building the Image

You can build the image locally by doing:

```shell
docker build -t secor .
```

To release a new version to the ovotech Docker org, you must create a tag/release in the git repository. The name of the tag will be used as the Docker release tag.

## How to Run

If you are running from outside an AWS instance, you must specify AWS credentials:

```shell
docker run \
  -e DEBUG=true \
  -e ZOOKEEPER_QUORUM=zookeeper.quorum.consul:2181 \
  -e AWS_ACCESS_KEY=YOUR_KEY \
  -e AWS_SECRET_KEY=YOUR_SECRET \
  -e SECOR_S3_BUCKET=my-kafka-backups \
  -e SECOR_GROUP=raw_logs \
  secor
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

## Using without Docker

If you just wish to package up Secor as a standalone uber-JAR, you can run the gradle tasks directly, e.g.:

```shell
./gradlew shadowJar
```
