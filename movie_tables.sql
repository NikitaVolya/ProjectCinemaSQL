DROP TABLE IF EXISTS movie;
DROP TABLE IF EXISTS movie_diffusion;
DROP TABLE IF EXISTS actor;
DROP TABLE IF EXISTS movie_actor;
DROP TABLE IF EXISTS studio;

CREATE TABLE movie (
id INT UNSIGNED AUTO_INCREMENT,
title VARCHAR(255) NOT NULL,
release_year YEAR NOT NULL,
runtime INT,
genre VARCHAR(255),
description VARCHAR(255),
global_rating DECIMAL(3,2),
PRIMARY KEY(id)
);

CREATE TABLE movie_diffusion (
id INT UNSIGNED AUTO_INCREMENT,
start_diffusion_date DATETIME,
end_diffusion_date DATETIME,
location VARCHAR(255),
notes VARCHAR(255),
PRIMARY KEY(id)
#movie id
);

CREATE TABLE actor (
id INT UNSIGNED AUTO_INCREMENT,
first_name VARCHAR(255) NOT NULL,
last_name VARCHAR(255) NOT NULL,
birthday DATETIME NOT NULL,
deathday DATETIME DEFAULT NULL,
biography VARCHAR(255),
PRIMARY KEY(id)
);

CREATE TABLE movie_actor (
id INT UNSIGNED AUTO_INCREMENT,
character_name VARCHAR(255),
role VARCHAR(255),
PRIMARY KEY(id)
#movie id
#actor id
);

CREATE TABLE studio (
id INT UNSIGNED AUTO_INCREMENT,
films_created INT UNSIGNED,
rating DECIMAL(3,2) UNSIGNED,
genres VARCHAR(255),
PRIMARY KEY(id)
#film id
);
