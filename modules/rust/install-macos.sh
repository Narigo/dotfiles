#!/usr/bin/env bash

# Check if Rust is already installed - if yes, return
if [ cargo --version ]; then
  echo "Rust is already installed, returning"
  return
fi

# # Installing Rust
# ?

# # Install mingw-w64 as Windows compiler / linker
# echo "Installing mingw-w64"
# brew install mingw-w64

# # Use mingw-w64 when targetting windows
# echo "Setting mingw-w64 as linker for windows compilation in Rust"
# echo '[target.x86_64-pc-windows-gnu]' >> ~/.cargo/config
# echo 'linker = "/usr/local/bin/x86_64-w64-mingw32-gcc"' >> ~/.cargo/config

# # The following code is necessary to compile Rust to a Windows target machine
# rustup target add x86_64-pc-windows-gnu
