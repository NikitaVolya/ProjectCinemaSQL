
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
        SIGNAL SQLSTATE '42000'
        SET MESSAGE_TEXT = 'Seance or reservation is not valide';

        SELECT seance.id
        INTO v_id_seance
        FROM seance, reservation
        WHERE seance.id = reservation.id_seance
        AND reservation.id = in_id_reservation
        ;

        IF NOT is_seat_available(v_id_seance, in_seat) THEN
           SIGNAL SQLSTATE '42000'
           SET MESSAGE_TEXT = 'seat is already reserved or not available'
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


DROP TRIGGER IF EXISTS t_bf_ins_reservation;

DELIMITER $
CREATE TRIGGER t_bf_ins_reservation
BEFORE UPDATE
ON reservation FOR EACH ROW
BEGIN

      IF count_available_seats(NEW.id_seance) = 0 THEN
         SIGNAL SQLSTATE '42000'
         SET MESSAGE_TEXT = 'Seance is already full'
         ;
      END IF;
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
      SIGNAL SQLSTATE '42000'
      SET MESSAGE_TEXT = 'Salle is not valide'
      ;

      IF in_seance_type NOT IN (SELECT salle.type
                                FROM salle
                                WHERE salle.id = in_id_salle) THEN
         SIGNAL SQLSTATE '42000'
         SET MESSAGE_TEXT = 'Seance can not have different from salle types.'
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
CALL p_check_seance_type(NEW.type, NEW.id_salle);
$
DELIMITER ;

DROP TRIGGER IF EXISTS t_bf_up_seance;

DELIMITER $
CREATE TRIGGER t_bf_up_seance
BEFORE UPDATE
ON seance FOR EACH ROW
CALL p_check_seance_type(NEW.type, NEW.id_salle);
$
DELIMITER ;