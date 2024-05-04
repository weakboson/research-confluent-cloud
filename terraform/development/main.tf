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

  lifecycle {
    prevent_destroy = false
  }
}

# Create a Kafka Cluster
# https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_kafka_cluster
resource "confluent_kafka_cluster" "development" {
  display_name = "development-cluster"
  availability = "SINGLE_ZONE"
  cloud        = "GCP"
  region       = "asia-northeast1"
  basic {}

  environment {
    id = confluent_environment.development.id
  }

  lifecycle {
    prevent_destroy = false
  }
}
