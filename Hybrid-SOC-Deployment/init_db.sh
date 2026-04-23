#!/bin/bash
sudo mysql < database.sql

sudo mysql -e "GRANT ALL PRIVILEGES ON insa_project.* TO 'admin'@'localhost' IDENTIFIED BY 'your_password';"
sudo mysql -e "FLUSH PRIVILEGES;"

echo "Database and Privileges initialized successfully!"