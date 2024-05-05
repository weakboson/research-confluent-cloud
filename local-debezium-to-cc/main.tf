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

    # local docker
    "schema.history.internal.kafka.bootstrap.servers" = "kafka:9092"
    # Confluent Cloud
    # "schema.history.internal.kafka.bootstrap.servers" = "${env.KAFKA_BOOTSTRAP_SERVERS}"
    "schema.history.internal.kafka.topic" = "__schemahistory.fullfillment"
    "include.schema.changes" = "true"

    "topic.prefix" = "debezium"

    "tasks.max" = "1"
  }

  config_sensitive = {
    "database.password" = "secret"
  }
}