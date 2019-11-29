#!/usr/bin/env bash
set -e

echo "Installing dependencies..."
if [ -x "$(command -v apt-get)" ]; then
   apt-get update -y
   apt-get install -y unzip
else
   yum update -y
   yum install -y unzip wget
fi

echo "Fetching Nomad..."
 mkdir -p /opt/nomad/data
 mkdir -p /etc/nomad.d
 mv /tmp/server.hcl /etc/nomad.d

NOMAD=0.10.1
cd /tmp
machine_type=arm64
if [[ `uname -m` == "x86_64" ]]; then
  machine_type=amd64
fi
echo https://releases.hashicorp.com/nomad/${NOMAD}/nomad_${NOMAD}_linux_${machine_type}.zip
curl -L -o nomad.zip https://releases.hashicorp.com/nomad/${NOMAD}/nomad_${NOMAD}_linux_${machine_type}.zip
unzip nomad.zip >/dev/null
mv nomad /usr/local/bin/nomad
chmod +x /usr/local/bin/nomad

# Read from the file we created

# Write the flags to a temporary file
cat >/tmp/nomad_flags << EOF
NOMAD_FLAGS="-server -data-dir /opt/nomad/data -config /etc/nomad.d"
EOF


if [ -f /tmp/upstart.conf ];
then
  echo "Installing Upstart service..."
   mkdir -p /etc/nomad.d
   mkdir -p /etc/service
   chown root:root /tmp/upstart.conf
   mv /tmp/upstart.conf /etc/init/nomad.conf
   chmod 0644 /etc/init/nomad.conf
   mv /tmp/nomad_flags /etc/service/nomad
   chmod 0644 /etc/service/nomad
else
  echo "Installing Systemd service..."
   mkdir -p /etc/systemd/system/nomad.d
   chown root:root /tmp/nomad.service
   mv /tmp/nomad.service /etc/systemd/system/nomad.service
   chmod 0644 /etc/systemd/system/nomad.service
   mkdir -p /etc/sysconfig/
   mv /tmp/nomad_flags /etc/sysconfig/nomad
   chown root:root /etc/sysconfig/nomad
   chmod 0644 /etc/sysconfig/nomad
fi