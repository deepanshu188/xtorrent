#!/bin/bash

PROJECT_DIR=$(pwd)
LUAROCKS_DIR="$PROJECT_DIR/.modules"

# Check if Git is installed
if ! command -v git &>/dev/null; then
  echo "Error: Git is not installed. Please install Git and try again."
  exit 1
fi

# Clone the xtorrent repository
echo "Cloning xtorrent repository..."
git clone https://github.com/deepanshu188/xtorrent.git

# Check if the clone was successful
if [ $? -ne 0 ]; then
  echo "Failed to clone xtorrent repository."
  exit 1
fi

echo "Successfully cloned xtorrent repository."

# Change directory into xtorrent
cd xtorrent

# Check if the directory change was successful
if [ $? -ne 0 ]; then
  echo "Failed to change directory into xtorrent."
  exit 1
fi

echo "Successfully changed directory into xtorrent."

# Check if Lua is installed
if ! command -v lua &>/dev/null; then
  echo "Error: Lua is not installed. Please install Lua and try again."
  exit 1
fi

# Check if LuaRocks is installed
if ! command -v luarocks &>/dev/null; then
  echo "Error: LuaRocks is not installed. Please install LuaRocks and try again."
  exit 1
fi

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
