#!/bin/bash
set -e

echo "================================================="
echo " Simplified Installer for Instagram Bot (v4)     "
echo "================================================="

# --- 1. System Update and Prerequisites ---
echo "[INFO] Updating system and installing prerequisites..."
sudo apt-get update
sudo apt-get install -y curl gnupg ca-certificates

# --- 2. Install MongoDB ---
echo "[INFO] Setting up and Installing MongoDB..."
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod

# --- 3. Install Node.js, NPM, and PM2 ---
echo "[INFO] Installing Node.js, npm, and PM2..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g pm2

# --- 4. Backend Setup ONLY ---
echo "[INFO] Setting up Backend application..."
cd backend
npm install
cd ..

# --- 5. Interactive Configuration ---
echo "[ACTION] Please answer the following questions to create the .env file."
node setup.js

# --- 6. Nginx Info ---
echo "[ACTION] Nginx configuration is needed. The app runs on a single domain now."
# ... (The rest of the script is the same)
echo "Please create a file like '/etc/nginx/sites-available/instagram-bot' with the content below."
echo "Remember to replace 'your_domain.com' with your actual domain name and set up SSL (e.g., with Let's Encrypt)."
echo ""
echo "-------------------------------------------------"
echo "
server {
    listen 80;
    server_name your_domain.com;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name your_domain.com;

    # SSL cert paths (replace with your certs)
    # ssl_certificate /etc/letsencrypt/live/your_domain.com/fullchain.pem;
    # ssl_certificate_key /etc/letsencrypt/live/your_domain.com/privkey.pem;

    location / {
        proxy_pass http://localhost:5000; # The backend now serves the HTML
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
"
echo "-------------------------------------------------"
echo "After creating the file, run:"
echo "sudo ln -s /etc/nginx/sites-available/instagram-bot /etc/nginx/sites-enabled/"
echo "sudo nginx -t"
echo "sudo systemctl restart nginx"
echo ""

# --- 7. Start Application with PM2 ---
echo "[INFO] Starting the application with PM2..."
cd backend
pm2 start src/index.js --name "instagram-bot"
pm2 save
pm2 startup

echo "================================================="
echo "✅ Installation Finished Successfully!"
echo "The application is much simpler now. Enjoy!"
echo "================================================="