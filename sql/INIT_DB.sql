CREATE DATABASE simple_service;
GRANT ALL ON simple_service.* TO 'a' @'localhost' IDENTIFIED BY 'password' WITH
GRANT OPTION;
FLUSH PRIVILEGES;
SHOW DATABASES;
USE simple_service CREATE TABLE users (
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    PRIMARY KEY (id)
);