#!/bin/bash
set -eu

function gen_mocks() {
  local module_path="$1"

  if [[ -d "${module_path}" ]]; then
    cd "${module_path}"

    swift package plugin --list
    swift package --allow-writing-to-package-directory sourcery-command
  
  else
    echo "Directory ${module_path} does not exist"
  fi
}

gen_mocks "../Modules/LFNetwork"
gen_mocks "../Modules/LFData"