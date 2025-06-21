#!/bin/bash

# List of programs to install
programs=(
  brave-bin
  bitwarden
  youtube-music-bin
  proton-vpn-gtk-app
  discord
  telegram-desktop
  qbittorrent
  vim
  alacritty
  pfetch
  neofetch
  cpufetch
  nerdfetch
  visual-studio-code-bin
  nordic-theme
  bibata-cursor-theme
  fish
  htop
  ttf-jetbrains-mono-nerd
  gtop
  ghostty
  ttf-iosevka-nerd
  neovim
  7zip
  unrar
  git
  ventoy-bin
  tmux
  docker
  dolphin
  vlc
  mpv
  zen-browser-bin
  lua
  luarocks
  npm
  neovim
  wl-clip
  python-pip
  curl
  wget
  ripgrep
  bat
  gcc
  make
  nodejs
  fzf
  stylua
  unzip
  base-devel
  # gnome-tweaks
  # gnome-shell-extensions
  # gnome-themes-extra
  # gtk-engine-murrine
  # sassc
  #  ulauncher

)

# Arrays to track installation status
declare -a installed_packages
declare -a skipped_packages
declare -a failed_packages

# Function to check if a package is installed
is_package_installed() {
  local package=$1
  if pacman -Q "$package" &>/dev/null; then
    return 0 # Package is installed
  else
    return 1 # Package is not installed
  fi
}

# Function to install a package
install_package() {
  local package=$1

  # Skip if package is already installed
  if is_package_installed "$package"; then
    echo "$package is already installed. Skipping..."
    skipped_packages+=("$package")
    return
  fi

  echo "Checking for $package..."

  # Check if the package exists in the official repositories
  if pacman -Si "$package" &>/dev/null; then
    echo "$package found in official repositories. Installing..."
    if sudo pacman -S --noconfirm --needed "$package" &>/dev/null; then
      installed_packages+=("$package")
    else
      echo "Failed to install $package from official repositories."
      failed_packages+=("$package")
    fi
  # Check if the package exists in the AUR
  elif yay -Si "$package" &>/dev/null; then
    echo "$package found in AUR. Installing..."
    if yay -S --noconfirm "$package" &>/dev/null; then
      installed_packages+=("$package")
    else
      echo "Failed to install $package from AUR."
      failed_packages+=("$package")
    fi
  else
    echo "Error: $package not found in official repositories or AUR."
    failed_packages+=("$package")
  fi
}

# Check if yay is installed
if ! command -v yay &>/dev/null; then
  echo "Error: yay is not installed. Please install yay to proceed with AUR packages."
  exit 1
fi

# Update package databases
echo "Updating package databases..."
sudo pacman -Sy
yay -Syy

# Iterate over the list of programs and install each
for program in "${programs[@]}"; do
  install_package "$program"
done

# Print summary
echo -e "\n=== Installation Summary ==="
echo "Installed packages (${#installed_packages[@]}):"
if [ ${#installed_packages[@]} -eq 0 ]; then
  echo "  None"
else
  for pkg in "${installed_packages[@]}"; do
    echo "  - $pkg"
  done
fi

echo -e "\nSkipped packages (${#skipped_packages[@]}):"
if [ ${#skipped_packages[@]} -eq 0 ]; then
  echo "  None"
else
  for pkg in "${skipped_packages[@]}"; do
    echo "  - $pkg"
  done
fi

echo -e "\nFailed packages (${#failed_packages[@]}):"
if [ ${#failed_packages[@]} -eq 0 ]; then
  echo "  None"
else
  for pkg in "${failed_packages[@]}"; do
    echo "  - $pkg"
  done
fi

echo -e "\nInstallation process completed."
