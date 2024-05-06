# ref. https://github.com/confluentinc/terraform-provider-confluent/blob/7de2072034b81ca10592f304946540ddccc0aeb3/examples/configurations/basic-kafka-acls/main.tf
# Configure the Confluent Provider
terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.74.0"
    }
  }
}

# Create Environments
# https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_environment
resource "confluent_environment" "development" {
  display_name = "Development"

  stream_governance {
    package = "ESSENTIALS"
  }
}

# Create a Kafka Cluster
# https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_kafka_cluster
resource "confluent_kafka_cluster" "research-cluster" {
  display_name = "research-cluster"
  availability = "SINGLE_ZONE"
  cloud        = "GCP"
  region       = "asia-northeast1"
  basic {}

  environment {
    id = confluent_environment.development.id
  }
}

# Create a Service Account
# https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_service_account
resource "confluent_service_account" "alice" {
  display_name = "Alice"
  description  = "Development Kafka Service Account"
}

# Create a Role Binding
# https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_role_binding
resource "confluent_role_binding" "alice-kafka-research-cluster-admin" {
  principal   = "User:${confluent_service_account.alice.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.research-cluster.rbac_crn
}

# Create a Kafka API Key
# https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_api_key
resource "confluent_api_key" "kafka-research-cluster-alice-api-key" {
  display_name = "kafka-research-cluster-alice-api-key"
  description  = "Kafka API Key that is owned by 'alice' service account"
  owner {
    id          = confluent_service_account.alice.id
    api_version = confluent_service_account.alice.api_version
    kind        = confluent_service_account.alice.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.research-cluster.id
    api_version = confluent_kafka_cluster.research-cluster.api_version
    kind        = confluent_kafka_cluster.research-cluster.kind

    environment {
      id = confluent_environment.development.id
    }
  }
}

# Create a Kafka Topic
# https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_kafka_topic
resource "confluent_kafka_topic" "test_topic" {
  kafka_cluster {
    id = confluent_kafka_cluster.research-cluster.id
  }
  topic_name         = "test_topic"
  partitions_count   =  1
  rest_endpoint      = confluent_kafka_cluster.research-cluster.rest_endpoint
  config = {
    "cleanup.policy"  = "compact"
    "retention.ms"    = -1
    "retention.bytes" = -1
  }
  credentials {
    key    = confluent_api_key.kafka-research-cluster-alice-api-key.id
    secret = confluent_api_key.kafka-research-cluster-alice-api-key.secret
  }
}

# # Create a Kafka Topic for Debezium
# resource "confluent_kafka_topic" "__consumer_offsets" {
#   kafka_cluster {
#     id = confluent_kafka_cluster.research-cluster.id
#   }
#   topic_name         = "__consumer_offsets"
#   partitions_count   =  50
#   rest_endpoint      = confluent_kafka_cluster.research-cluster.rest_endpoint
#   config = {
#     cleanup_policy = "compact"
#   }
#   credentials {
#     key    = confluent_api_key.kafka-research-cluster-alice-api-key.id
#     secret = confluent_api_key.kafka-research-cluster-alice-api-key.secret
#   }
# }

# resource "confluent_kafka_topic" "__debezium_offsets" {
#   kafka_cluster {
#     id = confluent_kafka_cluster.research-cluster.id
#   }
#   topic_name         = "__debezium_offsets"
#   partitions_count   =  25
#   rest_endpoint      = confluent_kafka_cluster.research-cluster.rest_endpoint
#   config = {
#     cleanup_policy = "compact"
#   }
#   credentials {
#     key    = confluent_api_key.kafka-research-cluster-alice-api-key.id
#     secret = confluent_api_key.kafka-research-cluster-alice-api-key.secret
#   }
# }

# resource "confluent_kafka_topic" "__debezium_status" {
#   kafka_cluster {
#     id = confluent_kafka_cluster.research-cluster.id
#   }
#   topic_name         = "__debezium_status"
#   partitions_count   =  5
#   rest_endpoint      = confluent_kafka_cluster.research-cluster.rest_endpoint
#   config = {
#     cleanup_policy = "compact"
#   }
#   credentials {
#     key    = confluent_api_key.kafka-research-cluster-alice-api-key.id
#     secret = confluent_api_key.kafka-research-cluster-alice-api-key.secret
#   }
# }

# resource "confluent_kafka_topic" "__debezium_configs" {
#   kafka_cluster {
#     id = confluent_kafka_cluster.research-cluster.id
#   }
#   topic_name         = "__debezium_configs"
#   partitions_count   =  1
#   rest_endpoint      = confluent_kafka_cluster.research-cluster.rest_endpoint
#   config = {
#     cleanup_policy = "compact"
#   }
#   credentials {
#     key    = confluent_api_key.kafka-research-cluster-alice-api-key.id
#     secret = confluent_api_key.kafka-research-cluster-alice-api-key.secret
#   }
# }

# resource "confluent_kafka_topic" "__schemahistory_fullfillment" {
#   kafka_cluster {
#     id = confluent_kafka_cluster.research-cluster.id
#   }
#   topic_name         = "__schemahistory.fullfillment"
#   partitions_count   =  1
#   rest_endpoint      = confluent_kafka_cluster.research-cluster.rest_endpoint
#   config = {
#     cleanup_policy = "delete"
#   }
#   credentials {
#     key    = confluent_api_key.kafka-research-cluster-alice-api-key.id
#     secret = confluent_api_key.kafka-research-cluster-alice-api-key.secret
#   }
# }
