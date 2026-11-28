#!/usr/bin/env bash
# Usage: source terraform/env.sh
# Short-lived Terraform credentials (IAM token, up to 12 hours) for the
# "coursework" folder, plus the Object Storage key for the remote state.

SA_ID="$(yc iam service-account get --name terraform-sa --folder-name portfolio --format json \
  | python3 -c 'import json,sys; print(json.load(sys.stdin)["id"])')"
if [ -z "$SA_ID" ]; then
  echo "Error: service account terraform-sa not found in folder portfolio" >&2
  return 1 2>/dev/null || exit 1
fi
YC_TOKEN="$(yc iam create-token --impersonate-service-account-id "$SA_ID")"
YC_CLOUD_ID="$(yc config get cloud-id)"
YC_FOLDER_ID="$(yc resource-manager folder get coursework --format json \
  | python3 -c 'import json,sys; print(json.load(sys.stdin)["id"])')"
export YC_TOKEN YC_CLOUD_ID YC_FOLDER_ID

# Static access key for the state bucket; kept outside the repository.
S3_ENV="${HOME}/.config/portfolio/s3.env"
if [ -f "$S3_ENV" ]; then
  set -a
  # shellcheck source=/dev/null
  . "$S3_ENV"
  set +a
else
  echo "Warning: ${S3_ENV} not found, the remote state will not work" >&2
fi

echo "Terraform credentials are set for folder ${YC_FOLDER_ID}"
