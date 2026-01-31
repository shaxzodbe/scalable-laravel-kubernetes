#!/bin/bash
set -e

echo "Building Docker image (this may take a while)..."
docker build -t my-laravel-app:latest .

echo "Loading image into Kind cluster..."
# Use local kind if available
KIND_CMD="kind"
if [ -f "./kind" ]; then
    KIND_CMD="./kind"
fi
$KIND_CMD load docker-image my-laravel-app:latest --name laravel-test

echo "Applying ConfigMaps and Secrets..."
kubectl apply -f k8s/config/

echo "Applying Redis..."
kubectl apply -f k8s/apps/redis/
kubectl wait --for=condition=ready pod -l app=redis --timeout=60s

echo "Applying Web Application..."
kubectl apply -f k8s/apps/web/

echo "Applying Worker..."
kubectl apply -f k8s/apps/worker/

echo "Applying Network Policies..."
kubectl apply -f k8s/network-policy.yaml
kubectl apply -f k8s/redis-network-policy.yaml

echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=laravel --timeout=120s

echo "Setup complete! Run './stress_test.sh' to start testing."
echo "To expose the app, run: kubectl port-forward service/laravel-web 8080:80"
