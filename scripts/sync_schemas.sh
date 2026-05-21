#!/usr/bin/env bash
set -euo pipefail

# Define local air-gapped schema storage matrix destination
SCHEMA_DIR="${HOME}/.config/nvim/schemas"
mkdir -p "${SCHEMA_DIR}"

echo "Initializing offline JSON Schema Store download sequence..."

# Key-Value pair map array: [Local_Filename]="Remote_URL"
declare -A SCHEMAS=(
  ["kustomization.json"]="https://json.schemastore.org/kustomization.json"

  # Flux Engine Stack
  ["flux-kustomization.json"]="https://raw.githubusercontent.com/fluxcd-community/flux2-schemas/main/kustomization-kustomize-v1.json"
  ["flux-helmrelease.json"]="https://raw.githubusercontent.com/fluxcd-community/flux2-schemas/main/helmrelease-helm-v2.json"
  ["flux-helmrepository.json"]="https://raw.githubusercontent.com/fluxcd-community/flux2-schemas/main/helmrepository-helm-v1.json"

  # Gateway API Matrix
  ["gateway-httproute.json"]="https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/gateway.networking.k8s.io/httproute_v1.json"
  ["gateway-gateway.json"]="https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/gateway.networking.k8s.io/gateway_v1.json"

  # External Secrets / OpenBao Boundary (Updated to full unstripped schemas containing description fields)
  ["external-secrets-clustersecretstore.json"]="https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master-standalone-strict/clustersecretstore-external-secrets-v1beta1.json"
  ["external-secrets-externalsecret.json"]="https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master-standalone-strict/externalsecret-external-secrets-v1beta1.json"

  # VictoriaMetrics (Core & Scrapers)
  ["vm-vmsingle.json"]="https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/operator.victoriametrics.com/vmsingle_v1beta1.json"
  ["vm-vmagent.json"]="https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/operator.victoriametrics.com/vmagent_v1beta1.json"
  ["vm-vmpodscrape.json"]="https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/operator.victoriametrics.com/vmpodscrape_v1beta1.json"
  ["vm-vmnodescrape.json"]="https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/operator.victoriametrics.com/vmnodescrape_v1beta1.json"
  ["vm-vmstaticscrape.json"]="https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/operator.victoriametrics.com/vmstaticscrape_v1beta1.json"

  # VictoriaMetrics (Alerting & Auth)
  ["vm-vmrule.json"]="https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/operator.victoriametrics.com/vmrule_v1beta1.json"
  ["vm-vmalert.json"]="https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/operator.victoriametrics.com/vmalert_v1beta1.json"
  ["vm-vmalertmanager.json"]="https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/operator.victoriametrics.com/vmalertmanager_v1beta1.json"
  ["vm-vmauth.json"]="https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/operator.victoriametrics.com/vmauth_v1beta1.json"

  # Cilium Security & Core Networking
  ["cilium-cnp.json"]="https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/cilium.io/ciliumnetworkpolicy_v2.json"
  ["cilium-ccnp.json"]="https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/cilium.io/ciliumclusterwidenetworkpolicy_v2.json"
  ["cilium-ippool.json"]="https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/cilium.io/ciliumloadbalancerippool_v2alpha1.json"
  ["cilium-l2policy.json"]="https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/cilium.io/ciliuml2announcementpolicy_v2alpha1.json"
)

for FILE in "${!SCHEMAS[@]}"; do
  URL="${SCHEMAS[$FILE]}"
  echo "Fetching ${FILE}..."
  curl -sSL "${URL}" -o "${SCHEMA_DIR}/${FILE}"
done

echo "Air-gapped schema cache generation sequence complete."
