#!/bin/sh

# Support for Apple Silicon
export PATH="$PATH:/opt/homebrew/bin:~/.mint/bin"

if [ "${CONFIGURATION}" = "Debug" ]
then
  if ! [ -x "$(command -v mint)" ]
  then
    if ! [ -x "$(command -v swiftlint)" ]
    then
      echo "error: swiftlint not installed. Run \`brew install mint \`."
      exit 1
    fi
    swiftlint
    exit 0
  fi
  mint run swiftlint
fi
