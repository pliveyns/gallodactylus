#!/usr/bin/env bash

set -euo pipefail

###############################################################################
# Replace GNOME with the Niri desktop
###############################################################################

echo "::group:: Install Niri"

# cosmic-session pulls the compositor, panel, settings, files, terminal and,
# with them, cosmic-greeter and xdg-desktop-portal-cosmic. The lines after it
# are the genuinely optional apps.
dnf5 install -y \
  niri \
  noctalia

dnf5 install -y --nogpgcheck --repofrompath \
  'terra,https://repos.fyralabs.com/terra$releasever' terra-release
dnf5 install -y \
  noctalia-greeter

echo "::endgroup::"

echo "::group:: Remove GNOME"

# gnome-session-wayland-session and gnome-classic-session own the files in
# /usr/share/wayland-sessions. Leaving them behind would keep offering GNOME
# sessions at the login screen that can no longer start. mutter and gnome-session
# are removed too: without them nothing is left that could try to bring GNOME up.
dnf5 remove -y \
  gnome-shell \
  "gnome-shell-extension*" \
  mutter \
  gnome-session \
  gnome-session-wayland-session \
  gnome-classic-session \
  gnome-control-center \
  gnome-software \
  nautilus \
  gdm

echo "::endgroup::"

echo "::group:: Switch the display manager"

# gdm was removed above, so COSMIC's greeter takes over the display-manager
# alias. cosmic-session already ships /usr/share/wayland-sessions/cosmic.desktop,
# so there is no session file to write by hand.
systemctl enable greetd.service

echo "::endgroup::"
