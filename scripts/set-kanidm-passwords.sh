#!/usr/bin/env bash
# Script to generate credential reset tokens for kanidm person accounts.
# Users can visit the link to set their own password or register a passkey.
#
# Usage: ./set-kanidm-passwords.sh
#
# Prerequisites:
#   - KanidmPersonAccount CRs must be reconciled (kubectl get kanidmpersonaccounts -n security)
#   - kanidm pod must be running

set -euo pipefail

NAMESPACE="security"
POD="kanidm-default-0"
DOMAIN="idm.rafaribe.com"
TTL="${1:-3600}" # Token validity in seconds (default: 1 hour)

echo "=== Kanidm Credential Reset Token Generator ==="
echo ""
echo "Generating credential reset tokens (valid for ${TTL}s)..."
echo "Users can visit the link to set their password or register a passkey."
echo ""

for USER in rafaribe filipa; do
  echo "--- ${USER} ---"
  # Generate a credential reset token via kanidmd
  TOKEN=$(kubectl exec -n "$NAMESPACE" "$POD" -- \
    kanidmd credential-reset-token "${USER}" "${TTL}" 2>/dev/null | grep -oP 'token=\K.*' || true)

  if [ -z "$TOKEN" ]; then
    # Fallback: try via the kanidm CLI with idm_admin auth
    echo "  Generating reset link..."
    kubectl exec -n "$NAMESPACE" "$POD" -- \
      kanidmd credential-reset-token "${USER}" "${TTL}" 2>&1 | tail -5
  else
    echo "  Reset URL: https://${DOMAIN}/ui/reset?token=${TOKEN}"
  fi
  echo ""
done

echo "=== Alternative: Set passwords directly ==="
echo ""
echo "If you prefer to set passwords directly, exec into the pod:"
echo ""
echo "  kubectl exec -it -n ${NAMESPACE} ${POD} -- /bin/sh"
echo ""
echo "Then recover admin and use the kanidm CLI:"
echo ""
echo "  # Get idm_admin password from secret first:"
echo "  kubectl get secret kanidm-admin-passwords -n ${NAMESPACE} -o jsonpath='{.data.IDM_ADMIN_PASSWORD}' | base64 -d"
echo ""
echo "  # Then in the pod, authenticate as idm_admin and reset credentials:"
echo "  kanidm login --name idm_admin"
echo "  kanidm person credential update rafaribe --name idm_admin"
echo "  kanidm person credential update filipa --name idm_admin"
echo ""
echo "  # Or generate reset tokens from inside the pod:"
echo "  kanidmd credential-reset-token rafaribe 3600"
echo "  kanidmd credential-reset-token filipa 3600"
