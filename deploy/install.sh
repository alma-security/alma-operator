#!/bin/bash
# Alma Operator Installation Script
# Usage: curl -sL https://raw.githubusercontent.com/alma-security/alma-operator/main/deploy/install.sh | bash -s -- --token <GITHUB_TOKEN> --customer-id <CUSTOMER_ID>

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TOKEN=""
CUSTOMER_ID=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --token)
      TOKEN="$2"
      shift 2
      ;;
    --customer-id)
      CUSTOMER_ID="$2"
      shift 2
      ;;
    --help)
      echo "Usage: $0 --token <GITHUB_TOKEN> --customer-id <CUSTOMER_ID>"
      echo ""
      echo "Options:"
      echo "  --token        GitHub token for accessing private repos and images (required)"
      echo "  --customer-id  Your customer ID provided by Alma Security (required)"
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
  echo "Usage: $0 --token <GITHUB_TOKEN> --customer-id <CUSTOMER_ID>"
  exit 1
fi

if [ -z "$CUSTOMER_ID" ]; then
  echo -e "${RED}Error: --customer-id is required${NC}"
  echo "Usage: $0 --token <GITHUB_TOKEN> --customer-id <CUSTOMER_ID>"
  exit 1
fi

echo -e "${GREEN}Installing Alma Operator for customer: ${CUSTOMER_ID}${NC}"

# Download and apply manifest with token and customer-id substitution
echo -e "${YELLOW}Downloading and applying manifests...${NC}"
curl -sL https://raw.githubusercontent.com/alma-security/alma-operator/main/deploy/install.yaml | \
  sed "s/<GITHUB_TOKEN>/$TOKEN/g" | \
  sed "s/<CUSTOMER_ID>/$CUSTOMER_ID/g" | \
  kubectl apply -f -

# Wait for operator to be ready
echo -e "${YELLOW}Waiting for operator to be ready...${NC}"
kubectl rollout status deployment/alma-operator -n alma-system --timeout=120s

echo -e "${GREEN}✓ Alma Operator installed successfully!${NC}"
echo ""
echo "Customer ID: ${CUSTOMER_ID}"
echo ""
echo "Check operator logs:"
echo "  kubectl logs -n alma-system -l app.kubernetes.io/name=alma-operator -f"
echo ""
echo "Check deployed resources:"
echo "  kubectl get all -n alma-system"
