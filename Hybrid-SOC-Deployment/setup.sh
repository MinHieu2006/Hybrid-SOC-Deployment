#!/bin/bash

# =================================================================
# PROJECT: SECURE WEB INFRASTRUCTURE & AI AGENT HUB
# TARGET: Ubuntu Server (Noble 24.04 LTS)
# =================================================================

# --- 1. LOG CONFIGURATION ---
LOG_FILE="setup_status.log"
exec 2>> "$LOG_FILE"

echo "[$(date)] --- Initializing system deployment ---" >&2

# --- 2. FIX LINE ENDINGS (CRLF TO LF) ---
# Ensures script compatibility across different environments
sed -i 's/\r$//' "$0"

# --- 3. SYSTEM UPDATE & PACKAGE INSTALLATION ---
echo "Updating system package repositories..."
sudo apt update -y

echo "Installing essential tools and LAMP Stack..."
# Core tools
sudo apt install -y \
    git curl wget net-tools netcat-traditional openssh-server \
    apache2 mariadb-server php libapache2-mod-php php-mysql \
    ufw fail2ban certbot python3-certbot-apache python3-pip || {
    echo "ERROR: Package installation failed. Check $LOG_FILE" >&2
    exit 1
}

# --- 4. FIREWALL CONFIGURATION (LAB 1) ---
echo "Applying Zero-Trust Firewall rules..."
# Default policy: deny all incoming traffic
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw allow 22/tcp   # SSH (Management)
echo "y" | sudo ufw enable

# --- 5. SSH HARDENING (LAB 2) ---
if [ -f /etc/ssh/sshd_config ]; then
    echo "Hardening SSH configuration..."
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    # Disabling password authentication for Key-based security
    sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    sudo systemctl restart ssh
else
    echo "WARNING: SSH config file not found." >&2
fi

# --- 6. REMOTE NETWORKING (TAILSCALE) ---
echo "Deploying Tailscale for secure management tunnel..."
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --authkey your_tailscale_key

# --- 7. WEB DIRECTORY PERMISSIONS ---
echo "Setting up web directory permissions..."
WEB_ROOT="/var/www/html"
sudo mkdir -p $WEB_ROOT
# Assigning ownership to current user and www-data group for Apache access
sudo chown -R $USER:www-data $WEB_ROOT
sudo chmod -R 775 $WEB_ROOT

# --- 8. AUTHENTICATION TEST FILE  ---
echo "Generating PHP test file for MD5 Hashing..."
# Lab 4 requirement: Testing password encryption
cat <<EOF | sudo tee "$WEB_ROOT/auth_test.php" > /dev/null
<?php
echo "<h1>System Ready: Hieu's Secure Hub</h1>";
echo "<p>Server Time: " . date('Y-m-d H:i:s') . "</p>";
\$test_pass = "insa_bourges_2026";
echo "<p>MD5 Hash Test: " . md5(\$test_pass) . "</p>";
?>
EOF

# --- 9. SERVICE ACTIVATION ---
echo "Enabling and restarting core services..."
sudo systemctl enable apache2 mariadb ssh
sudo systemctl restart apache2 mariadb ssh

# --- 10. Clone repositorie  ---
cd /var/www/html
sudo git clone https://github.com/MinHieu2006/Hybrid-SOC-Deployment.git
cd Hybrid-SOC-Deployment
mv * /var/www/html
cd /var/www/html

# --- 11. Create database and login page  ---
sudo chmod +x init_db.sh
sudo ./init_db.sh
sudo chown -R $USER:www-data /var/www/html
sudo chmod -R 775 /var/www/html


echo "--- DEPLOYMENT COMPLETE ---"
echo "Internal Access: http://localhost/auth_test.php"
echo "Secure Tunnel: Run 'sudo tailscale up' to connect your Local AI Agent."
echo "Remember to change your_username and your_password in config.php"
echo "In your local machine, use ssh-copy-id -i ~/.ssh/id_ed25519.pub user@IP to copy ssh key"
echo "Then connect ssh by this command ssh -i /home/hieu/.ssh/id_ed25519 'user@IP'"