#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/terraform"

terraform -chdir="${TF_DIR}" init -backend-config=backend.hcl
terraform -chdir="${TF_DIR}" destroy
