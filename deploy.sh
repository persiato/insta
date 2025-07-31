#!/bin/bash
# ADDED: Exit immediately if a command exits with a non-zero status.
set -e

echo "================================================="
echo " Automatic Installer for Instagram Bot on Ubuntu "
echo " (v3 with Correct Dependencies for Ubuntu 24)    "
echo "================================================="

# --- 1. System Update and Prerequisites ---
echo "[INFO] Updating system and installing prerequisites..."
sudo apt-get update
sudo apt-get install -y curl gnupg ca-certificates

# --- 2. Install MongoDB (The Correct Way for Ubuntu 24) ---
echo "[INFO] Setting up MongoDB repository..."
# Import the public key used by the package management system
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
   --dearmor
# Create a list file for MongoDB
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
   sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

echo "[INFO] Installing MongoDB..."
sudo apt-get update
# The correct package name is mongodb-org
sudo apt-get install -y mongodb-org

echo "[INFO] Starting and enabling MongoDB service..."
sudo systemctl start mongod
sudo systemctl enable mongod


# --- 3. Install Node.js, NPM, and PM2 (The Correct Way) ---
echo "[INFO] Setting up Node.js repository..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

echo "[INFO] Installing Node.js, npm, and PM2..."
sudo apt-get install -y nodejs
sudo npm install -g pm2


# --- 4. Backend Setup ---
echo "[INFO] Setting up Backend..."
cd backend
npm install
cd ..


# --- 5. Frontend Setup ---
echo "[INFO] Setting up and building Frontend..."
cd frontend
npm install
npm run build
cd ..


# --- 6. Interactive Configuration ---
echo "[ACTION] Please answer the following questions to create the .env file."
node setup.js


# --- 7. Nginx Info (No changes here) ---
echo "[ACTION] Nginx needs to be configured manually."
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
        root $(pwd)/frontend/build;
        try_files \$uri /index.html;
    }

    location /api {
        proxy_pass http://localhost:5000;
    }
    
    location /webhook {
        proxy_pass http://localhost:5000;
    }
}
"
echo "-------------------------------------------------"
echo "After creating the file, run:"
echo "sudo ln -s /etc/nginx/sites-available/instagram-bot /etc/nginx/sites-enabled/"
echo "sudo nginx -t"
echo "sudo systemctl restart nginx"
echo ""


# --- 8. Start Application with PM2 ---
echo "[INFO] Starting the application with PM2..."
# Change to backend directory before starting
cd backend
pm2 start src/index.js --name "instagram-bot"
pm2 save
pm2 startup

echo "================================================="
echo "✅ Installation Finished Successfully!"
echo "Your application should now be running via PM2."
echo "================================================="