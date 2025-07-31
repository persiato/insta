#!/bin/bash

echo "================================================="
echo " Automatic Installer for Instagram Bot on Ubuntu "
echo " (v2 with Auto-MongoDB Setup)                  "
echo "================================================="

# --- 1. System Update and Dependencies ---
echo "[INFO] Updating system and installing dependencies..."
sudo apt-get update
# ADDED: mongodb is now installed automatically
sudo apt-get install -y nginx curl nodejs mongodb

# Start and enable MongoDB service
echo "[INFO] Starting and enabling MongoDB service..."
sudo systemctl start mongodb
sudo systemctl enable mongodb

# Install PM2 globally
sudo npm install -g pm2

# --- 2. Backend Setup ---
echo "[INFO] Setting up Backend..."
cd backend
if [ -d "node_modules" ]; then
    echo "[INFO] node_modules already exists, skipping npm install."
else
    npm install
fi
cd ..

# --- 3. Frontend Setup ---
echo "[INFO] Setting up and building Frontend..."
cd frontend
if [ -d "node_modules" ]; then
    echo "[INFO] node_modules already exists, skipping npm install."
else
    npm install
fi
npm run build
cd ..

# --- 4. Interactive Configuration ---
echo "[ACTION] Please answer the following questions to create the .env file."
# The setup script is now simpler
node setup.js

# --- 5. Nginx Configuration ---
echo "[ACTION] Nginx needs to be configured manually."
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


# --- 6. Start Application with PM2 ---
echo "[INFO] Starting the application with PM2..."
cd backend
pm2 start src/index.js --name "instagram-bot"
pm2 save
pm2 startup

echo "================================================="
echo "✅ Installation Finished!"
echo "MongoDB was installed and configured automatically."
echo "Your application is now running via PM2."
echo "================================================="