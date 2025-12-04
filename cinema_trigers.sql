
DROP TRIGGER IF EXISTS t_bf_ins_passage;


DELIMITER $
CREATE TRIGGER t_bf_ins_passage
BEFORE INSERT
ON passage FOR EACH ROW
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
        AND reservation.id = NEW.id_reservation
        ;

        IF NOT is_seat_available(v_id_seance, NEW.seat) THEN
           SIGNAL SQLSTATE '42000'
           SET MESSAGE_TEXT = 'seat is already reserved'
           ;
        END IF;
END;
$
DELIMITER ;


DROP TRIGGER IF EXISTS t_bf_up_passage;

DELIMITER $
CREATE TRIGGER t_bf_up_passage
BEFORE UPDATE
ON passage FOR EACH ROW
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
      AND reservation.id = NEW.id_reservation
      ;

      IF NOT is_seat_available(v_id_seance, NEW.seat) THEN
         SIGNAL SQLSTATE '42000'
         SET MESSAGE_TEXT = 'Seat is already reserved'
         ;
      END IF;  
END;
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