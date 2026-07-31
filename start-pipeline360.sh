#!/usr/bin/env bash

set -u

PROJECT_NAME="Pipeline360"
MONGO_LOCAL_PORT="8086"
ARGOCD_LOCAL_PORT="8081"

MONGO_LOG="/tmp/pipeline360-mongo-express.log"
ARGOCD_LOG="/tmp/pipeline360-argocd.log"

MONGO_PID_FILE="/tmp/pipeline360-mongo-express.pid"
ARGOCD_PID_FILE="/tmp/pipeline360-argocd.pid"

echo "=================================================="
echo "Starting ${PROJECT_NAME}"
echo "=================================================="

# --------------------------------------------------
# Verify Kubernetes cluster
# --------------------------------------------------

echo
echo "[1/5] Checking Kubernetes cluster..."

if ! kubectl cluster-info >/dev/null 2>&1; then
    echo "ERROR: Kubernetes cluster is not available."
    echo "Start Docker Desktop and verify the Kind cluster first."
    exit 1
fi

if ! kubectl get nodes >/dev/null 2>&1; then
    echo "ERROR: Unable to read Kubernetes nodes."
    exit 1
fi

echo "Kubernetes cluster is available."

# --------------------------------------------------
# Verify application Pods
# --------------------------------------------------

echo
echo "[2/5] Checking Pipeline360 Pods..."

kubectl get pods -n hotel-system

# --------------------------------------------------
# Start Mongo Express port-forward
# --------------------------------------------------

echo
echo "[3/5] Checking Mongo Express..."

if ss -ltn | grep -q ":${MONGO_LOCAL_PORT} "; then
    echo "Port ${MONGO_LOCAL_PORT} is already in use."
    echo "Mongo Express may already be available at:"
    echo "http://localhost:${MONGO_LOCAL_PORT}"
else
    nohup kubectl port-forward \
        service/mongo-express-service \
        -n hotel-system \
        "${MONGO_LOCAL_PORT}:8081" \
        >"${MONGO_LOG}" 2>&1 &

    MONGO_PID=$!
    echo "${MONGO_PID}" >"${MONGO_PID_FILE}"

    sleep 2

    if kill -0 "${MONGO_PID}" 2>/dev/null; then
        echo "Mongo Express port-forward started."
        echo "PID: ${MONGO_PID}"
        echo "Log: ${MONGO_LOG}"
    else
        echo "ERROR: Mongo Express port-forward failed."
        cat "${MONGO_LOG}"
    fi
fi

# --------------------------------------------------
# Start ArgoCD port-forward
# --------------------------------------------------

echo
echo "[4/5] Checking ArgoCD..."

if ss -ltn | grep -q ":${ARGOCD_LOCAL_PORT} "; then
    echo "Port ${ARGOCD_LOCAL_PORT} is already in use."
    echo "ArgoCD may already be available at:"
    echo "https://localhost:${ARGOCD_LOCAL_PORT}"
else
    nohup kubectl port-forward \
        service/argocd-server \
        -n argocd \
        "${ARGOCD_LOCAL_PORT}:443" \
        >"${ARGOCD_LOG}" 2>&1 &

    ARGOCD_PID=$!
    echo "${ARGOCD_PID}" >"${ARGOCD_PID_FILE}"

    sleep 2

    if kill -0 "${ARGOCD_PID}" 2>/dev/null; then
        echo "ArgoCD port-forward started."
        echo "PID: ${ARGOCD_PID}"
        echo "Log: ${ARGOCD_LOG}"
    else
        echo "ERROR: ArgoCD port-forward failed."
        cat "${ARGOCD_LOG}"
    fi
fi

# --------------------------------------------------
# Show URLs
# --------------------------------------------------

echo
echo "[5/5] Pipeline360 URLs"
echo "=================================================="
echo "Frontend:     http://hotel.local:3000"
echo "Mongo Express: http://localhost:${MONGO_LOCAL_PORT}"
echo "ArgoCD:        https://localhost:${ARGOCD_LOCAL_PORT}"
echo "=================================================="
echo
echo "Port-forwards are running in the background."
