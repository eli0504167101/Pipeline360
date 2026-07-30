# Pipeline360 Startup Guide

This guide describes the recommended startup procedure after restarting your computer when working with the **Pipeline360** project.

---

# 1. Start Docker Desktop

Launch **Docker Desktop**.

Wait until it shows:

```text
Engine running
```

---

# 2. Open WSL

Open Ubuntu (WSL).

Navigate to the project directory:

```bash
cd ~/Pipeline360
```

---

# 3. Verify the Kind Cluster

Check that the cluster exists:

```bash
kind get clusters
```

Expected output:

```text
pipeline360-cluster
```

Then verify the Kubernetes nodes:

```bash
kubectl get nodes
```

Expected:

```text
pipeline360-cluster-control-plane   Ready
```

If the node is not available, verify Docker:

```bash
docker ps
```

---

# 4. Verify Kubernetes Context

```bash
kubectl config current-context
```

Expected:

```text
kind-pipeline360-cluster
```

---

# 5. Verify the Application Pods

Run:

```bash
kubectl get pods -n hotel-system
```

Expected components:

- Backend (5 Pods)
- Frontend (5 Pods)
- MongoDB Replica Set (3 Pods)
- Mongo Express (1 Pod)

Example:

```text
backend-deployment-xxxxx      1/1 Running

frontend-deployment-xxxxx     1/1 Running

mongo-0                       1/1 Running
mongo-1                       1/1 Running
mongo-2                       1/1 Running

mongo-express-xxxxx           1/1 Running
```

---

# 6. Verify ArgoCD

```bash
kubectl get application pipeline360 \
-n argocd \
-o custom-columns='SYNC:.status.sync.status,HEALTH:.status.health.status'
```

Expected:

```text
Synced
Healthy
```

---

# 7. Start All Local Services

Instead of running multiple `kubectl port-forward` commands manually, use the startup script.

Run:

```bash
./start-pipeline360.sh
```

The script automatically:

- Verifies the Kubernetes cluster
- Checks that all Pipeline360 Pods are running
- Starts Mongo Express (if needed)
- Starts ArgoCD (if needed)
- Leaves both port-forwards running in the background
- Displays all project URLs

---

# 8. Application URLs

## Hotel Application

```text
http://hotel.local:3000
```

---

## Mongo Express

```text
http://localhost:8085
```

---

## ArgoCD

```text
https://localhost:8081
```

Accept the browser security warning the first time.

---

# 9. Check Running Port-Forwards

```bash
ps -ef | grep '[k]ubectl port-forward'
```

---

# 10. Check Listening Ports

```bash
ss -ltn | grep -E ':8081|:8085'
```

---

# 11. View Port-Forward Logs

Mongo Express:

```bash
cat /tmp/pipeline360-mongo-express.log
```

ArgoCD:

```bash
cat /tmp/pipeline360-argocd.log
```

---

# 12. Quick Health Checks

## Backend API

```bash
curl http://127.0.0.1:3000/api/reservations/hotels \
-H "Host: hotel.local"
```

---

## Frontend

```bash
curl http://127.0.0.1:3000 \
-H "Host: hotel.local"
```

---

# Troubleshooting

## Cluster is unavailable

```bash
docker ps
kind get clusters
kubectl get nodes
```

---

## Pods are not Running

```bash
kubectl get pods -n hotel-system
```

---

## Backend Logs

```bash
kubectl logs \
deployment/backend-deployment \
-n hotel-system \
--tail=100
```

---

## Frontend Logs

```bash
kubectl logs \
deployment/frontend-deployment \
-n hotel-system \
--tail=100
```

---

## Mongo Express Logs

```bash
kubectl logs \
deployment/mongo-express \
-n hotel-system \
--tail=100
```

---

## Verify Services

```bash
kubectl get svc -n hotel-system
```

---

## Verify Ingress

```bash
kubectl get ingress -n hotel-system
```

---

## Verify ArgoCD

```bash
kubectl get application pipeline360 -n argocd
```

---

# Daily Startup Checklist

- ✅ Docker Desktop is running
- ✅ Kind cluster is available
- ✅ Kubernetes node is Ready
- ✅ All Pods are Running
- ✅ ArgoCD is Synced and Healthy
- ✅ Run `./start-pipeline360.sh`
- ✅ Open:
  - http://hotel.local:3000
  - http://localhost:8085
  - https://localhost:8081

---

# Project Structure

```
Frontend
    ↓
hotel.local:3000
    ↓
Ingress
    ↓
Frontend Service
    ↓
Backend Service
    ↓
MongoDB Replica Set
```

---

**Pipeline360** is now ready for development.