#!/usr/bin/env bash

if [ -d ~/.bin ]; then
  echo "Already has a ~/.bin directory - return without running before script"
  return
fi

echo "RUNNING INSTALL SCRIPT"

# # Install homebrew
# echo "Installing Homebrew"
# /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# # Installing Rust
# 

# # Install mingw-w64 as Windows compiler / linker
# echo "Installing mingw-w64"
# brew install mingw-w64

# # Use mingw-w64 when targetting windows
# echo "Setting mingw-w64 as linker for windows compilation in Rust"
# echo '[target.x86_64-pc-windows-gnu]' >> ~/.cargo/config
# echo 'linker = "/usr/local/bin/x86_64-w64-mingw32-gcc"' >> ~/.cargo/config

# # The following code is necessary to compile Rust to a Windows target machine
# rustup target add x86_64-pc-windows-gnu
