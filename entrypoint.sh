#!/bin/bash
set -e

# Configure git to use GH_TOKEN for HTTPS GitHub auth
# ~/.gitconfig is a read-only bind mount, so write to a temp file instead
cp "$HOME/.gitconfig" /tmp/.gitconfig 2>/dev/null || touch /tmp/.gitconfig
export GIT_CONFIG_GLOBAL=/tmp/.gitconfig
if [ -n "$GH_TOKEN" ]; then
    git config --file /tmp/.gitconfig url."https://x-access-token:${GH_TOKEN}@github.com/".insteadOf "https://github.com/"
fi

# Fix SSH key permissions (bind-mounted as ro, may have wrong perms)
if [ -d "$HOME/.ssh" ]; then
    mkdir -p /tmp/.ssh
    cp "$HOME/.ssh/"* /tmp/.ssh/ 2>/dev/null || true
    chmod 700 /tmp/.ssh
    chmod 600 /tmp/.ssh/* 2>/dev/null || true
    chmod 644 /tmp/.ssh/*.pub 2>/dev/null || true
    export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no -i /tmp/.ssh/id_ed25519 -i /tmp/.ssh/id_rsa 2>/dev/null"
fi

# Seed conda volume on first run (named volume starts empty)
if [ ! -f /opt/conda/bin/conda ]; then
    echo "Seeding conda volume from image..."
    cp -a /opt/conda.seed/. /opt/conda/
fi

# Update claude-code
echo "Updating claude-code..."
sudo npm install -g @anthropic-ai/claude-code@latest 2>/dev/null || true

# Update galaxy-mcp (pull latest)
echo "Updating galaxy-mcp..."
uvx --from galaxy-mcp galaxy-mcp --help >/dev/null 2>&1 || true

# Clone or update galaxy-skills
SKILLS_DIR="$HOME/.claude/skills/galaxy"
if [ -d "$SKILLS_DIR/.git" ]; then
    echo "Updating galaxy-skills..."
    GIT_TERMINAL_PROMPT=0 git -C "$SKILLS_DIR" pull --ff-only 2>/dev/null || true
else
    echo "Cloning galaxy-skills..."
    mkdir -p "$HOME/.claude/skills"
    GIT_TERMINAL_PROMPT=0 git clone https://github.com/galaxyproject/galaxy-skills.git "$SKILLS_DIR" 2>/dev/null || true
fi

# Register Galaxy MCP server if not already configured
if ! claude mcp list 2>/dev/null | grep -q "galaxy"; then
    echo "Registering Galaxy MCP server..."
    claude mcp add galaxy -- uvx galaxy-mcp 2>/dev/null || true
fi

exec claude --dangerously-skip-permissions "$@"
