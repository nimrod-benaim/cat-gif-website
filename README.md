# Project Overview
This project is a Flask-based web application deployed on a Kubernetes cluster using Helm and managed with Terraform. 
The application includes a visitor counter, monitored using Prometheus and visualized with Grafana. 
The CI/CD pipeline is built with GitHub Actions, automating the deployment process on Google Kubernetes Engine (GKE).

---

## Table of Contents
- [Project Overview](#project-overview)
- [Setup Instructions](#setup-instructions)
- [CI/CD Workflow](#cicd-workflow)
- [Deployment Steps](#deployment-steps)
- [Security Considerations](#security-considerations)
- [Monitoring Setup](#monitoring-setup)

---

## Setup Instructions
### Prerequisites
Ensure you have the following installed:
- **Terraform** (for infrastructure management)
- **Google Cloud SDK** (for GKE authentication)
- **Docker** (for containerization)
- **Helm** (for Kubernetes deployments)
- **Kubectl** (for interacting with the Kubernetes cluster)
- **GitHub Actions** (for CI/CD automation)

### Initial Setup
1. **Clone the Repository**
   ```sh
   git clone <repository_url>
   cd <project_directory>
   ```

2. **Authenticate with Google Cloud**
   ```sh
   gcloud auth login
   gcloud auth application-default login
   ```

3. **Initialize Terraform & Deploy Infrastructure**
   ```sh
   cd terraform/
   terraform init
   terraform apply -auto-approve
   ```

4. **Set Up Kubernetes Context**
   ```sh
   gcloud container clusters get-credentials <cluster_name> --region <region>
   ```

5. **Deploy the Application with Helm**
   ```sh
   cd helm/
   helm install catgif ./
   ```

---

## CI/CD Workflow
This project uses **GitHub Actions** for CI/CD automation. The workflow includes:
1. **Code Push & Pull Requests**
   - On push, the workflow triggers automated testing.
2. **Docker Image Build & Push**
   - The Flask app is built into a Docker image and pushed to Docker Hub.
3. **Terraform Execution**
   - Ensures that the GKE infrastructure is correctly provisioned.
4. **Helm Deployment**
   - Deploys the latest application version to the Kubernetes cluster.

---

## Deployment Steps
1. **Push Code to GitHub** → Triggers CI/CD workflow.
2. **GitHub Actions Runs Pipeline** → Builds, pushes, and deploys the application.
3. **Helm Deploys the App on GKE** → Kubernetes applies the latest updates.
4. **Monitor Deployment via Grafana** → Visualize app performance and logs.

---

## Security Considerations
- **Secrets Management**: Application secrets (DB credentials) are stored securely in Kubernetes Secrets.
- **IAM Roles**: Least privilege access is enforced using Google Cloud IAM roles.
- **Image Security**: Docker images are scanned for vulnerabilities before deployment.
- **Network Policies**: Firewalls restrict external access to essential services only.

---

## Monitoring Setup
This project integrates Prometheus and Grafana for monitoring:
1. **Prometheus**: Collects metrics from the Flask app (`/metrics` endpoint).
2. **Loki**: Logs aggregation for better debugging.
3. **Grafana**: Visualizes Prometheus metrics.

To access Grafana:
```sh
kubectl port-forward service/grafana 3000:80 -n monitoring
```
Then, open `http://localhost:3000` in your browser.

---

## Conclusion
This project automates infrastructure management, deployment, and monitoring using a robust CI/CD pipeline. 
Terraform ensures scalable infrastructure, 
Helm manages Kubernetes applications, 
and Prometheus/Grafana provides real-time observability.

For any issues, open a GitHub Issue or reach out to the maintainers.

