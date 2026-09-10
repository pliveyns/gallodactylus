#!/usr/bin/bash

set -euo pipefail

###############################################################################
# Swap GNOME Desktop with Niri Desktop
###############################################################################

# Source helper functions
# shellcheck source=/dev/null
source /ctx/build/copr-helpers.sh

echo "::group:: Remove GNOME Desktop"

# Remove GNOME Shell and related packages
dnf5 remove -y \
  gnome-shell \
  gnome-shell-extension* \
  gnome-terminal \
  gnome-software \
  gnome-control-center \
  gdm

echo "GNOME desktop removed"
echo "::endgroup::"

echo "::group:: Install Niri Desktop with DMS"

# Install Niri and DMS and recommended extras
# isolated COPR pattern to avoid leaving the COPR enabled
copr_install_isolated "yalter/niri" \
  niri
copr_install_isolated "avengemedia/dms" \
  dms
copr_install_isolated "avengemedia/danklinux" \
  dms-cli \
  dgop \
  danksearch \
  dms-greeter \
  matugen \
  quickshell
#  dankcalendar \          # This exists as Flatpak
#  dms-color-picker \
#  dmsclipboard \
#  cli11 \
#  cliphist \
#  wl-clipboard \
#  cava \
#  qt6-multimedia
#  breakpad
#  material-symbols-fonts

echo "Niri desktop installed successfully"
echo "::endgroup::"

echo "::group:: Enable DMS user service for all users"

# Ensure user unit wants directories exist and enable DMS globally
install -d /etc/systemd/user/default.target.wants /etc/systemd/user/niri.service.wants
systemctl --global enable dms.service
systemctl --global add-wants niri.service dms.service

echo "DMS user service enabled for all users"
echo "::endgroup::"

echo "::group:: Configure greetd with dms-greeter"

dnf5 install -y greetd

install -d /etc/greetd
cat >/etc/greetd/config.toml <<'EOF'
[terminal]
vt = 1

[default_session]
user = "greeter"
command = "dms-greeter --command niri"
EOF

install -d -m 755 -o greeter -g greeter /var/cache/dms-greeter

systemctl disable gdm.service lightdm.service sddm.service || true
systemctl enable greetd.service

echo "greetd configured for dms-greeter"
echo "::endgroup::"

echo "::group:: Install Additional Utilities"

# Install additional utilities that work well with Niri
dnf5 install -y \
  alacritty \
  kitty
#xdg-desktop-portal-????

echo "Additional utilities installed"
echo "::endgroup::"

echo "Niri desktop installation complete!"
