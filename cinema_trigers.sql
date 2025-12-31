
DROP PROCEDURE IF EXISTS p_check_passage_seat;

DELIMITER $
CREATE PROCEDURE p_check_passage_seat(
       IN in_id_reservation INT UNSIGNED,
       IN in_seat INT UNSIGNED
)
BEGIN
        DECLARE v_id_seance INT UNSIGNED;

        DECLARE EXIT HANDLER
        FOR NOT FOUND
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Seance or reservation is not valide';

        SELECT seance.id
        INTO v_id_seance
        FROM seance, reservation
        WHERE seance.id = reservation.id_seance
        AND reservation.id = in_id_reservation
        ;

        IF NOT is_seat_available(v_id_seance, in_seat) THEN
           SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'seat is already reserved or not available'
           ;
        END IF;

        IF check_seance_is_ended(v_id_seance) THEN
           SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Seance already ended'
           ;
        END IF;
END;
$
DELIMITER ;

DROP TRIGGER IF EXISTS t_bf_ins_passage;

DELIMITER $
CREATE TRIGGER t_bf_ins_passage
BEFORE INSERT
ON passage FOR EACH ROW
CALL p_check_passage_seat(NEW.id_reservation, NEW.seat);
$
DELIMITER ;


DROP TRIGGER IF EXISTS t_bf_up_passage;

DELIMITER $
CREATE TRIGGER t_bf_up_passage
BEFORE UPDATE
ON passage FOR EACH ROW
CALL p_check_passage_seat(NEW.id_reservation, NEW.seat);
$
DELIMITER ;


DROP TRIGGER IF EXISTS t_af_del_passage;
DELIMITER $
CREATE TRIGGER t_af_del_passage
AFTER DELETE
ON passage FOR EACH ROW
BEGIN
        DECLARE v_id_reservation INT UNSIGNED;
        DECLARE v_continue BOOLEAN DEFAULT TRUE;

        DECLARE c_reservation CURSOR FOR
        SELECT reservation.id
        FROM reservation
        LEFT JOIN passage ON passage.id_reservation = reservation.id
        WHERE passage.seat IS NULL
        ;

        DECLARE CONTINUE HANDLER
        FOR NOT FOUND
        SET v_continue = FALSE;

        OPEN c_reservation;

        b_reservation: LOOP

             FETCH c_reservation
             INTO v_id_reservation
             ;

             IF NOT v_continue THEN
                LEAVE b_reservation;
             END IF;

             DELETE FROM reservation
             WHERE id = v_id_reservation
             ;

        END LOOP b_reservation;

        CLOSE c_reservation;

END;
$
DELIMITER ;


DROP TRIGGER IF EXISTS t_bf_ins_reservation;

DELIMITER $
CREATE TRIGGER t_bf_ins_reservation
BEFORE INSERT
ON reservation FOR EACH ROW
BEGIN

      IF check_seance_is_ended(NEW.id_seance) THEN
         SIGNAL SQLSTATE '45000'
         SET MESSAGE_TEXT = 'Seance is already ended'
         ;
      END IF;

      IF count_available_seats(NEW.id_seance) = 0 THEN
         SIGNAL SQLSTATE '45000'
         SET MESSAGE_TEXT = 'Seance is already full'
         ;
      END IF;
END;
$
DELIMITER ;


DROP TRIGGER IF EXISTS t_bf_up_reservation;

DELIMITER $
CREATE TRIGGER t_bf_up_reservation
BEFORE UPDATE
ON reservation FOR EACH ROW
BEGIN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Reservation update is not posibile'
        ;
END;
$
DELIMITER ;


DROP PROCEDURE IF EXISTS p_check_seance_type;
DELIMITER $
CREATE PROCEDURE p_check_seance_type(
       IN in_seance_type VARCHAR(255),
       IN in_id_salle INT UNSIGNED
)
BEGIN
      DECLARE EXIT HANDLER
      FOR NOT FOUND
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Salle is not valide'
      ;
      IF NOT FIND_IN_SET(in_seance_type, (SELECT salle.type
                                FROM salle
                                WHERE salle.id = in_id_salle)) THEN
         SIGNAL SQLSTATE '42000'
         SET MESSAGE_TEXT = 'Seance can not have different from salle types.'
         ;
      END IF;
END;
$
DELIMITER ;


DROP PROCEDURE IF EXISTS p_check_seance_movie_time;
DELIMITER $
CREATE PROCEDURE p_check_seance_movie_time(
       IN in_id_movie INT UNSIGNED,
       IN in_start_time DATETIME,
       IN in_end_time DATETIME
)
BEGIN
        DECLARE v_movie_runtime TIME;

        DECLARE EXIT HANDLER
        FOR NOT FOUND
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Movie not exists'
        ;

        SELECT runtime
        INTO v_movie_runtime
        FROM movie
        WHERE movie.id = in_id_movie
        ;

        IF TIME(in_end_time - in_start_time) < v_movie_runtime THEN
           SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Seance runtime can not be less than movie runtime'
           ;
        END IF;
END;
$
DELIMITER ;


DROP TRIGGER IF EXISTS t_bf_ins_seance;

DELIMITER $
CREATE TRIGGER t_bf_ins_seance
BEFORE INSERT
ON seance FOR EACH ROW
BEGIN
        /* Validate that the seance type matches the salle configuration */
        CALL p_check_seance_type(NEW.type, NEW.id_salle);

        /* Validate that the seance duration time is greater or equale to movie runtime */
        CALL p_check_seance_movie_time(NEW.id_movie, NEW.start_time, NEW.end_time);

        /* Check on time */
        IF check_on_seance_in_datetime(NEW.id_salle, NEW.start_time, NEW.end_time) THEN
           SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Seance in this time already exists'
           ;
        END IF;

END;
$
DELIMITER ;


DROP TRIGGER IF EXISTS t_bf_up_seance;

DELIMITER $
CREATE TRIGGER t_bf_up_seance
BEFORE UPDATE
ON seance FOR EACH ROW
BEGIN
        /* Validate that the seance type matches the salle configuration */
        CALL p_check_seance_type(NEW.type, NEW.id_salle);
        
        /* Validate that the seance duration time is greater or equale to movie runtime */
        CALL p_check_seance_movie_time(NEW.id_movie, NEW.start_time, NEW.end_time);

        /* Check on time if new salle */
        IF NEW.id_salle <> OLD.id_salle THEN
           IF check_on_seance_in_datetime(NEW.id_salle, NEW.start_time, NEW.end_time) THEN
              SIGNAL SQLSTATE '45000'
              SET MESSAGE_TEXT = 'Seance in this time in new salle already exists'
              ;
           END IF;
        ELSE
           /* Check on new time */
           IF NEW.start_time <> OLD.start_time AND NEW.end_time <> OLD.end_time THEN

              IF check_on_seance_in_datetime(NEW.id_salle, NEW.start_time, NEW.end_time) THEN
                 SIGNAL SQLSTATE '45000'
                 SET MESSAGE_TEXT = 'Seance in this time in new salle already exists'
                 ;
              END IF;
              
           ELSE
              /* Check on new start time */
              IF NEW.start_time < OLD.start_time AND
              check_on_seance_in_datetime(NEW.id_salle, NEW.start_time, OLD.start_time) THEN
                 SIGNAL SQLSTATE '45000'
                 SET MESSAGE_TEXT = 'The new start time overlaps with an existing seance in this salle';
              END IF;

              /* Check on new end time */
              IF NEW.end_time > OLD.end_time AND
              check_on_seance_in_datetime(NEW.id_salle, OLD.end_time, NEW.end_time) THEN
                 SIGNAL SQLSTATE '45000'
                 SET MESSAGE_TEXT = 'The new end time overlaps with an existing seance in this salle';
              END IF;
           
           END IF;
           
        END IF;

END;
$
DELIMITER ;



