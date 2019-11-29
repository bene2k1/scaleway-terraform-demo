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


echo "Fetching Consul..."
CONSUL=1.6.2
cd /tmp
machine_type=arm64
if [[ `uname -m` == "x86_64" ]]; then
  machine_type=amd64
fi
echo https://releases.hashicorp.com/consul/${CONSUL}/consul_${CONSUL}_linux_${machine_type}.zip
curl -L -o consul.zip https://releases.hashicorp.com/consul/${CONSUL}/consul_${CONSUL}_linux_${machine_type}.zip

echo "Installing Consul..."

unzip /tmp/consul.zip >/dev/null
chmod +x consul
 mv consul /usr/local/bin/consul
 mkdir -p /opt/consul/data

# Read from the file we created
SERVER_COUNT=$(cat /tmp/consul-server-count | tr -d '\n')
CONSUL_JOIN=$(cat /tmp/consul-server-addr | tr -d '\n')
BIND=`scw-metadata | grep "PRIVATE_IP" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"`

# Write the flags to a temporary file
cat >/tmp/consul_flags << EOF
CONSUL_FLAGS="-server -bootstrap-expect=${SERVER_COUNT} -join=${CONSUL_JOIN} -data-dir=/opt/consul/data -client ${BIND}"
EOF

if [ -f /tmp/upstart.conf ];
then
  echo "Installing Upstart service..."
   mkdir -p /etc/consul.d
   mkdir -p /etc/service
   chown root:root /tmp/upstart.conf
   mv /tmp/upstart.conf /etc/init/consul.conf
   chmod 0644 /etc/init/consul.conf
   mv /tmp/consul_flags /etc/service/consul
   chmod 0644 /etc/service/consul
else
  echo "Installing Systemd service..."
   mkdir -p /etc/systemd/system/consul.d
   chown root:root /tmp/consul.service
   mv /tmp/consul.service /etc/systemd/system/consul.service
   chmod 0644 /etc/systemd/system/consul.service
   mkdir -p /etc/sysconfig/
   mv /tmp/consul_flags /etc/sysconfig/consul
   chown root:root /etc/sysconfig/consul
   chmod 0644 /etc/sysconfig/consul
fi