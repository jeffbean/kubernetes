#!/bin/bash

# Copyright 2015 The Kubernetes Authors All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

token_dir=${TOKEN_DIR:-/var/srv/kubernetes}

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
