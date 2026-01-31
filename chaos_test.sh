#!/bin/bash
echo "Starting Chaos Monkey..."

# Get a pod name
POD=$(kubectl get pod -l app=laravel,tier=web -o jsonpath="{.items[0].metadata.name}")

if [ -z "$POD" ]; then
    echo "No pods found!"
    exit 1
fi

echo "Deleting pod $POD..."
kubectl delete pod $POD --wait=false
echo "Pod deleted. Watch the stress test output for failures."
