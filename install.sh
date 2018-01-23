#!/usr/bin/env bash

isMacOs=`[ -e "/Applications" ] && echo true || echo false`

if [ $isMacOs = "true" ]; then
  platform="macos"
else
  platform="linux"
fi

echo "Platform is '$platform'."

install_module "shell"


function install_module() {
  moduleName=$1;
  echo "Installing module $moduleName"

  if [ -e "modules/${moduleName}/concat-file.txt" ]; then
    fileName=`cat "modules/${moduleName}/concat-file.txt"`
    rm $HOME/$fileName
    echo "Writing into $HOME/$fileName"
    cat "modules/$moduleName/$platform/"* >> "$HOME/$fileName"
  fi
}
