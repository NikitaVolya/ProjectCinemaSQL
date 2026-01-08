
SET @v_salt = 'base_de_donne';

DELIMITER $

/* START PROCEDURES */
DROP PROCEDURE IF EXISTS p_add_subscribe;
CREATE PROCEDURE p_add_subscribe(

    IN in_name VARCHAR(255) ,
    IN in_price DECIMAL(5,2),
    IN in_reduce SMALLINT,
    IN in_priority BOOLEAN ,
    IN in_reserved_place BOOLEAN 
)
BEGIN
    DECLARE v_name VARCHAR(255);

    SELECT name
    INTO v_name
    FROM subscribe
    WHERE in_name = name
    ;

    IF v_name IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'le nom de subscribe est deja utilise';
    END IF;

    INSERT INTO subscribe (name, price, reduce, priority, reserved_place) VALUES (in_name, in_price, in_reduce,in_priority, in_reserved_place);
    

END;

$
DROP PROCEDURE IF EXISTS p_add_user;
CREATE PROCEDURE p_add_user(

    IN in_first_name VARCHAR(255) ,
    IN in_last_name VARCHAR(255) ,
    IN in_surname VARCHAR(255 ),
    IN in_email VARCHAR(255) ,
    IN in_passwrd VARCHAR(255) 
)
BEGIN
    DECLARE v_hash varchar(64);
    DECLARE v_test TINYINT UNSIGNED;
    SET v_hash = SHA2(CONCAT(@v_salt, in_passwrd), 256);
    SET v_test = 0 ;

    SELECT count(email) 
    INTO v_test
    FROM `user`
    WHERE in_email = email ;
    
    IF (v_test = 1) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'adresse email deja utilise';
    END IF; 

    SELECT count(surname)
    INTO v_test
    FROM `user`
    WHERE in_surname = surname ;
    
    IF (v_test = 1) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'surname deja utilise';
    END IF; 

    INSERT INTO `user` (first_name, last_name, surname, email, passwrd, id_sub, end_sub)
    VALUES (in_first_name, in_last_name, in_surname, in_email, v_hash, NULL, NULL);
    
END;

$
DROP PROCEDURE IF EXISTS p_delete_user;
CREATE PROCEDURE p_delete_user(
       IN in_surname VARCHAR(255)
)
BEGIN
       DELETE FROM `user` 
       WHERE surname = in_surname;
END;

$
DROP PROCEDURE IF EXISTS p_authenticate_user;
CREATE PROCEDURE p_authenticate_user(
       IN in_surname VARCHAR(255),
       IN in_password VARCHAR(255)
)
BEGIN
        DECLARE v_user_hash VARCHAR(255);
        DECLARE v_hash VARCHAR(255);

        DECLARE EXIT HANDLER
        FOR NOT FOUND
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User not found'
        ;

        SELECT passwrd
        INTO v_user_hash
        FROM `user`
        WHERE `user`.surname = in_surname
        ;

        SET v_hash = SHA2(CONCAT(@v_salt, in_password), 256);

        IF v_user_hash <> v_hash THEN
           SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Passord incorrect'
           ;
        ELSE
           SELECT 'Authentication successfully' as result;
        END IF;
END;

$
DROP PROCEDURE IF EXISTS p_add_sub_user;
CREATE PROCEDURE p_add_sub_user(
    IN in_surname VARCHAR(255),
    IN in_subscribe VARCHAR(255),
    IN in_end_sub DATE
)
BEGIN
    DECLARE v_id_sub INT UNSIGNED;
    DECLARE v_id_user INT UNSIGNED;

    SET v_id_sub = f_search_id_sub(in_subscribe);
    SET v_id_user = f_search_id_user(in_surname);

    UPDATE `user`
    SET id_sub = v_id_sub,
        end_sub = in_end_sub
    WHERE id = v_id_user;
END;

$
DROP PROCEDURE IF EXISTS p_delete_sub_user;
CREATE PROCEDURE p_delete_sub_user(
    IN in_surname VARCHAR(255)
)
BEGIN

    DECLARE v_id_user INT UNSIGNED;


    SET v_id_user = f_search_id_user(in_surname);

    UPDATE `user`
    SET id_sub = NULL,
        end_sub = NULL
    WHERE id = v_id_user;
END;

$

DROP PROCEDURE IF EXISTS p_seance_info
;
/*
        Output info for seance id | available seats | reserved seats | seance capacity
        In in_id_seance - Seance id to output information
*/
CREATE PROCEDURE p_seance_info(
     IN in_id_seance INT UNSIGNED
)
BEGIN
        DECLARE EXIT HANDLER
        FOR NOT FOUND
        SIGNAL SQLSTATE '42000'
        SET MESSAGE_TEXT = 'Seance is not exists'
        ;

        SELECT seance.id,
        f_count_available_seats(in_id_seance) AS available_seats,
        f_count_reserved_seats(in_id_seance) AS reserved_seats,
        salle.capacity
        FROM seance, salle
        WHERE seance.id_salle = salle.id
        AND seance.id = in_id_seance;
END;

$
DROP PROCEDURE IF EXISTS p_add_seance_for_movie;
CREATE PROCEDURE p_add_seance_for_movie(
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
DROP PROCEDURE IF EXISTS p_check_passage_seat;
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

        IF NOT f_is_seat_available(v_id_seance, in_seat) THEN
           SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'seat is already reserved or not available'
           ;
        END IF;

        IF f_check_seance_is_ended(v_id_seance) THEN
           SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Seance already ended'
           ;
        END IF;
END;

$
DROP PROCEDURE IF EXISTS p_check_seance_type;
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
DROP PROCEDURE IF EXISTS p_check_seance_movie_time;
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

DROP PROCEDURE IF EXISTS seance_info
;

$

CREATE PROCEDURE seance_info(
     IN in_id_seance INT UNSIGNED
)
BEGIN
        DECLARE v_seance_capacity INT UNSIGNED;

        DECLARE EXIT HANDLER
        FOR NOT FOUND
        SIGNAL SQLSTATE '42000'
        SET MESSAGE_TEXT = 'Seance is not exists'
        ;

        SELECT
        f_count_available_seats(in_id_seance) AS available_seats,
        f_count_reserved_seats(in_id_seance) AS reserved_seats,
        salle.capacity,
        (
         SELECT SUM(f_reservation_price(reservation.id))
         FROM reservation
         WHERE id_seance = seance.id
        ) as 'total_profit'
        FROM seance, salle
        WHERE seance.id_salle = salle.id
        AND seance.id = in_id_seance
        ;

        SELECT
        reservation.id as id_reservation,
        reservation.id_user,
        f_reservation_price(reservation.id) as price,
        COUNT(passage.seat) as seats_number
        FROM reservation, passage
        WHERE reservation.id_seance = in_id_seance
        AND passage.id_reservation = reservation.id
        GROUP BY reservation.id
        ;

END;

/* END PROCEDURES */
$
/* START FUNCTIONS */

DROP FUNCTION IF EXISTS f_search_id_sub;

CREATE FUNCTION f_search_id_sub(
    in_name_sub VARCHAR(255)
)
RETURNS INT UNSIGNED
DETERMINISTIC
READS SQL DATA
BEGIN

        DECLARE v_id_sub INT UNSIGNED;

        DECLARE EXIT HANDLER
        FOR NOT FOUND
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'error subscribe not found. Retry '
        ;

        SELECT id 
        INTO v_id_sub
        FROM subscribe
        WHERE name = in_name_sub;

        RETURN v_id_sub ; 

END ;

$
DROP FUNCTION IF EXISTS f_search_id_user;

CREATE FUNCTION f_search_id_user(
    in_name_user VARCHAR(255)
)
RETURNS INT UNSIGNED
DETERMINISTIC
READS SQL DATA
BEGIN

        DECLARE v_id_user INT UNSIGNED;

        DECLARE EXIT HANDLER
        FOR NOT FOUND
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'error user not found. Retry '
        ;

        SELECT id 
        INTO v_id_user
        FROM user
        WHERE surname = in_name_user;

        RETURN v_id_user ; 
END ;

$
DROP FUNCTION IF EXISTS f_is_seat_available;

/*
        Return if seat is available on seance

        In in_id_seance - Seance id to check seat
        In in_seat - Seat number
*/
CREATE FUNCTION f_is_seat_available(
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
DROP FUNCTION IF EXISTS f_count_reserved_seats;

/*
        Count number of seats reserved on seance

        In in_id_seance - Seance id to check
*/
CREATE FUNCTION f_count_reserved_seats(
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
DROP FUNCTION IF EXISTS f_count_available_seats;
/*
        Count number of seats available on seance

        In in_id_seance - Seance id to check
*/
CREATE FUNCTION f_count_available_seats(
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
        RETURN v_seance_capacity - f_count_reserved_seats(in_id_seance);
END;

$
DROP FUNCTION IF EXISTS f_check_on_seance_in_datetime;
CREATE FUNCTION f_check_on_seance_in_datetime(
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
DROP FUNCTION IF EXISTS f_check_seance_is_started;
CREATE FUNCTION f_check_seance_is_started(
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
DROP FUNCTION IF EXISTS f_check_seance_is_ended;
CREATE FUNCTION f_check_seance_is_ended(
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

DROP FUNCTION IF EXISTS f_reservation_price;
CREATE FUNCTION f_reservation_price(
       in_id_reservation INT UNSIGNED
)
RETURNS DECIMAL(3, 2)
READS SQL DATA
BEGIN
        DECLARE v_seance_price DECIMAL(5, 2);
        DECLARE v_passages_count INT UNSIGNED;
        DECLARE v_reduce TINYINT UNSIGNED;

        DECLARE EXIT HANDLER
        FOR NOT FOUND
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Reservation is not exists';

        SELECT price
        INTO v_seance_price
        FROM reservation, seance
        WHERE seance.id = reservation.id_seance
        AND reservation.id = in_id_reservation
        ;

        SELECT COUNT(passage.seat)
        INTO v_passages_count
        FROM passage
        WHERE passage.id_reservation = in_id_reservation
        ;

        IF (SELECT id_user FROM reservation WHERE reservation.id = in_id_reservation) IS NULL THEN
           RETURN v_seance_price * v_passages_count;
        ELSE
           BEGIN
                DECLARE CONTINUE HANDLER
                FOR NOT FOUND
                SET v_reduce = 0;

                SELECT subscribe.reduce
                INTO v_reduce
                FROM subscribe, user, reservation
                WHERE reservation.id = in_id_reservation
                AND user.id = reservation.id_user
                AND subscribe.id = user.id_sub
                AND DATE(NOW()) <= user.end_sub
                ;

                RETURN (v_seance_price - v_seance_price * v_reduce / 100) * v_passages_count;
           END;
        END IF;

END;

/* END FUNCTIONS */

/* START TRIGGERS */
$
DROP TRIGGER IF EXISTS t_actor_movie_life;
CREATE TRIGGER t_actor_movie_life
BEFORE INSERT ON movie_actor
FOR EACH ROW
BEGIN
    DECLARE v_actor_birthday DATETIME;
    DECLARE v_actor_deathday DATETIME;
    DECLARE v_movie_release_date DATE;

    SELECT birthday, deathday
    INTO v_actor_birthday, v_actor_deathday
    FROM actor
    WHERE id = NEW.actor_id;

    SELECT release_date
    INTO v_movie_release_date
    FROM movie
    WHERE id = NEW.movie_id;

    IF v_actor_birthday IS NOT NULL AND
       NEW.role IS NOT NULL AND
       NEW.role = 'Lead' AND
       v_actor_deathday IS NOT NULL AND
       v_movie_release_date IS NOT NULL AND
       v_movie_release_date BETWEEN 1000 AND 9999 AND
       v_movie_release_date > YEAR(v_actor_deathday) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Un acteur décédé avant l\'année de sortie du film ne peut pas être assigné à un rôle principal';
    END IF;
END;

$
DROP TRIGGER IF EXISTS t_bf_ins_passage;
CREATE TRIGGER t_bf_ins_passage
BEFORE INSERT
ON passage FOR EACH ROW
CALL p_check_passage_seat(NEW.id_reservation, NEW.seat);

$
DROP TRIGGER IF EXISTS t_bf_up_passage;
CREATE TRIGGER t_bf_up_passage
BEFORE UPDATE
ON passage FOR EACH ROW
CALL p_check_passage_seat(NEW.id_reservation, NEW.seat);

$
DROP TRIGGER IF EXISTS t_af_del_passage;
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
DROP TRIGGER IF EXISTS t_bf_ins_reservation;
CREATE TRIGGER t_bf_ins_reservation
BEFORE INSERT
ON reservation FOR EACH ROW
BEGIN

      IF f_check_seance_is_ended(NEW.id_seance) THEN
         SIGNAL SQLSTATE '45000'
         SET MESSAGE_TEXT = 'Seance is already ended'
         ;
      END IF;

      IF f_count_available_seats(NEW.id_seance) = 0 THEN
         SIGNAL SQLSTATE '45000'
         SET MESSAGE_TEXT = 'Seance is already full'
         ;
      END IF;
END;

$
DROP TRIGGER IF EXISTS t_bf_up_reservation;
CREATE TRIGGER t_bf_up_reservation
BEFORE UPDATE
ON reservation FOR EACH ROW
BEGIN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Reservation update is not possible'
        ;
END;

$
DROP TRIGGER IF EXISTS t_bf_ins_seance;
CREATE TRIGGER t_bf_ins_seance
BEFORE INSERT
ON seance FOR EACH ROW
BEGIN

        IF NEW.start_time < NOW() THEN
           SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Seance can not start in the past'
           ;
        END IF;

        /* Validate that the seance type matches the salle configuration */
        CALL p_check_seance_type(NEW.type, NEW.id_salle);

        /* Validate that the seance duration time is greater or equale to movie runtime */
        CALL p_check_seance_movie_time(NEW.id_movie, NEW.start_time, NEW.end_time);

        /* Check on time */
        IF f_check_on_seance_in_datetime(NEW.id_salle, NEW.start_time, NEW.end_time) THEN
           SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Seance in this time already exists'
           ;
        END IF;

END;

$
DROP TRIGGER IF EXISTS t_bf_up_seance;
CREATE TRIGGER t_bf_up_seance
BEFORE UPDATE
ON seance FOR EACH ROW
BEGIN
        IF NEW.start_time < NOW() THEN
           SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Seance can not start in the past'
           ;
        END IF;

        /* Validate that the seance type matches the salle configuration */
        CALL p_check_seance_type(NEW.type, NEW.id_salle);
        
        /* Validate that the seance duration time is greater or equale to movie runtime */
        CALL p_check_seance_movie_time(NEW.id_movie, NEW.start_time, NEW.end_time);

        /* Check on time if new salle */
        IF NEW.id_salle <> OLD.id_salle THEN
           IF f_check_on_seance_in_datetime(NEW.id_salle, NEW.start_time, NEW.end_time) THEN
              SIGNAL SQLSTATE '45000'
              SET MESSAGE_TEXT = 'Seance in this time in new salle already exists'
              ;
           END IF;
        ELSE
           /* Check on new time */
           IF NEW.start_time <> OLD.start_time AND NEW.end_time <> OLD.end_time THEN

              IF f_check_on_seance_in_datetime(NEW.id_salle, NEW.start_time, NEW.end_time) THEN
                 SIGNAL SQLSTATE '45000'
                 SET MESSAGE_TEXT = 'Seance in this time in new salle already exists'
                 ;
              END IF;
              
           ELSE
              /* Check on new start time */
              IF NEW.start_time < OLD.start_time AND
              f_check_on_seance_in_datetime(NEW.id_salle, NEW.start_time, OLD.start_time) THEN
                 SIGNAL SQLSTATE '45000'
                 SET MESSAGE_TEXT = 'The new start time overlaps with an existing seance in this salle';
              END IF;

              /* Check on new end time */
              IF NEW.end_time > OLD.end_time AND
              f_check_on_seance_in_datetime(NEW.id_salle, OLD.end_time, NEW.end_time) THEN
                 SIGNAL SQLSTATE '45000'
                 SET MESSAGE_TEXT = 'The new end time overlaps with an existing seance in this salle';
              END IF;
           
           END IF;
           
        END IF;

END;

/* END TRIGGERS */
/* START EVENT */

$
DROP EVENT IF EXISTS e_date_subscribes;

CREATE EVENT e_date_subscribes 
ON SCHEDULE EVERY 1 DAY 
DO
BEGIN

        UPDATE `user`
        SET id_sub = NULL,
        end_sub = NULL
        WHERE end_sub = CURRENT_DATE();

END;

$

DROP EVENT IF EXISTS e_free_seance;

CREATE EVENT e_free_seance
ON SCHEDULE EVERY 1 YEAR
DO BEGIN

        DELETE FROM seance
        WHERE YEAR(seance.start_time) < YEAR(NOW()) - 1
        ;

END;

/* END EVENT */

$
DELIMITER ; 