#!/bin/bash

PROJECT_DIR=$(pwd)
LUAROCKS_DIR="$PROJECT_DIR/.modules"

lua_version=$(ls .modules/share/lua)

mkdir -p "$LUAROCKS_DIR"

# Check if the directory was created successfully
if [ $? -ne 0 ]; then
  echo "Failed to create .modules directory."
  exit 1
fi

echo "Successfully created .modules directory."

# Install lua-json, luasec, and luasocket using LuaRocks
PACKAGES=("json-lua" "luasec" "luasocket")

for package in "${PACKAGES[@]}"; do
  echo "Installing $package..."
  luarocks install "$package" --tree="$LUAROCKS_DIR"

  # Check if the installation was successful
  if [ $? -ne 0 ]; then
    echo "Failed to install $package."
    exit 1
  fi

  echo "Successfully installed $package."
done

echo "All packages installed successfully."
