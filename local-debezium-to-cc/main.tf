# https://github.com/Mongey/terraform-provider-kafka-connect
terraform {
  required_providers {
    kafka-connect = {
      source  = "Mongey/kafka-connect"
      version = "0.3.0"
    }
  }
}

provider "kafka-connect" {
  url = "http://localhost:8083"
}

resource "kafka-connect_connector" "debezium" {
  name = "Debezium"

  config = {
    "name"            = "Debezium"
    "connector.class" = "io.debezium.connector.mysql.MySqlConnector"

    "database.user" = "root"
    "database.server.id" = "1"
    "database.hostname" = "mysql"
    "database.include.list" = "inventory"
    "topic.prefix" = "debezium"
    "tasks.max" = "1"
    "schema.history.internal.kafka.topic" = "__schemahistory.fullfillment"
    "include.schema.changes" = "true"

    # local docker
    # "schema.history.internal.kafka.bootstrap.servers" = "kafka:9092"

    # Confluent Cloud
    "schema.history.internal.kafka.bootstrap.servers" = var.KAFKA_BOOTSTRAP_SERVERS
    "schema.history.internal.consumer.security.protocol" = "SASL_SSL"
    "schema.history.internal.consumer.sasl.mechanism" = "PLAIN"
    "schema.history.internal.consumer.sasl.jaas.config" = "org.apache.kafka.common.security.plain.PlainLoginModule required username=\"${var.KAFKA_API_KEY}\" password=\"${var.KAFKA_API_SECRET}\";"
    "schema.history.internal.producer.security.protocol" = "SASL_SSL"
    "schema.history.internal.producer.sasl.mechanism" = "PLAIN"
    "schema.history.internal.producer.sasl.jaas.config" = "org.apache.kafka.common.security.plain.PlainLoginModule required username=\"${var.KAFKA_API_KEY}\" password=\"${var.KAFKA_API_SECRET}\";"
  }

  config_sensitive = {
    "database.password" = "secret"
  }
}