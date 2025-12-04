DROP TABLE IF EXISTS passage;
DROP TABLE IF EXISTS reservation;
DROP TABLE IF EXISTS seance;
DROP TABLE IF EXISTS salle;
DROP TABLE IF EXISTS cinema;


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
       id_movie INT UNSIGNED, # Add foreign key in the future
       start_time DATETIME NOT NULL,
       end_time DATETIME NOT NULL,
       price DECIMAL (5, 2) NOT NULL,
       type ENUM('3D', 'IMAX', '4DX', 'STANDART') NOT NULL,
       CONSTRAINT primary_key_id PRIMARY KEY (id),
       CONSTRAINT fk_id_salle FOREIGN KEY (id_salle) REFERENCES salle(id),
       CONSTRAINT chk_start_end_time CHECK (start_time < end_time),
       CONSTRAINT chk_positive_price CHECK (0.0 < price)
);

CREATE TABLE reservation(
       id INT UNSIGNED AUTO_INCREMENT,
       id_seance INT UNSIGNED NOT NULL,
       id_user INT UNSIGNED,
       CONSTRAINT primary_key_id PRIMARY KEY (id),
       CONSTRAINT fk_id_seance FOREIGN KEY (id_seance) REFERENCES seance(id),
       CONSTRAINT fk_id_user FOREIGN KEY (id_user) REFERENCES user(id)
);

CREATE TABLE passage(
       id_reservation INT UNSIGNED,
       seat INT UNSIGNED,
       CONSTRAINT primary_key_id_resermation_place PRIMARY KEY (id_reservation, seat)
);


