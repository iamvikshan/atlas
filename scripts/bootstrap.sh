#!/bin/bash
set -euo pipefail

# --- Configuration ---
GIT_USER="iamvikshan"
GIT_EMAIL="103361575+iamvikshan@users.noreply.github.com"
DEFAULT_GL_NAMESPACE="vikshan"
MAX_SSH_KEYS=10
# ---------------------

# Colors for UX
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Global state for cleanup
TMP_DIR=""
JQ_INSTALLED_BY_US=false

# Auto-cleanup trap (runs on exit, success, or failure)
cleanup() {
  if [[ -n "$TMP_DIR" && -d "$TMP_DIR" ]]; then
    rm -rf "$TMP_DIR"
  fi
  if [[ "$JQ_INSTALLED_BY_US" == "true" ]]; then
    echo -e "\nCleaning up temporary dependencies..."
    SUDO=""
    if [ "$EUID" -ne 0 ] && command -v sudo &> /dev/null; then SUDO="sudo"; fi
    $SUDO apt-get remove -y jq -qq 2>/dev/null || true
    echo -e "✓ jq removed."
  fi
}
trap cleanup EXIT

echo -e "${GREEN}Starting Environment Bootstrap...${NC}\n"

# 1. Parse Execution Mode
IS_INTERACTIVE=true
if [[ "${1:-}" == "--default" ]]; then
  IS_INTERACTIVE=false
  echo -e "${YELLOW}Running in Headless (--default) Mode${NC}\n"
fi

# 2. Determine Context (Repository Name & Host)
REPO_NAME=$(basename "$PWD")
if [[ -n "${CODESPACE_NAME:-}" ]]; then
  HOST_ID="$CODESPACE_NAME"
else
  HOST_ID=$(hostname -s 2>/dev/null || echo "local-machine")
fi

echo -e "Detected Repository: ${GREEN}${REPO_NAME}${NC}"
echo -e "Detected Host: ${GREEN}${HOST_ID}${NC}"

# 3. Establish Identity
echo -e "\nConfiguring Git identity for ${GIT_USER}..."
git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"

# 4. Secret Waterfall (Quarantined from host OS)
# Accept either standard token name from the environment first
GH_TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
GL_TOKEN="${GL_TOKEN:-${GITLAB_TOKEN:-}}"

if [ -f ".env" ]; then
  echo -e "Checking local .env for tokens..."
  if [[ -z "$GH_TOKEN" ]]; then
    GH_TOKEN=$(grep -E '^(GH_TOKEN|GITHUB_TOKEN)=' .env | head -1 | cut -d '=' -f2 | tr -d '"' | tr -d "'" || true)
  fi
  if [[ -z "$GL_TOKEN" ]]; then
    GL_TOKEN=$(grep -E '^(GL_TOKEN|GITLAB_TOKEN)=' .env | head -1 | cut -d '=' -f2 | tr -d '"' | tr -d "'" || true)
  fi
fi

# Interactive Prompt for missing tokens (if not headless)
if [[ "$IS_INTERACTIVE" == "true" ]]; then
  if [[ -z "$GH_TOKEN" ]]; then
    read -sp "Enter GitHub PAT (GH_TOKEN) [Leave blank to skip]: " GH_TOKEN
    echo ""
  fi
  if [[ -z "$GL_TOKEN" ]]; then
    read -sp "Enter GitLab PAT (GL_TOKEN) [Leave blank to skip]: " GL_TOKEN
    echo ""
  fi
fi

# 5. Determine GitLab Namespace
GL_NAMESPACE="$DEFAULT_GL_NAMESPACE"
if [[ "$IS_INTERACTIVE" == "true" ]]; then
  read -p "Map GitLab mirror to '${DEFAULT_GL_NAMESPACE}/${REPO_NAME}'? [Y/n/skip]: " gl_choice
  case "$gl_choice" in
    [Nn]*)
      read -p "Enter target GitLab namespace (e.g., mapedie): " GL_NAMESPACE
      ;;
    "skip")
      GL_NAMESPACE="SKIP"
      ;;
  esac
fi

# 6. Setup SSH Signing Key ({host}-key format)
KEY_NAME="atlas-${HOST_ID}-signing"
KEY_PATH="$HOME/.ssh/$KEY_NAME"

echo -e "\nSetting up SSH signing key (${KEY_NAME})..."
mkdir -p "$HOME/.ssh"

if [ ! -f "$KEY_PATH" ]; then
  ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$KEY_PATH" -N "" -q
  echo -e "✓ Generated new SSH signing key."
else
  echo -e "✓ SSH signing key already exists."
fi

git config --global gpg.format ssh
git config --global user.signingkey "${KEY_PATH}.pub"
git config --global commit.gpgsign true

# --- Helper Functions for GitHub API ---

ensure_jq() {
  if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}jq is required for API parsing but not installed. Attempting temporary installation...${NC}"
    if command -v apt-get &> /dev/null; then
      SUDO=""
      if [ "$EUID" -ne 0 ] && command -v sudo &> /dev/null; then SUDO="sudo"; fi
      
      # Suppress apt output to keep terminal clean
      $SUDO apt-get update -qq 2>/dev/null || true
      if $SUDO apt-get install -y jq -qq 2>/dev/null; then
        JQ_INSTALLED_BY_US=true
        echo -e "✓ jq temporarily installed."
      else
        echo -e "${RED}⚠️ Failed to install jq. SSH key pruning will be skipped.${NC}"
        return 1
      fi
    else
      echo -e "${RED}⚠️ Package manager not found. SSH key pruning will be skipped.${NC}"
      return 1
    fi
  fi
  return 0
}

prune_ssh_signing_keys() {
  echo -e "\nChecking SSH signing keys limit (Max: $MAX_SSH_KEYS)..."
  ensure_jq || return 0

  local keys_json
  keys_json=$(curl -s -H "Accept: application/vnd.github+json" \
                     -H "Authorization: Bearer $GH_TOKEN" \
                     -H "X-GitHub-Api-Version: 2022-11-28" \
                     https://api.github.com/user/ssh_signing_keys)

  local key_count
  key_count=$(echo "$keys_json" | jq '. | length' 2>/dev/null || echo "0")

  if [[ "$key_count" -gt "$MAX_SSH_KEYS" ]]; then
    local delete_count=$((key_count - MAX_SSH_KEYS))
    echo -e "⚠️ Found $key_count keys. Pruning the oldest $delete_count..."

    # Extract IDs of the oldest keys (sorted by created_at)
    local old_keys
    old_keys=$(echo "$keys_json" | jq -r "sort_by(.created_at) | .[0:${delete_count}] | .[].id")

    for key_id in $old_keys; do
      curl -s -o /dev/null -X DELETE \
           -H "Accept: application/vnd.github+json" \
           -H "Authorization: Bearer $GH_TOKEN" \
           -H "X-GitHub-Api-Version: 2022-11-28" \
           "https://api.github.com/user/ssh_signing_keys/${key_id}"
      echo -e "  ✓ Deleted key ID: $key_id"
    done
  else
    echo -e "  ✓ Key count ($key_count) is within limits."
  fi
}

# 7. Upload SSH Key to GitHub API & Prune
if [[ -n "$GH_TOKEN" ]]; then
  echo -e "\nUploading SSH public key to GitHub API..."
  PUB_KEY=$(cat "${KEY_PATH}.pub")
  
  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GH_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/user/ssh_signing_keys \
    -d "{\"title\":\"${KEY_NAME}\",\"key\":\"${PUB_KEY}\"}")

  if [[ "$HTTP_STATUS" == "201" || "$HTTP_STATUS" == "304" || "$HTTP_STATUS" == "422" ]]; then
    echo -e "✓ Key successfully registered with GitHub."
    prune_ssh_signing_keys
  else
    echo -e "${RED}⚠️ Failed to upload key (HTTP $HTTP_STATUS). Check token permissions.${NC}"
  fi
else
  echo -e "${YELLOW}\n⚠️ No GH_TOKEN found. Skipping GitHub SSH key API upload and pruning.${NC}"
fi

# 8. Configure Multiple Push URLs
echo -e "\nConfiguring Git Remotes..."

GH_URL="github.com/${GIT_USER}/${REPO_NAME}.git"
if [[ -n "$GH_TOKEN" ]]; then
  GH_REMOTE="https://${GH_TOKEN}@${GH_URL}"
else
  GH_REMOTE="https://${GH_URL}"
fi

git remote set-url origin "$GH_REMOTE" 2>/dev/null || git remote add origin "$GH_REMOTE"
git config --unset-all remote.origin.pushurl || true
git remote set-url --add --push origin "$GH_REMOTE"
echo -e "✓ GitHub configured."

if [[ "$GL_NAMESPACE" != "SKIP" ]]; then
  GL_URL="gitlab.com/${GL_NAMESPACE}/${REPO_NAME}.git"
  if [[ -n "$GL_TOKEN" ]]; then
    GL_REMOTE="https://oauth2:${GL_TOKEN}@${GL_URL}"
  else
    GL_REMOTE="https://${GL_URL}"
  fi
  
  git remote set-url --add --push origin "$GL_REMOTE"
  echo -e "✓ GitLab mirror configured (${GL_NAMESPACE}/${REPO_NAME})."
fi

# 9. Fetch and Apply Git Hooks
echo -e "\nFetching Git Hooks from Atlas..."
TMP_DIR=$(mktemp -d)

git clone --depth 1 --filter=blob:none --sparse https://github.com/iamvikshan/atlas.git "$TMP_DIR" -q
git -C "$TMP_DIR" sparse-checkout set scripts/hooks -q

mkdir -p scripts/hooks
if [ -d "$TMP_DIR/scripts/hooks" ]; then
  cp -R "$TMP_DIR/scripts/hooks/"* scripts/hooks/ 2>/dev/null || true
  cp -R "$TMP_DIR/scripts/hooks/".* scripts/hooks/ 2>/dev/null || true
  echo -e "✓ Hooks successfully installed."
else
  echo -e "${YELLOW}⚠️ Hooks directory not found in Atlas repo.${NC}"
fi

# 10. Final Summary
echo -e "\n${GREEN}==========================================${NC}"
echo -e "${GREEN}✓ Environ Setup Complete!${NC}"
echo -e "${GREEN}==========================================${NC}"
echo -e "Identity: $(git config user.name) <$(git config user.email)>"
echo -e "Signing Key: ${KEY_NAME}"
if [[ "$IS_INTERACTIVE" == "false" && -z "$GH_TOKEN" ]]; then
  echo -e "\n${YELLOW}Note: Ran in headless mode without tokens.${NC}"
  echo -e "To authenticate remotes and upload SSH keys, run:"
  echo -e "  ${GREEN}scripts/bootstrap.sh${NC}"
fi
echo ""