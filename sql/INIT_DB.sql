CREATE DATABASE a_database;
GRANT ALL ON a_database.* TO 'a' @'localhost' IDENTIFIED BY 'password' WITH
GRANT OPTION;
FLUSH PRIVILEGES;
SHOW a_database;
USE a_database;
CREATE TABLE users (
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    PRIMARY KEY (id)
);