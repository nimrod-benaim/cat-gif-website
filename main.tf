provider "google" {
  project     = var.gcp_project_id
  credentials = file(var.gcp_credentials_path)
  region  = "us-central1"
}
variable "gcp_project_id" {
  description = "gcp project id"
  type        = string
}

variable "gcp_credentials_path" {
  description = "gcp_credentials_path"
  type        = string
}

resource "google_container_cluster" "primary" {
  name     = "cat-gif-cluster"
  location = "us-central1"
  initial_node_count = 1
  node_config {
    machine_type = "e2-small"
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "node-pool"
  location   = "us-central1"
  cluster    = google_container_cluster.primary.name
  node_count = 1
  node_config {
    machine_type = "e2-small"
  }
}


