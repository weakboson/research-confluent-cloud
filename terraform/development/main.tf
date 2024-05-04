# Configure the Confluent Provider
terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.74.0"
    }
  }
}
