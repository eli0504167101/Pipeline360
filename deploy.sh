#!/bin/bash

# הגדרות
IMAGE_NAME="hotel-frontend:local"
CLUSTER_NAME="pipeline360-cluster"
DEPLOYMENT_FILE="infra-repo/kubernetes/deployments/frontend-deployment.yaml"

echo "🚀 Starting deployment pipeline..."

# 1. Build
docker build -t $IMAGE_NAME -f frontend-repo/Dockerfile .

# 2. Load
kind load docker-image $IMAGE_NAME --name $CLUSTER_NAME

# 3. Apply
kubectl apply -f $DEPLOYMENT_FILE

# 4. Restart to ensure new image is pulled
kubectl rollout restart deployment frontend-deployment

echo "✅ Deployment completed successfully!"