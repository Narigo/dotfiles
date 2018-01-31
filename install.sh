#!/usr/bin/env bash

(

set -e

main() {
  dry_run=`[ "$1" == "-d" ] && echo true || echo false`

  platform=""

  if $dry_run ; then
    echo "Dry Run!"
  fi
  select_platform

  if [ "$platform" != "" ]; then
    echo "Platform is '$platform'."
    settings_script="settings-${platform}.sh"

    install_module "shell" "$platform" $dry_run
    install_module "git" "$platform" $dry_run

    if [ -e "./$settings_script" ] && ! $dry_run; then
      echo "Setting settings from $settings_script"
      . "$settings_script"
    fi
  fi
}

install_module() {
  module_name=$1;
  platform=$2;
  dry_run=$3;

  platform_file="modules/${module_name}/file-${platform}"
  should_copy_files="modules/${module_name}/.copy-files-to-${platform}"

  if [ -e "$platform_file" ]; then
    echo "Concatenating files from $module_name into $platform_file"
    file_name=`echo $(eval echo $(cat "$platform_file"))`

    if $dry_run ; then
      file_name=".dry_run/$file_name"
    fi

    # Back up file before overwriting
    if [ -f $file_name ] && ! $dry_run; then
      echo "Backing up $file_name into .backups/$file_name"
      mkdir -p `dirname ".backups/$file_name"`
      cp "$file_name" ".backups/$file_name"
    fi

    echo "Making sure directory of $file_name exists"
    mkdir -p `dirname "$file_name"`

    echo "Writing into $file_name"
    echo -n "" > "$file_name"
    if [ -d "modules/$module_name/all" ]; then
      echo "Writing platform agnostic things into $file_name"
      cat "modules/$module_name/all/"* >> "$file_name"
    fi
    cat "modules/$module_name/$platform/"* >> "$file_name"

  elif [ -e "$should_copy_files" ]; then
    copy_files_to=`echo $(eval echo $(cat $should_copy_files))`

    if $dry_run ; then
      copy_files_to=".dry_run/$copy_files_to"
    fi

    module_dir="modules/$module_name"
    echo "Copying files from $module_dir to $copy_files_to"
    if [ -d "$module_dir/all" ]; then
      echo "Copying platform agnostic files"
      copy_files "$module_dir/all" "$copy_files_to"
    fi
    if [ -d "$module_dir/$platform" ]; then
      echo "Copying platform specific files"
      copy_files "$module_dir/$platform" "$copy_files_to"
    fi

  else
    echo "Could not find installation file for platform $platform (looked for $platform_file)"
  fi
}

copy_files() {
  from_dir="$1"
  to_dir="$2"

  echo "Creating directory $to_dir if it does not exist"
  mkdir -p "$to_dir"
  for file_name in `ls -1A "$from_dir"`; do
    from="$from_dir/$file_name"
    to="$to_dir/$file_name"

    # Back up file before overwriting
    if [ -f $to ] && ! $dry_run; then
      echo "Backing up $to into .backups/$to"
      mkdir -p `dirname ".backups/$to"`
      cp "$to" ".backups/$to"
    fi

    echo "Copying $from to $to"
    cp "$from" "$to"
  done
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

main $@

)
