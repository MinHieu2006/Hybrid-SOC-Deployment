CREATE DATABASE IF NOT EXISTS insa_project;
USE insa_project;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL
);

INSERT INTO users (username, password) 
VALUES ('admin', '$2a$10$8sTZTP/GzAiRZk61XyGjLOogupC3v.2tNOltsbywM3w/PVceI0W9q');