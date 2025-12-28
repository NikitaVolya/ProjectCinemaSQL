DROP TABLE IF EXISTS movie_actor;
DROP TABLE IF EXISTS actor;
DROP TABLE IF EXISTS movie;

CREATE TABLE movie (
id INT AUTO_INCREMENT,
title VARCHAR(255) NOT NULL,
release_date DATE,
runtime TIME,
genre VARCHAR(255),
description TEXT,
global_rating DECIMAL(3,2),
poster_url VARCHAR(255),
PRIMARY KEY(id)
);

CREATE TABLE actor (
id INT AUTO_INCREMENT,
first_name VARCHAR(255) NOT NULL,
last_name VARCHAR(255) NOT NULL,
birthday DATETIME NOT NULL,
deathday DATETIME DEFAULT NULL,
biography TEXT,
photo_url VARCHAR(255),
PRIMARY KEY(id)
);

CREATE TABLE movie_actor (
id INT AUTO_INCREMENT,
character_name VARCHAR(255),
role VARCHAR(255),
PRIMARY KEY(id),
movie_id INT NOT NULL,
actor_id INT NOT NULL,
FOREIGN KEY (movie_id) REFERENCES movie(id),
FOREIGN KEY (actor_id) REFERENCES actor(id)
);