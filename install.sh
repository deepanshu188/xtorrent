#!/bin/bash

PROJECT_DIR="$HOME/.xtorrent"
LUAROCKS_DIR="$PROJECT_DIR/.modules"

# Function to check if a command is available
check_command_exists() {
  if ! command -v "$1" &>/dev/null; then
    echo "Error: $1 is not installed. Please install $1 and try again."
    exit 1
  fi
}

# Function to check if the last command was successful
check_success() {
  if [ $? -ne 0 ]; then
    echo "$1"
    exit 1
  fi
}

# Function to perform a command with a success message and failure message
perform_command() {
  local command="$1"
  local success_message="$2"
  local failure_message="$3"

  echo "$success_message..."
  eval "$command"
  check_success "$failure_message"

  echo "$success_message."
}

# Check if Git is installed
check_command_exists "git"

# Clone the xtorrent repository
perform_command "git clone https://github.com/deepanshu188/xtorrent.git" "Cloning xtorrent repository" "Failed to clone xtorrent repository"

# Rename the xtorrent directory to .xtorrent
perform_command "mv xtorrent .xtorrent" "Renaming xtorrent directory to .xtorrent" "Failed to rename directory to .xtorrent"

# Change directory into .xtorrent
perform_command "cd .xtorrent" "Changing directory into .xtorrent" "Failed to change directory into .xtorrent"

# Check if Lua is installed
check_command_exists "lua"

# Check if LuaRocks is installed
check_command_exists "luarocks"

# Create the .modules directory
perform_command "mkdir -p \"$LUAROCKS_DIR\"" "Creating .modules directory" "Failed to create .modules directory"

# Install lua-json, luasec, and luasocket using LuaRocks
PACKAGES=("json-lua" "luasec" "luasocket")

for package in "${PACKAGES[@]}"; do
  perform_command "luarocks install \"$package\" --tree=\"$LUAROCKS_DIR\"" "Installing $package" "Failed to install $package"
done

echo "All packages installed successfully."

# update the PATH variable in the user's shell configuration file

# Prompt the user to select their shell
echo "Which shell are you using?"
echo "1) Bash"
echo "2) Zsh"
echo "3) Fish"
echo "4) Other"

read -p "Enter the number corresponding to your shell: " shell_choice

case "$shell_choice" in
1)
  SHELL_TYPE="bash"
  SHELL_CONFIG_FILE="$HOME/.bashrc"
  ;;
2)
  SHELL_TYPE="zsh"
  SHELL_CONFIG_FILE="$HOME/.zshrc"
  ;;
3)
  SHELL_TYPE="fish"
  SHELL_CONFIG_FILE="$HOME/.config/fish/config.fish"
  ;;
4)
  echo "Please manually add the following line to your shell configuration file:"
  echo "export PATH=\"$PROJECT_DIR:\$PATH\""
  exit 0
  ;;
*)
  echo "Invalid choice. Please enter a valid number."
  exit 1
  ;;
esac

# Add ~/.xtorrent to PATH if not already present
if ! grep -q "export PATH=\"$PROJECT_DIR:\$PATH\"" "$SHELL_CONFIG_FILE"; then
  echo "Adding ~/.xtorrent to PATH in $SHELL_CONFIG_FILE..."
  echo "export PATH=\"$PROJECT_DIR:\$PATH\"" >>"$SHELL_CONFIG_FILE"
  echo "Added ~/.xtorrent to PATH in $SHELL_CONFIG_FILE."
else
  echo "~/.xtorrent is already in PATH in $SHELL_CONFIG_FILE."
fi

# Source the updated shell configuration file
case "$SHELL_TYPE" in
bash)
  source "$SHELL_CONFIG_FILE"
  ;;
zsh)
  source "$SHELL_CONFIG_FILE"
  ;;
fish)
  source "$SHELL_CONFIG_FILE"
  ;;
esac

echo "Installation complete."
