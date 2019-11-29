#!/usr/bin/env bash
set -e

echo "Starting Consul..."
if [ -x "$(command -v systemctl)" ]; then
  echo "using systemctl"
   systemctl enable consul.service
   systemctl start consul
else
  echo "using upstart"
   start consul
fi