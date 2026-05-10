#!/bin/bash
set -euo pipefail

# --- Configuration ---
GIT_USER="iamvikshan"
GIT_EMAIL="103361575+iamvikshan@users.noreply.github.com"
DEFAULT_GL_NAMESPACE="vikshan"
# ---------------------

# Colors for UX
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Atlas Environment Bootstrap...${NC}\n"

# 1. Parse Execution Mode
IS_INTERACTIVE=true
if [[ "${1:-}" == "--default" ]]; then
  IS_INTERACTIVE=false
  echo -e "${YELLOW}Running in Headless (--default) Mode${NC}\n"
fi

# 2. Determine Context (Repository Name)
# Assumes standard structure where the folder name matches the repo name
REPO_NAME=$(basename "$PWD")
echo -e "Detected Repository: ${GREEN}${REPO_NAME}${NC}"

# 3. Establish Identity
echo -e "Configuring Git identity for ${GIT_USER}..."
git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"

# 4. Secret Waterfall (Quarantined from host OS)
GH_TOKEN=""
GL_TOKEN=""

if [ -f ".env" ]; then
  echo -e "Checking local .env for tokens..."
  # Safely extract tokens without evaluating the whole file
  GH_TOKEN=$(grep -E '^GH_TOKEN=' .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" || true)
  GL_TOKEN=$(grep -E '^GL_TOKEN=' .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" || true)
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

# 6. Setup SSH Signing Key ({repo}-{key} format)
KEY_NAME="${REPO_NAME}-id_ed25519_signing"
KEY_PATH="$HOME/.ssh/$KEY_NAME"

echo -e "\nSetting up SSH signing key (${KEY_NAME})..."
mkdir -p "$HOME/.ssh"

if [ ! -f "$KEY_PATH" ]; then
  ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$KEY_PATH" -N "" -q
  echo -e "✓ Generated new SSH signing key."
else
  echo -e "✓ SSH signing key already exists."
fi

# Configure git to sign commits with this specific key
git config user.signingkey "${KEY_PATH}.pub"
git config commit.gpgsign true

# 7. Upload SSH Key to GitHub API (Bypasses CLI auth)
if [[ -n "$GH_TOKEN" ]]; then
  echo -e "Uploading SSH public key to GitHub API..."
  PUB_KEY=$(cat "${KEY_PATH}.pub")
  
  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GH_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/user/ssh_signing_keys \
    -d "{\"title\":\"${KEY_NAME} (Atlas Auto)\",\"key\":\"${PUB_KEY}\"}")

  if [[ "$HTTP_STATUS" == "201" || "$HTTP_STATUS" == "304" || "$HTTP_STATUS" == "422" ]]; then
    # 422 usually means key already exists, which is fine
    echo -e "✓ Key successfully registered with GitHub."
  else
    echo -e "${RED}⚠️ Failed to upload key (HTTP $HTTP_STATUS). Check token permissions.${NC}"
  fi
else
  echo -e "${YELLOW}⚠️ No GH_TOKEN found. Skipping GitHub SSH key API upload.${NC}"
fi

# 8. Configure Multiple Push URLs
echo -e "\nConfiguring Git Remotes..."

# Base URLs
GH_URL="github.com/${GIT_USER}/${REPO_NAME}.git"
# Embed tokens if they exist, otherwise use standard HTTPS
if [[ -n "$GH_TOKEN" ]]; then
  GH_REMOTE="https://${GH_TOKEN}@${GH_URL}"
else
  GH_REMOTE="https://${GH_URL}"
fi

# Set origin fetch URL (always GitHub)
git remote set-url origin "$GH_REMOTE" 2>/dev/null || git remote add origin "$GH_REMOTE"

# Git multiple push URLs mechanic: 
# Once you add a push URL, the fetch URL is no longer used for pushing.
# Therefore, we MUST add GitHub explicitly as the first push URL.
git config --unset-all remote.origin.pushurl || true
git remote set-url --add --push origin "$GH_REMOTE"

echo -e "✓ GitHub configured."

# Add GitLab if not skipped
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
trap 'rm -rf "$TMP_DIR"' EXIT

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
echo -e "${GREEN}✓ Atlas Setup Complete!${NC}"
echo -e "${GREEN}==========================================${NC}"
echo -e "Identity: $(git config user.name) <$(git config user.email)>"
echo -e "Signing Key: ${KEY_NAME}"
if [[ "$IS_INTERACTIVE" == "false" && -z "$GH_TOKEN" ]]; then
  echo -e "\n${YELLOW}Note: Ran in headless mode without tokens.${NC}"
  echo -e "To authenticate remotes and upload SSH keys, run:"
  echo -e "  ${GREEN}scripts/bootstrap.sh${NC}"
fi
echo ""