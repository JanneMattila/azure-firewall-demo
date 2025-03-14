#!/bin/bash

if [ -f /etc/systemd/system/webappnetworktester.service ]; then
    echo "WebApp Network Tester already installed."
    exit 0
fi

# Requires connectivity to:
# http://azure.archive.ubuntu.com
sudo apt install unzip

sudo mkdir -p /usr/local/bin

# Requires connectivity to:
# https://github.com/
# https://objects.githubusercontent.com/
wget -q "https://github.com/JanneMattila/webapp-network-tester/releases/latest/download/webappnetworktester-linux.zip" -O /tmp/webappnetworktester-linux.zip
unzip /tmp/webappnetworktester-linux.zip -d /tmp/webappnetworktester-linux
sudo chmod +x /tmp/webappnetworktester-linux/artifacts/webappnetworktester-linux/webappnetworktester
sudo mv /tmp/webappnetworktester-linux/artifacts/webappnetworktester-linux/* /usr/local/bin/
rm -rf /tmp/webappnetworktester-linux.zip /tmp/webappnetworktester-linux

# Create as a service
sudo bash -c 'cat > /etc/systemd/system/webappnetworktester.service' << EOF
[Unit]
Description=WebApp Network Tester
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/webappnetworktester --urls http://*:80
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable webappnetworktester
sudo systemctl start webappnetworktester
