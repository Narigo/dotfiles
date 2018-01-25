#!/usr/bin/env bash

(

main() {
  select_platform

  echo "Platform is '$platform'."

  if [ "$platform" != "" ]; then
    settings_script="settings-${platform}.sh"
    install_module "shell"
    if [ -e "./$settings_script" ]; then
      echo "Setting settings from $settings_script"
      . "$settings_script"
    fi
  fi
}

install_module() {
  moduleName=$1;
  echo "Installing module $moduleName"

  if [ -e "modules/${moduleName}/concat-file.txt" ]; then
    fileName=`cat "modules/${moduleName}/concat-file.txt"`
    rm $HOME/$fileName
    echo "Writing into $HOME/$fileName"
    cat "modules/$moduleName/$platform/"* >> "$HOME/$fileName"
  fi
}

select_platform() {
  echo "Please select your platform:"
  OPTIONS="macos linux Quit"
  select opt in $OPTIONS; do
    if [ "$opt" = "Quit" ]; then
      exit
    elif [ "$opt" = "macos" ]; then
      platform="macos"
      return
    elif [ "$opt" = "linux" ]; then
      platform="linux"
      return
    else
      echo bad option
    fi
  done
}

main

)
