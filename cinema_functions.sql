

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
