terraform {
  backend "gcs" {
    bucket  = "catgifbuckets"
    prefix  = "terraform/state"
  }
}