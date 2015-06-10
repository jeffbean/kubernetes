#!/usr/bin/env bash
token_dir=${TOKEN_DIR:-/srv/kubernetes}

# The business logic for whether a given object should be created
# was already enforced by salt, and /etc/kubernetes/addons is the
# managed result is of that. Start everything below that directory.
echo "== Kubernetes Generate token csv $(date -Is) =="
touch ${token_dir}/known_tokens.csv
echo -n > ${token_dir}/known_tokens.csv
# Generate tokens for other "service accounts".  Append to known_tokens.
# NB: If this list ever changes, this script actually has to
# change to detect the existence of this file, kill any deleted
# old tokens and add any new tokens (to handle the upgrade case).
service_accounts=("system:scheduler" "system:controller_manager" "system:logging" "system:monitoring" "system:dns")
for account in "${service_accounts[@]}"; do
  token=$(dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64 | tr -d "=+/" | dd bs=32 count=1 2>/dev/null)
  echo "${token},${account},${account}" >> ${token_dir}/known_tokens.csv
done
