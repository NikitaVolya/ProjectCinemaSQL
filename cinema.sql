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
       CONSTRAINT fk_id_cinema FOREIGN KEY (id_cinema) REFERENCES cinema(id)
);

CREATE TABLE seance(
       id INT UNSIGNED AUTO_INCREMENT,
       id_salle INT UNSIGNED NOT NULL,
       id_movie INT UNSIGNED NOT NULL, # Add foreign key in future
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
       CONSTRAINT fk_id_seance FOREIGN KEY (id_seance) REFERENCES seance(id)
);

CREATE TABLE passage(
       id_reservation INT UNSIGNED,
       place INT UNSIGNED,
       CONSTRAINT primary_key_id_resermation_place PRIMARY KEY (id_reservation, place)
);


DROP FUNCTION IF EXISTS check_free_place
;

DELIMITER $

CREATE FUNCTION check_free_place(
       in_id_seance INT UNSIGNED,
       in_place INT UNSIGNED
)
RETURNS BOOLEAN
READS SQL DATA
BEGIN

        DECLARE v_check INT UNSIGNED;
        DECLARE v_seance_capacity INT UNSIGNED;
        DECLARE v_res BOOLEAN DEFAULT FALSE;

        DECLARE CONTINUE HANDLER
        FOR NOT FOUND
        SET v_res = TRUE
        ;

        /* seance check on exists */
        BEGIN 
                DECLARE EXIT HANDLER
                FOR NOT FOUND
                SIGNAL SQLSTATE '42000'
                SET MESSAGE_TEXT = 'Seance isn`t exists'
                ;

                SELECT id
                INTO v_check
                FROM seance
                WHERE seance.id = in_id_seance
                ;

        END;

        IF in_place < 1 THEN
           SIGNAL SQLSTATE '42000'
           SET MESSAGE_TEXT = 'Place can`t be 0'
           ;
        END IF;

        SELECT passage.place, salle.capacity
        INTO v_check, v_seance_capacity
        FROM passage, reservation, seance, salle
        WHERE passage.id_reservation = reservation.id
        AND reservation.id_seance = seance.id
        AND seance.id_salle = salle.id
        AND passage.place = in_place
        ;

        IF in_place > v_seance_capacity THEN
           SIGNAL SQLSTATE '42000'
           SET MESSAGE_TEXT = 'Place can`t be greater that capacity of the salle'
           ;
        END IF;

        RETURN v_res;
END;
$
DELIMITER ;