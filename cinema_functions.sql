

DROP FUNCTION IF EXISTS is_seat_available
;

DELIMITER $

/*
        Return if seat is available on seance

        In in_id_seance - Seance id to check seat
        In in_seat - Seat number
*/
CREATE FUNCTION is_seat_available(
       in_id_seance INT UNSIGNED,
       in_seat INT UNSIGNED
)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
        DECLARE v_check INT UNSIGNED;
        DECLARE v_seance_capacity INT UNSIGNED;
        DECLARE v_res BOOLEAN DEFAULT FALSE;

        /* change result to TRUE if not found reserved seat */
        DECLARE CONTINUE HANDLER
        FOR NOT FOUND
        SET v_res = TRUE
        ;

        /* check seance on exists */
        BEGIN 
                DECLARE EXIT HANDLER
                FOR NOT FOUND
                SIGNAL SQLSTATE '42000'
                SET MESSAGE_TEXT = 'Seance is not exists'
                ;

                SELECT id
                INTO v_check
                FROM seance
                WHERE seance.id = in_id_seance
                ;

        END;

        IF in_seat = 0 THEN
           SIGNAL SQLSTATE '42000'
           SET MESSAGE_TEXT = 'Place can`t be 0'
           ;
        END IF;

        SELECT salle.capacity
        INTO v_seance_capacity
        FROM seance, salle
        WHERE seance.id = in_id_seance
        AND salle.id = seance.id_salle
        ;

        IF in_seat > v_seance_capacity THEN
           SIGNAL SQLSTATE '42000'
           SET MESSAGE_TEXT = 'Place can`t be greater that capacity of the salle'
           ;

           SET v_res = FALSE;
        END IF;

        SELECT passage.seat
        INTO v_check
        FROM passage, reservation
        WHERE passage.id_reservation = reservation.id
        AND reservation.id_seance = in_id_seance
        AND passage.seat = in_seat
        ;

        RETURN v_res;
END;
$
DELIMITER ;

DROP FUNCTION IF EXISTS count_reserved_seats
;

/*
        Count number of seats reserved on seance

        In in_id_seance - Seance id to check
*/
DELIMITER $
CREATE FUNCTION count_reserved_seats(
       in_id_seance INT UNSIGNED
)
RETURNS INT UNSIGNED
READS SQL DATA
BEGIN
        DECLARE v_reserved_seats INT UNSIGNED;

        DECLARE EXIT HANDLER
        FOR NOT FOUND
        SIGNAL SQLSTATE '42000'
        SET MESSAGE_TEXT = 'Seance is not exists'
        ;

        SELECT COUNT(*)
        INTO v_reserved_seats
        FROM passage, reservation
        WHERE passage.id_reservation = reservation.id
        AND reservation.id_seance = in_id_seance
        ;

        RETURN v_reserved_seats;
END;
$
DELIMITER ;


DROP FUNCTION IF EXISTS count_available_seats
;

/*
        Count number of seats available on seance

        In in_id_seance - Seance id to check
*/
DELIMITER $
CREATE FUNCTION count_available_seats(
       in_id_seance INT UNSIGNED
)
RETURNS INT UNSIGNED
READS SQL DATA
BEGIN
        DECLARE v_seance_capacity INT UNSIGNED;

        DECLARE EXIT HANDLER
        FOR NOT FOUND
        SIGNAL SQLSTATE '42000'
        SET MESSAGE_TEXT = 'Seance is not exists'
        ;

        SELECT salle.capacity
        INTO v_seance_capacity
        FROM seance, salle
        WHERE seance.id = in_id_seance
        AND salle.id = seance.id_salle
        ;
        RETURN v_seance_capacity - count_reserved_seats(in_id_seance);
END;
$
DELIMITER ;

DROP PROCEDURE IF EXISTS seance_info
;

/*
        Output info for seance id | available seats | reserved seats | seance capacity
        In in_id_seance - Seance id to output information
*/
DELIMITER $
CREATE PROCEDURE seance_info(
     IN in_id_seance INT UNSIGNED
)
BEGIN
        DECLARE EXIT HANDLER
        FOR NOT FOUND
        SIGNAL SQLSTATE '42000'
        SET MESSAGE_TEXT = 'Seance is not exists'
        ;

        SELECT seance.id,
        count_available_seats(in_id_seance) AS available_seats,
        count_reserved_seats(in_id_seance) AS reserved_seats,
        salle.capacity
        FROM seance, salle
        WHERE seance.id_salle = salle.id
        AND seance.id = in_id_seance;
END;
$
DELIMITER ;


DROP FUNCTION IF EXISTS check_on_seance_in_datetime;
DELIMITER $
CREATE FUNCTION check_on_seance_in_datetime(
       in_id_salle INT UNSIGNED,
       in_time_begin DATETIME,
       in_time_end DATETIME
)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
        DECLARE v_finded_seances INT UNSIGNED;
        DECLARE v_check INT UNSIGNED;

        DECLARE EXIT HANDLER
        FOR NOT FOUND
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Salle is not exists';

        SELECT id
        INTO v_check
        FROM salle
        WHERE salle.id = in_id_salle
        ;

        IF in_time_begin > in_time_end THEN
           SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Time borders are not valides'
           ;
        END IF;

        SET v_finded_seances = (SELECT COUNT(seance.id)
                                 FROM seance
                                 WHERE (seance.id_salle = in_id_salle
                                 AND ((in_time_begin BETWEEN seance.start_time AND end_time) OR
                                     (in_time_end BETWEEN seance.start_time AND end_time) OR
                                     (in_time_begin <= seance.start_time AND seance.end_time <= in_time_end)))
                               );

        IF 0 < v_finded_seances THEN
                RETURN TRUE;
        ELSE
                RETURN FALSE;
        END IF;
                          
END;
$
DELIMITER ;


DROP FUNCTION IF EXISTS check_seance_is_started;
DELIMITER $
CREATE FUNCTION check_seance_is_started(
       in_id_seance INT UNSIGNED
)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
        DECLARE v_start_time DATETIME;

        DECLARE EXIT HANDLER
        FOR NOT FOUND
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Seance is not exists'
        ;

        SELECT start_time
        INTO v_start_time
        FROM seance
        WHERE id = in_id_seance
        ;

        RETURN (v_start_time <= NOW());
END;
$
DELIMITER ;



DROP FUNCTION IF EXISTS check_seance_is_ended;
DELIMITER $
CREATE FUNCTION check_seance_is_ended(
       in_id_seance INT UNSIGNED
)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
        DECLARE v_end_time DATETIME;

        DECLARE EXIT HANDLER
        FOR NOT FOUND
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Seance is not exists'
        ;

        SELECT end_time
        INTO v_end_time
        FROM seance
        WHERE id = in_id_seance
        ;

        RETURN (v_end_time <= NOW());
END;
$
DELIMITER ;



DROP PROCEDURE IF EXISTS add_seance_for_movie;
DELIMITER $
CREATE PROCEDURE add_seance_for_movie(
       IN in_id_salle INT UNSIGNED,
       IN in_id_movie INT UNSIGNED,
       IN in_commercial_time TIME,
       IN in_start_time DATETIME,
       IN in_price DECIMAL (5, 2),
       IN in_type VARCHAR(255)
)
BEGIN
        DECLARE v_check INT UNSIGNED;
        DECLARE v_movie_runtime TIME;
        DECLARE v_end_time DATETIME;

        BEGIN
                DECLARE EXIT HANDLER
                FOR NOT FOUND
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Salle is not exists'
                ;

                SELECT id
                INTO v_check
                FROM salle
                WHERE salle.id = in_id_salle
                ;
        END;

        BEGIN
                DECLARE EXIT HANDLER
                FOR NOT FOUND
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Movie is not exists'
                ;

                SELECT movie.runtime
                INTO v_movie_runtime
                FROM movie
                WHERE movie.id = in_id_movie
                ;
        END;

        IF in_commercial_time < '00:10:00' THEN
           SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Commercial time can not be less than 10 minutes'
           ;
        END IF;

        IF in_commercial_time > '00:25:00' THEN
           SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Commercial time can not be greater than 25 minutes'
           ;
        END IF;

        SET v_end_time = DATE_ADD(in_start_time, INTERVAL ( TIME_TO_SEC(v_movie_runtime) + TIME_TO_SEC(in_commercial_time)) SECOND);

        INSERT INTO seance (id_salle, id_movie, start_time, end_time, price, type)
        VALUES (in_id_salle, in_id_movie, in_start_time, v_end_time, in_price, in_type)
        ;

        SELECT CONCAT('Seance created with id ', CAST(seance.id AS CHAR)) AS message
        FROM seance
        ORDER BY seance.id DESC
        LIMIT 1
        ;
END;
$
DELIMITER ;