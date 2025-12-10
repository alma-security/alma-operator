#!/bin/bash
set -e

TOKEN=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --token) TOKEN="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [ -z "$TOKEN" ]; then
  echo "Error: --token is required"
  exit 1
fi

curl -sL https://raw.githubusercontent.com/alma-security/alma-operator/main/deploy/install.yaml | \
sed "s/<GITHUB_TOKEN>/$TOKEN/g" | \
kubectl apply -f -

echo "Alma Operator installed. Watching logs..."
kubectl rollout status deployment/alma-operator -n alma-system --timeout=120s