#!/bin/bash

bash

set -e
if [[ ! -z "$DEBUG" ]]; then
    set -x
fi

if [[ -z "$ZOOKEEPER_QUORUM" && -z "$KAFKA_SEED_BROKER_HOST" ]]; then
    echo "You must set ZOOKEEPER_QUORUM or KAFKA_SEED_BROKER_HOST."
    echo "  e.g., launch with -e ZOOKEEPER_QUORUM=zookeeper:2181 or -e KAFKA_SEED_BROKER_HOST=my.kafka.host"
    exit 1
fi

if [[ -z "$SECOR_S3_BUCKET" || -z "$SECOR_S3_PATH" ]]; then
    echo "You must set SECOR_S3_BUCKET and SECOR_S3_PATH."
    echo "  e.g., launch with -e SECOR_S3_BUCKET=my-bucket -e SECOR_S3_PATH=my-path"
    exit 1
fi

if [[ -n "$AWS_ACCESS_KEY" && -n "$AWS_SECRET_KEY" ]]; then
    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY
    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY
fi

# Ensure we can access S3
aws s3 ls s3://$SECOR_S3_BUCKET > /dev/null

SECOR_CONFIG_FILE=/opt/secor/secor.prod.properties

# AWS Access Credentials
if [[ -n "$AWS_ACCESS_KEY" ]]; then sed -i -e "s^aws.access.key=.*$^aws.access.key=${AWS_ACCESS_KEY}^" $SECOR_CONFIG_FILE ; fi
if [[ -n "$AWS_SECRET_KEY" ]]; then sed -i -e "s^aws.secret.key=.*$^aws.secret.key=${AWS_SECRET_KEY}^" $SECOR_CONFIG_FILE ; fi

# How to connect to Kafka/ZK
if [[ -n "$KAFKA_SEED_BROKER_HOST" ]]; then sed -i -e "s/kafka.seed.broker.host=.*$/kafka.seed.broker.host=${KAFKA_SEED_BROKER_HOST}/" $SECOR_CONFIG_FILE ; fi
if [[ -n "$KAFKA_SEED_BROKER_PORT" ]]; then sed -i -e "s/kafka.seed.broker.port=.*$/kafka.seed.broker.port=${KAFKA_SEED_BROKER_PORT}/" $SECOR_CONFIG_FILE ; fi
if [[ -n "$ZOOKEEPER_QUORUM" ]]; then sed -i -e "s/zookeeper.quorum=.*$/zookeeper.quorum=${ZOOKEEPER_QUORUM}/" $SECOR_CONFIG_FILE ; fi

# Where to store things in S3 (no need for if as they're always specified)
sed -i -e "s/secor.s3.bucket=.*$/secor.s3.bucket=${SECOR_S3_BUCKET}/" $SECOR_CONFIG_FILE
sed -i -e "s/secor.s3.path=.*$/secor.s3.path=${SECOR_S3_PATH}/" $SECOR_CONFIG_FILE

# Max file size/ages
if [[ -n "$SECOR_MAX_FILE_BYTES" ]]; then sed -i -e "s/secor.max.file.size.bytes=.*$/secor.max.file.size.bytes=${SECOR_MAX_FILE_BYTES:-200000000}/" $SECOR_CONFIG_FILE ; fi
if [[ -n "$SECOR_MAX_FILE_SECONDS" ]]; then sed -i -e "s/secor.max.file.age.seconds=.*$/secor.max.file.age.seconds=${SECOR_MAX_FILE_SECONDS:-3600}/" $SECOR_CONFIG_FILE ; fi

# Use compression if specified
if [[ -n "$SECOR_COMPRESSION_CODEC" ]]; then sed -i -e "s/secor.compression.codec=.*$/secor.compression.codec=${SECOR_COMPRESSION_CODEC}/" $SECOR_CONFIG_FILE ; fi
if [[ -n "$SECOR_FILE_EXTENSION" ]]; then sed -i -e "s/secor.file.extension=.*$/secor.file.extension=${SECOR_FILE_EXTENSION}/" $SECOR_CONFIG_FILE ; fi

KAFKA_TOPIC_FILTER=${SECOR_KAFKA_TOPIC_FILTER:-'.*'}
TIMESTAMP_NAME=${SECOR_TIMESTAMP_NAME:-timestamp}
TIMESTAMP_PATTERN=${SECOR_TIMESTAMP_PATTERN:-timestamp}
WRITER_FACTORY=${SECOR_WRITER_FACTORY:-com.pinterest.secor.io.impl.SequenceFileReaderWriterFactory}

sed -i -e "s/secor.kafka.topic_filter=.*$/secor.kafka.topic_filter=${KAFKA_TOPIC_FILTER}/" $SECOR_CONFIG_FILE
sed -i -e "s/message.timestamp.name=.*$/message.timestamp.name=${TIMESTAMP_NAME}/" $SECOR_CONFIG_FILE
sed -i -e "s/message.timestamp.input.pattern=.*$/message.timestamp.input.pattern=${TIMESTAMP_PATTERN}/" $SECOR_CONFIG_FILE
sed -i -e "s/secor.file.reader.writer.factory=.*$/secor.file.reader.writer.factory=${WRITER_FACTORY}/" $SECOR_CONFIG_FILE

SECOR_PER_HOUR=${SECOR_PER_HOUR:-false}
SECOR_GROUP=${SECOR_GROUP:-secor_backup}
SECOR_PARSER=${SECOR_MESSAGE_PARSER:-com.pinterest.secor.parser.OffsetMessageParser}
SECOR_OSTRICH_PORT=${SECOR_OSTRICH_PORT:-9999}
JVM_MEMORY=${JVM_MEMORY:-512m}


# Local location before upload to S3
sed -i -e "s/secor.local.path=.*$/secor.local.path=\/tmp\/${SECOR_GROUP}/" $SECOR_CONFIG_FILE

sed -i -e "s/partitioner.granularity.hour=.*$/partitioner.granularity.hour=${SECOR_PER_HOUR}/" $SECOR_CONFIG_FILE
sed -i -e "s/secor.kafka.group=.*$/secor.kafka.group=${SECOR_GROUP}/" $SECOR_CONFIG_FILE
sed -i -e "s/secor.kafka.group=.*$/secor.kafka.group=${SECOR_GROUP}/" $SECOR_CONFIG_FILE
sed -i -e "s/secor.message.parser.class=.*$/secor.message.parser.class=${SECOR_PARSER}/" $SECOR_CONFIG_FILE
sed -i -e "s/ostrich.port=.*$/ostrich.port=${SECOR_OSTRICH_PORT}/" $SECOR_CONFIG_FILE

java -Xmx$JVM_MEMORY -ea -cp /opt/secor/secor.jar \
  -Dsecor_group=$SECOR_GROUP \
  -Dlog4j.configuration=file:./log4j.docker.properties \
  -Dconfig=secor.prod.properties \
  com.pinterest.secor.main.ConsumerMain
