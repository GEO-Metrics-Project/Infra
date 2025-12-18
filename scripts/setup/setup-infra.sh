#!/bin/bash
set -euo pipefail

# Colors and logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}✓${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1" >&2; }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; }
log_step() { echo -e "${BLUE}==>${NC} $1"; }

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Infra Namespace
INFRA_NAMESPACE="geo-infra"

# Create infra namespace if it doesn't exist
create_namespace() {
    log_step "Ensuring infra namespace exists"

    if kubectl get namespace "$INFRA_NAMESPACE" &>/dev/null; then
        log_info "Namespace '$INFRA_NAMESPACE' already exists"
    else
        kubectl create namespace "$INFRA_NAMESPACE"
        log_info "Created namespace '$INFRA_NAMESPACE'"
    fi
}

# Install and configure MetalLB using Helm
setup_metallb() {
    log_step "Installing MetalLB with Helm"

    # Install MetalLB if not present
    if ! helm list -n metallb-system | grep -q "^metallb"; then
        helm install metallb metallb/metallb --namespace metallb-system --create-namespace
        log_info "MetalLB installed via Helm"
    else
        log_info "MetalLB already installed via Helm"
    fi

    # Apply MetalLB config
    if kubectl get ipaddresspool -n metallb-system my-ip-pool &>/dev/null; then
        log_info "MetalLB IPAddressPool already configured"
    else
        kubectl apply -f "$PROJECT_ROOT/k8s/metallb/metallb.yaml"
        log_info "Applied MetalLB configuration"
    fi
}

if [[ $# -gt 0 ]]; then
    "$@"
fi