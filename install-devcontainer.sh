#!/usr/bin/env bash

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

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
  # Ensure plugins are activated in .zshrc
  DEVCONTAINER_PLUGINS=(git pw2cb)
  for plugin in "${DEVCONTAINER_PLUGINS[@]}"; do
    if grep -q "^plugins=(" "$HOME/.zshrc" 2>/dev/null; then
      if ! grep "^plugins=(" "$HOME/.zshrc" | grep -q "$plugin"; then
        sed -i "s/^plugins=(\(.*\))/plugins=(\1 $plugin)/" "$HOME/.zshrc"
        echo "Activated oh-my-zsh plugin: $plugin"
      else
        echo "oh-my-zsh plugin already active: $plugin"
      fi
    else
      echo "plugins=($plugin)" >> "$HOME/.zshrc"
      echo "Created plugins list with: $plugin"
    fi
  done
else
  echo "oh-my-zsh not found, skipping plugin setup"
fi
