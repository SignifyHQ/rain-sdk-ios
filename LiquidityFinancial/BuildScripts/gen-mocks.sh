#!/bin/bash
set -eu

function gen_mocks() {
  local initial_dir=$(pwd)  # Store the initial directory
  local module_path="$1"  # Path to the module where you need to create mocks

  if [[ -d "${module_path}" ]]; then
    cd "${module_path}"

    swift package plugin --list
    swift package --allow-writing-to-package-directory sourcery-command
  
  else
    echo "Directory ${module_path} does not exist"
  fi
  
  cd "$initial_dir"  # Return to the initial directory
}

gen_mocks "../Modules/LFNetwork"
gen_mocks "../Modules/LFData"
gen_mocks "../Modules/LFDomain"
