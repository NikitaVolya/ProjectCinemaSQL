
/* START User Part */
CREATE TABLE subscribe (
       id INT UNSIGNED AUTO_INCREMENT,
       name VARCHAR(255) NOT NULL,
       reduce TINYINT UNSIGNED NOT NULL ,
       price DECIMAL(5,2)NOT NULL,
       priority BOOLEAN DEFAULT 0,
       reserved_place BOOLEAN DEFAULT 0,
       PRIMARY KEY (id),
       CONSTRAINT chk_price CHECK (price > 0),
       CONSTRAINT unq_name UNIQUE(name)
);


CREATE TABLE `user` (
       id INT UNSIGNED AUTO_INCREMENT,
       first_name VARCHAR(255) NOT NULL,
       last_name VARCHAR(255) NOT NULL,
       surname VARCHAR(255 )NOT NULL,
       email VARCHAR(255) NOT NULL,
       passwrd VARCHAR(255) NOT NULL,
       id_sub INT UNSIGNED DEFAULT NULL,
       end_sub DATE DEFAULT NULL,
       PRIMARY KEY (id),
       CONSTRAINT fk_id_sub_id FOREIGN KEY (id_sub) REFERENCES subscribe(id),
       CONSTRAINT unq_surname UNIQUE(surname),
       CONSTRAINT unq_email UNIQUE(email),
       INDEX idx_surname(surname)
);
/* END User Part */


/* START Movie Part */
CREATE TABLE movie (
       id INT UNSIGNED AUTO_INCREMENT,
       title VARCHAR(255) NOT NULL,
       release_date DATE NOT NULL,
       runtime TIME NOT NULL,
       genre VARCHAR(255),
       description TEXT,
       global_rating DECIMAL(3,2),
       poster_url VARCHAR(255),
       PRIMARY KEY(id),
       CHECK (runtime IS NULL OR runtime > 0),
       CHECK (global_rating IS NULL OR (global_rating >= 0 AND global_rating <= 10)),
       CHECK (release_date IS NULL OR DATE(release_date) >= '1888-01-01')
);

CREATE TABLE actor (
       id INT UNSIGNED AUTO_INCREMENT,
       first_name VARCHAR(255) NOT NULL,
       last_name VARCHAR(255) NOT NULL,
       birthday DATETIME NOT NULL,
       deathday DATETIME DEFAULT NULL,
       biography TEXT,
       photo_url VARCHAR(255),
       PRIMARY KEY(id),
       CHECK (deathday IS NULL OR deathday >= birthday),
       CHECK (birthday >= '1850-01-01')
);

CREATE TABLE movie_actor (
       id INT UNSIGNED AUTO_INCREMENT,
       character_name VARCHAR(255),
       role VARCHAR(255),
       PRIMARY KEY(id),
       movie_id INT UNSIGNED NOT NULL,
       actor_id INT UNSIGNED NOT NULL,
       FOREIGN KEY (movie_id) REFERENCES movie(id),
       FOREIGN KEY (actor_id) REFERENCES actor(id)
);
/* END Movie Part */

/* START Cinema Part */
CREATE TABLE cinema(
       id INT UNSIGNED AUTO_INCREMENT,
       name VARCHAR(255) NOT NULL,
       city VARCHAR(255) NOT NULL,
       address_name VARCHAR(255) NOT NULL,
       address_number SMALLINT UNSIGNED NOT NULL,
       CONSTRAINT primary_key_id PRIMARY KEY (id)
);

CREATE TABLE salle(
       id INT UNSIGNED AUTO_INCREMENT,
       id_cinema INT UNSIGNED NOT NULL,
       name VARCHAR(255) NOT NULL,
       capacity INT UNSIGNED NOT NULL,
       type SET('3D', 'IMAX', '4DX', 'STANDART') NOT NULL,
       CONSTRAINT primary_key_id PRIMARY KEY (id),
       CONSTRAINT fk_id_cinema FOREIGN KEY (id_cinema) REFERENCES cinema(id),
       CONSTRAINT unique_id_cinema_name UNIQUE (id_cinema, name)
);

CREATE TABLE seance(
       id INT UNSIGNED AUTO_INCREMENT,
       id_salle INT UNSIGNED NOT NULL,
       id_movie INT UNSIGNED NOT NULL,
       start_time DATETIME NOT NULL,
       end_time DATETIME NOT NULL,
       price DECIMAL (5, 2) NOT NULL,
       type ENUM('3D', 'IMAX', '4DX', 'STANDART') NOT NULL,
       CONSTRAINT primary_key_id PRIMARY KEY (id),
       CONSTRAINT fk_id_salle FOREIGN KEY (id_salle) REFERENCES salle(id),
       CONSTRAINT fk_id_movie FOREIGN KEY (id_movie) REFERENCES movie(id),
       CONSTRAINT chk_start_end_time CHECK (start_time < end_time),
       CONSTRAINT chk_positive_price CHECK (0.0 < price)
);

CREATE TABLE reservation(
       id INT UNSIGNED AUTO_INCREMENT,
       id_seance INT UNSIGNED NOT NULL,
       id_user INT UNSIGNED,
       CONSTRAINT primary_key_id PRIMARY KEY (id),
       CONSTRAINT fk_id_seance FOREIGN KEY (id_seance) REFERENCES seance(id) ON DELETE CASCADE,
       CONSTRAINT fk_id_user FOREIGN KEY (id_user) REFERENCES `user`(id) ON DELETE SET NULL
);

CREATE TABLE passage(
       id_reservation INT UNSIGNED,
       seat INT UNSIGNED,
       CONSTRAINT fk_id_reservation FOREIGN KEY (id_reservation) REFERENCES reservation(id) ON DELETE CASCADE,
       CONSTRAINT primary_key_id_reservation_place PRIMARY KEY (id_reservation, seat)
);
/* END Cinema PART */
