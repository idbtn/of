#!/bin/sh

set -eu

printf "Add required variables to root.hcl file\n\n"

printf "Project name: "
read PROJECT_NAME
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

exit 0
