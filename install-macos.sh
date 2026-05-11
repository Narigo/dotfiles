#!/usr/bin/env zsh

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Ensure a line exists in a file. Greps for the key (everything before '=') to check.
ensure_line() {
  local file="$1" line="$2"
  local key="${line%%=*}="
  local name="${line%%=*}"
  local existing
  existing=$(grep -F "$key" "$file" 2>/dev/null || true)
  if [ -z "$existing" ]; then
    echo "$line" >> "$file"
    echo "Added to $(basename "$file"): $line"
  elif [ "$existing" = "$line" ]; then
    echo "Already set in $(basename "$file"): $name"
  else
    echo "WARNING: $name is set in $(basename "$file"), but differs:"
    echo "  Expected: $line"
    echo "  Found:    $existing"
  fi
}

# Git: add include for shared config (keeps personal user.name, email, signing intact)
INCLUDE_PATH="$DOTFILES_DIR/git/.gitconfig"
if ! git config --global --get-all include.path 2>/dev/null | grep -qF "$INCLUDE_PATH"; then
  git config --global --add include.path "$INCLUDE_PATH"
  echo "Added git include for $INCLUDE_PATH"
else
  echo "Git include already present"
fi

# Oh My Zsh custom plugins
if [ -d "$HOME/.oh-my-zsh/custom/plugins" ]; then
  for plugin_dir in "$DOTFILES_DIR"/oh-my-zsh/custom/plugins/*/; do
    plugin_name="$(basename "$plugin_dir")"
    target="$HOME/.oh-my-zsh/custom/plugins/$plugin_name"
    if [ -L "$target" ]; then
      echo "oh-my-zsh plugin already linked: $plugin_name"
    else
      ln -sn "$plugin_dir" "$target"
      echo "Linked oh-my-zsh plugin: $plugin_name"
    fi
  done

  # Ensure custom plugins are activated in .zshrc (preserves existing plugins)
  if [ -f "$HOME/.zshrc" ] && grep -qE '^plugins=\(.*\)$' "$HOME/.zshrc"; then
    current_plugins=$(grep -E '^plugins=\(.*\)$' "$HOME/.zshrc" | sed -E 's/^plugins=\((.*)\)$/\1/')
    new_plugins="$current_plugins"
    for plugin_dir in "$DOTFILES_DIR"/oh-my-zsh/custom/plugins/*/; do
      plugin_name="$(basename "$plugin_dir")"
      if [ -f "$plugin_dir/.platforms" ] && ! grep -q "macos" "$plugin_dir/.platforms"; then
        echo "Skipping plugin $plugin_name (not supported on macos)"
        continue
      fi
      if echo " $new_plugins " | grep -qF " $plugin_name "; then
        echo "oh-my-zsh plugin already activated: $plugin_name"
      else
        new_plugins="$new_plugins $plugin_name"
        echo "Activating oh-my-zsh plugin: $plugin_name"
      fi
    done
    new_plugins=$(echo "$new_plugins" | xargs)
    if [ "$current_plugins" != "$new_plugins" ]; then
      sed -i '' "s/^plugins=(.*)$/plugins=($new_plugins)/" "$HOME/.zshrc"
      echo "Updated oh-my-zsh plugins: $new_plugins"
    fi
  else
    echo "No plugins=(...) line in .zshrc, skipping activation"
  fi
else
  echo "oh-my-zsh not found, skipping plugin setup"
fi

# docker-box: run apps in Docker containers via simple aliases
DOCKER_BOX_DIR="$HOME/.docker-box"
DOCKER_BOX_APPS_DIR="$HOME/.docker-box-apps"

if [ ! -d "$DOCKER_BOX_DIR" ]; then
  git clone https://github.com/compose-us-research/docker-box.git "$DOCKER_BOX_DIR"
  chmod u+x "$DOCKER_BOX_DIR"/docker-box*.sh
  echo "Installed docker-box"
else
  echo "docker-box already installed"
fi

if [ ! -d "$DOCKER_BOX_APPS_DIR" ]; then
  git clone https://github.com/compose-us-research/docker-box-apps.git "$DOCKER_BOX_APPS_DIR"
  echo "Installed docker-box-apps"
else
  echo "docker-box-apps already installed"
fi

# docker-box env (in .zshenv so it's available everywhere, including Automator)
ensure_line "$HOME/.zshenv" 'export DOCKER_BOX_PATH="$HOME/.docker-box"'
ensure_line "$HOME/.zshenv" 'export DOCKER_BOX_APPS_PATH="$HOME/.docker-box-apps"'

# docker-box aliases (only needed in interactive shells)
ensure_line "$HOME/.zshrc" 'alias mountbox="${DOCKER_BOX_PATH}/docker-box-static-mount.sh"'
ensure_line "$HOME/.zshrc" 'alias box="${DOCKER_BOX_PATH}/docker-box.sh"'
ensure_line "$HOME/.zshrc" 'alias boxed="${DOCKER_BOX_PATH}/docker-box-script.sh"'
ensure_line "$HOME/.zshrc" 'alias dr="${DOCKER_BOX_PATH}/docker-box-run.sh"'

# Automator workflows
mkdir -p "$HOME/Library/Services"
for workflow in "$DOTFILES_DIR"/automator/*.workflow; do
  [ -d "$workflow" ] || continue
  workflow_name="$(basename "$workflow")"
  target="$HOME/Library/Services/$workflow_name"
  if [ ! -L "$target" ]; then
    ln -sf "$workflow" "$target"
    echo "Linked Automator workflow: $workflow_name"
  else
    echo "Automator workflow already linked: $workflow_name"
  fi
done

# macOS settings
read -q "REPLY?Apply macOS system settings? (y/N) " || true
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  bash "$DOTFILES_DIR/settings-macos.sh"
  echo "Applied macOS settings"
fi
