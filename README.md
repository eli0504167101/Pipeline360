# Pipeline360
Pipeline360 - Hotel Management System
A cloud-native, scalable hotel management platform orchestrated with Kubernetes, designed with a focus on high availability, persistence, and production-grade reliability.

# 🏗️ System Architecture


The platform is deployed within a dedicated hotel-system namespace, ensuring resource isolation and management efficiency. It consists of the following components:

Frontend: A high-performance web interface deployed with 5 replicas to ensure seamless user accessibility.

Backend: A robust API service with 5 replicas, utilizing horizontal scaling for efficient request handling.

Database: A MongoDB cluster deployed as a StatefulSet with 3 replicas, utilizing volumeClaimTemplates to ensure consistent and persistent data storage.

# 🚀 Key Technical Features
High Availability: Load-balanced deployment across multiple pods for all microservices.

Self-Healing Infrastructure: Configured with Liveness and Readiness probes to automatically detect and recover from service failures.

Data Persistence: Automated persistent volume provisioning ensuring zero data loss during pod rescheduling.

Configuration Management: Decoupled architecture using ConfigMaps for environment variables and Secrets for sensitive data management.

Operational Isolation: Resource segregation using Kubernetes Namespaces.

# 🛠️ Prerequisites
A local Kubernetes cluster (e.g., Kind, Minikube, or Docker Desktop).

kubectl command-line tool installed and configured.

# 📋 Deployment Instructions
Follow these steps to deploy the system to your local cluster:

Create the dedicated namespace:

Bash
kubectl create namespace hotel-system
Deploy the system components:

Bash
kubectl apply -f k8s/ -n hotel-system
Verify the deployment status:

Bash
kubectl get all -n hotel-system
🔐 Security & Operations
Hardening: Containers are built with minimal images to reduce the attack surface.

Secret Management: Sensitive credentials are injected at runtime via Kubernetes Secrets, ensuring they are never exposed in the source code or build artifacts.

Pro-Tip for your GitHub:
If you have a k8s/ folder, make sure all your files are inside it so the commands above work perfectly.
