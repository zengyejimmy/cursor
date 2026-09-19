#!/usr/bin/env bash
# Idempotent bootstrap for the C/C++ development environment.
#
# The base image already provides gcc/g++ 13, clang/clang++ 18, make, cmake,
# and pkg-config. This script adds the pieces missing for a complete
# build-and-debug experience:
#   * gdb                - interactive debugger (absent from the base image)
#   * libstdc++-14-dev   - libstdc++ headers for the GCC 14 toolchain that clang
#                          selects by default (otherwise clang/cmake can't find
#                          <iostream> and other standard C++ headers)
set -euo pipefail

packages=(gdb libstdc++-14-dev)
missing=()
for pkg in "${packages[@]}"; do
  if ! dpkg -s "$pkg" >/dev/null 2>&1; then
    missing+=("$pkg")
  fi
done

if [ "${#missing[@]}" -gt 0 ]; then
  echo "Installing missing packages: ${missing[*]}"
  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${missing[@]}"
else
  echo "All required packages already installed."
fi

# Print the first line of each tool's version. awk drains the whole stream,
# avoiding SIGPIPE that `head` would cause under `set -o pipefail`.
first_line() { awk 'NR==1{print}'; }

echo "C/C++ toolchain:"
gcc --version 2>&1 | first_line
g++ --version 2>&1 | first_line
clang --version 2>&1 | first_line
make --version 2>&1 | first_line
cmake --version 2>&1 | first_line
gdb --version 2>&1 | first_line
