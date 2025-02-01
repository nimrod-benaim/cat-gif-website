provider "google" {
# project = "var.gcp_project_id"
  project = "cat-gif-project"
  region  = "us-central1"
  credentials = file("C:\\Program Files (x86)\\Google\\Cloud SDK\\terraform-key.json")
}

resource "google_container_cluster" "primary" {
  name     = "gke-cluster"
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

resource "null_resource" "kubectl_apply" {
  provisioner "local-exec" {
    command = <<EOT
      gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region us-central1
      kubectl apply -f k8s/
    EOT
  }
  depends_on = [google_container_cluster.primary]
}
