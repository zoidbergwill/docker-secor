# Docker image for running Secor

By default uses Snappy compression, please checkout https://github.com/pinterest/secor for more information.

## Example
```
docker run -e ZOOKEEPER_QUORUM=zookeeper.service.consul:2181 \
       -e SECOR_S3_BUCKET=test-bucket sagent/secor
```

## Configuration options 

Can be configured using environment variables:

Variable Name              | Configuration Option
---------------------------|---------------------------
DEBUG                      | Enable some debug logging (default `false`)
ZOOKEEPER_QUORUM           | Zookeeper quorom (required)
AWS_ACCESS_KEY             | AWS Access key (required)
AWS_SECRET_KEY             | AWS Secret access key (required)
SECOR_S3_BUCKET            | Target S3 bucket (required)
KAFKA_SEED_BROKER_HOST     | Kafka broker hosts (not required?)  
SECOR_MAX_FILE_BYTES       | Max bytes per file (default `200000000`)
SECOR_MAX_FILE_SECONDS     | Max time per file (default `3600`)
SECOR_KAFKA_TOPIC_FILTER   | Regexp filter which topics it should replicate (default `.*`)
SECOR_MESSAGE_PARSER       | Which message parser to use (default `OffsetMessageParser`)
SECOR_TIMESTAMP_NAME       | When using `DateMessageParser` what field to use in the JSON (default `timestamp`)
SECOR_TIMESTAMP_PATTERN    | When using `DateMessageParser` what format the timestamp is (default `timestamp`)
SECOR_WRITER_FACTORY       | What WriterFactory to use (default `SequenceFileReaderWriterFactory`)
SECOR_GROUP                | Name that is used for S3 path and as Kafka consumer name. (default `secor_backup`)

