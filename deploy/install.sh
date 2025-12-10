#!/bin/bash
# Alma Operator Installation Script
# Usage: curl -sL https://raw.githubusercontent.com/alma-security/alma-operator/main/deploy/install.sh | bash -s -- --token <GITHUB_TOKEN>

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TOKEN=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --token)
      TOKEN="$2"
      shift 2
      ;;
    --help)
      echo "Usage: $0 --token <GITHUB_TOKEN>"
      echo ""
      echo "Options:"
      echo "  --token    GitHub token for accessing private repos and images (required)"
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      exit 1
      ;;
  esac
done

if [ -z "$TOKEN" ]; then
  echo -e "${RED}Error: --token is required${NC}"
  echo "Usage: curl -sL https://raw.githubusercontent.com/alma-security/alma-operator/main/deploy/install.sh | bash -s -- --token <GITHUB_TOKEN>"
  exit 1
fi

echo -e "${GREEN}Installing Alma Operator...${NC}"

# Download and apply manifest with token substitution
echo -e "${YELLOW}Downloading and applying manifests...${NC}"
curl -sL https://raw.githubusercontent.com/alma-security/alma-operator/main/deploy/install.yaml | \
  sed "s/<GITHUB_TOKEN>/$TOKEN/g" | \
  kubectl apply -f -

# Wait for operator to be ready
echo -e "${YELLOW}Waiting for operator to be ready...${NC}"
kubectl rollout status deployment/alma-operator -n alma-system --timeout=120s

echo -e "${GREEN}✓ Alma Operator installed successfully!${NC}"
echo ""
echo "Check operator logs:"
echo "  kubectl logs -n alma-system -l app.kubernetes.io/name=alma-operator -f"
echo ""
echo "Check deployed resources:"
echo "  kubectl get all -n alma-system"
