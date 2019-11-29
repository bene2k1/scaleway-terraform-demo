#!/usr/bin/env bash
set -e

echo "Starting Nomad..."
if [ -x "$(command -v systemctl)" ]; then
  echo "using systemctl"
   systemctl enable nomad.service
   systemctl start nomad
else
  echo "using upstart"
   start nomad
fi