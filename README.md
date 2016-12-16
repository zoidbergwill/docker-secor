# Secor 0.22 _(Kafka 0.10.0.1)_

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

There are many more configuration options that can be passed in via `-e NAME=value`, described in the table below.

## Configuration options

Can be configured using environment variables:

Environment Variable Name           | Required? | Default Value                      | Purpose
------------------------------------|-----------|------------------------------------|--------------------------------------------------------------------------
`DEBUG`                             | **No**    | `false`                            | Enable some debug logging
`JVM_MEMORY`                        | **No**    | `512m`                             | How much memory to give the JVM (via the `-Xmx` parameter)
`ZOOKEEPER_QUORUM`                  | **Yes**   |                                    | Zookeeper quorum (not required if `KAFKA_SEED_BROKER_HOST` is specified)
`KAFKA_SEED_BROKER_HOST`            | **Yes**   |                                    | Kafka broker hosts (not required if `ZOOKEEPER_QUORUM` is specified)
`KAFKA_SEED_BROKER_PORT`            | **No**    | `9092`                             | Kafka broker port
`AWS_ACCESS_KEY`                    | **No**    |                                    | AWS Access key
`AWS_SECRET_KEY`                    | **No**    |                                    | AWS Secret access key
`AWS_REGION`                        | **No**    |                                    | The AWS region for S3 uploading
`AWS_ENDPOINT`                      | **No**    |                                    | The AWS S3 endpoint to use for uploading
`SECOR_S3_BUCKET`                   | **Yes**   |                                    | The S3 bucket into which backups will be persisted
`SECOR_S3_PATH`                     | **Yes**   |                                    | Path within S3 bucket where sequence files are stored
`SECOR_KAFKA_TOPIC_FILTER`          | **No**    | `.*`                               | Regexp filter which topics it should replicate
`SECOR_KAFKA_TOPIC_BLACKLIST`       | **No**    |                                    | Which topics to exclude from backing up
`SECOR_MAX_FILE_BYTES`              | **No**    | `200000000`                        | Max bytes per file stored in S3
`SECOR_MAX_FILE_SECONDS`            | **No**    | `3600`                             | Max time per file before it is stored in S3
`SECOR_FILE_READER_WRITER_FACTORY`  | **Yes**   | `SequenceFileReaderWriterFactory`  | Which `WriterFactory` to use
`SECOR_COMPRESSION_CODEC`           | **No**    |                                    | Which Hadoop compression codec to use for partition files
`SECOR_FILE_EXTENSION`              | **No**    |                                    | Custom file extension to be appended to all partition names
`SECOR_TIMESTAMP_NAME`              | **No**    | `timestamp`                        | When using `DateMessageParser` what field to use in the JSON
`SECOR_TIMESTAMP_PATTERN`           | **No**    |                                    | When using `DateMessageParser` what format the timestamp is
`PARTITIONER_GRANULARITY_HOUR`      | **No**    | `false`                            | Should Secor partition the files up by hour as well as day?
`PARTITIONER_GRANULARITY_MINUTE`    | **No**    | `false`                            | Should Secor partition the files up by hour as well as hour, and day?
`SECOR_KAFKA_GROUP`                 | **No**    | `secor_backup`                     | Kafka consumer group name
`SECOR_MESSAGE_PARSER_CLASS`        | **No**    | `OffsetMessageParser`              | Which message parser factory to use
`SECOR_GENERATION`                  | **No**    | `1`                                | Generational version ID to differentiate between incompatible upgrades
`SECOR_CONSUMER_THREADS`            | **No**    | `7`                                | Number of consumer threads per Secor process
`SECOR_MESSAGES_PER_SECOND`         | **No**    | `10000`                            | Maximum number of messages consumed per second for the **entire process**
`SECOR_OFFSETS_PER_PARTITION`       | **No**    | `10000000`                         | How many offsets should be stored within a backed up partition?
`KAFKA_OFFSETS_STORAGE`             | **No**    | `kafka`                            | Should offsets be stored in Kafka or ZooKeeper?
`KAFKA_DUAL_COMMIT_ENABLED`         | **No**    | `false`                            | Should Secor commit processed offsets to Kafak AND ZooKeeper?
`SECOR_OSTRICH_PORT`                | **No**    | `9999`                             | What port should Ostrict data be sent on


## Using without Docker

If you just wish to package up Secor as a standalone uber-JAR, you can run the gradle tasks directly, e.g.:

```shell
./gradlew shadowJar
```
