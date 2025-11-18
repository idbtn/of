#!/bin/sh

set -eu

printf "Add required variables to root.hcl file\n\n"

printf "Project name: "
read PROJECT_NAME
printf "Environment(e.g. dev): "
read ENVIRONMENT_NAME
printf "EKS Version: "
read EKS_VERSION
printf "AWS region: "
read AWS_REGION
printf "AWS allowed account ID: "
read AWS_ALLOWED_ACCOUNT_ID
printf "S3 state bucket: "
read S3_BUCKET

tmpfile=$(mktemp)
sed \
  -e "s|^\([[:space:]]*project_name[[:space:]]*=[[:space:]]*\).*|\1\"$PROJECT_NAME\"|" \
  -e "s|^\([[:space:]]*aws_region[[:space:]]*=[[:space:]]*\).*|\1\"$AWS_REGION\"|" \
  -e "s|^\([[:space:]]*aws_allowed_account_id[[:space:]]*=[[:space:]]*\).*|\1\"$AWS_ALLOWED_ACCOUNT_ID\"|" \
  -e "s|^\([[:space:]]*bucket[[:space:]]*=[[:space:]]*\).*|\1\"$S3_BUCKET\"|" \
  ./v5/infrastructure-live-v5/root.hcl > "$tmpfile"

mv "$tmpfile" ./v5/infrastructure-live-v5/root.hcl

tmpfile=$(mktemp)
sed \
  -e "s|^\([[:space:]]*eks_version[[:space:]]*=[[:space:]]*\).*|\1\"$EKS_VERSION\"|" \
  -e "s|^\([[:space:]]*env[[:space:]]*=[[:space:]]*\).*|\1\"$ENVIRONMENT_NAME\"|" \
  ./v5/infrastructure-live-v5/dev/env.hcl > "$tmpfile"

mv "$tmpfile" ./v5/infrastructure-live-v5/dev/env.hcl

exit 0
