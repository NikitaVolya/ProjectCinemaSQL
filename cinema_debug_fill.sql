source cinema.sql


INSERT INTO cinema (name, city, address_name, address_number) VALUES
('MegaCinema Center', 'Paris', 'Boulevard Lumiere', 12),
('Skyline Cinema', 'Lyon', 'Rue de la République', 45),
('Galaxy Movies', 'Marseille', 'Avenue du Prado', 88),
('CineStar Max', 'Toulouse', 'Rue des Arts', 23),
('Royal Screens', 'Nice', 'Promenade du Soleil', 14),
('UrbanMovie Plaza', 'Bordeaux', 'Cours Victor Hugo', 66),
('Cinema Horizon', 'Nantes', 'Rue du Calvaire', 39),
('SilverFox Cinema', 'Lille', 'Rue de Paris', 77),
('NeonLights Cinema', 'Rennes', 'Avenue Janvier', 19),
('Cinema Lumière', 'Saint-Etienne', 'Rue de la Paix', 5);


INSERT INTO salle (id_cinema, name, capacity, type) VALUES
-- Cinema 1
(1, 'Salle Alpha', 120, '3D'),
(1, 'Salle Beta', 180, 'IMAX,3D'),
(1, 'Salle Gamma', 90, 'STANDART'),

-- Cinema 2
(2, 'Salle Lumiere', 150, '3D,STANDART'),
(2, 'Salle Rouge', 200, '4DX,IMAX'),
(2, 'Salle Vert', 110, 'STANDART'),

-- Cinema 3
(3, 'Salle Marine', 130, 'IMAX'),
(3, 'Salle Coral', 95, '3D,4DX'),
(3, 'Salle Pearl', 160, 'STANDART,3D'),

-- Cinema 4
(4, 'Salle Orion', 140, '4DX'),
(4, 'Salle Vega', 170, 'IMAX,4DX'),
(4, 'Salle Nova', 85, 'STANDART'),

-- Cinema 5
(5, 'Salle Azure', 125, '3D'),
(5, 'Salle Emerald', 190, '4DX,IMAX,3D'),
(5, 'Salle Amber', 105, 'STANDART,3D'),

-- Cinema 6
(6, 'Salle River', 135, 'STANDART,IMAX'),
(6, 'Salle Stone', 175, 'IMAX'),
(6, 'Salle Leaf', 100, '3D,STANDART'),

-- Cinema 7
(7, 'Salle Ultra', 160, 'IMAX,3D'),
(7, 'Salle Midi', 120, '3D'),
(7, 'Salle Petit', 80, 'STANDART'),

-- Cinema 8
(8, 'Salle Noir', 145, '4DX'),
(8, 'Salle Blanc', 115, '3D,IMAX'),
(8, 'Salle Gris', 180, 'IMAX'),

-- Cinema 9
(9, 'Salle Wave', 155, '3D'),
(9, 'Salle Breeze', 100, 'STANDART,3D'),
(9, 'Salle Storm', 190, 'IMAX,4DX'),

-- Cinema 10
(10, 'Salle Zenith', 170, 'IMAX'),
(10, 'Salle Opal', 95, 'STANDART'),
(10, 'Salle Jade', 130, '3D,4DX');


INSERT INTO seance (id_salle, start_time, end_time, price, type) VALUES
(1, '2025-01-10 14:00', '2025-01-10 16:00', 9.50, '3D'),
(1, '2025-01-10 18:00', '2025-01-10 20:00', 9.50, '3D'),

(3, '2025-01-09 10:00', '2025-01-09 12:00', 7.00, 'STANDART'),
(3, '2025-01-09 13:00', '2025-01-09 15:00', 7.00, 'STANDART'),

(6, '2025-01-07 11:00', '2025-01-07 13:00', 8.00, 'STANDART'),
(6, '2025-01-07 14:00', '2025-01-07 16:00', 8.00, 'STANDART'),

(7, '2025-01-10 13:00', '2025-01-10 15:30', 13.50, 'IMAX'),
(7, '2025-01-10 17:00', '2025-01-10 19:30', 13.50, 'IMAX'),

(10, '2025-01-09 10:00', '2025-01-09 12:30', 11.00, '4DX'),
(10, '2025-01-09 13:00', '2025-01-09 15:30', 11.00, '4DX'),

(12, '2025-01-14 16:00', '2025-01-14 18:30', 13.00, 'STANDART'),
(12, '2025-01-14 19:00', '2025-01-14 21:30', 13.00, 'STANDART')

;



DROP PROCEDURE IF EXISTS create_random_reservation
;

/*
   Create random reservation on seance in_id_seance with 
   in_seats_nb random seats on seanse
*/
DELIMITER $
CREATE PROCEDURE create_random_reservation(
       IN in_id_seance INT UNSIGNED,
       IN in_seats_nb INT UNSIGNED
)
BEGIN
        DECLARE v_seance_capacity INT UNSIGNED;
        DECLARE v_seat_number INT UNSIGNED;
        DECLARE v_id_reservation INT UNSIGNED;

        DECLARE EXIT HANDLER
        FOR NOT FOUND
        SIGNAL SQLSTATE '42000'
        SET MESSAGE_TEXT = 'Seace is not exitst'
        ;

        SELECT salle.capacity
        INTO v_seance_capacity
        FROM seance, salle
        WHERE seance.id_salle = salle.id
        AND seance.id = in_id_seance
        ;        

        IF in_seats_nb = 0 THEN
           SIGNAL SQLSTATE '42000'
           SET MESSAGE_TEXT = 'Seats number can`t be 0'
           ;
        END IF;

        IF count_available_seats(in_id_seance) < in_seats_nb THEN
           SIGNAL SQLSTATE '42000'
           SET MESSAGE_TEXT = 'Not enough available seats'
           ;
        END IF;

        INSERT INTO reservation(id_seance) VALUES (in_id_seance);

        SELECT id
        INTO v_id_reservation
        FROM reservation
        ORDER BY id DESC
        LIMIT 1
        ;

        passage_loop: LOOP
           IF in_seats_nb = 0 THEN
              LEAVE passage_loop;
           END IF;

           seat_loop: LOOP
              SET v_seat_number = FLOOR(RAND() * v_seance_capacity + 1);

              IF is_seat_available(in_id_seance, v_seat_number) THEN
                 LEAVE seat_loop;
              END IF;
           END LOOP seat_loop;

           INSERT INTO passage(id_reservation, seat) VALUES (v_id_reservation, v_seat_number);

           SET in_seats_nb = in_seats_nb - 1;
        END LOOP passage_loop;
END;

$
DELIMITER ;

DROP PROCEDURE IF EXISTS fill_seance
;

/*
   Reserve in_nb_seats with random number of reservation
   on seance with id in_id_seance
*/
DELIMITER $
CREATE PROCEDURE fill_seance(
       IN in_id_seance INT UNSIGNED,
       IN in_nb_seats INT UNSIGNED
)
BEGIN
        DECLARE v_reservation_seats INT UNSIGNED;
        
        seats_loop: LOOP
           IF in_nb_seats = 0 THEN
              LEAVE seats_loop;
           END IF;

           SET v_reservation_seats = FLOOR(RAND() * 5 + 1);

           CALL create_random_reservation(in_id_seance, v_reservation_seats);
           
           IF v_reservation_seats > in_nb_seats THEN
              SET v_reservation_seats = in_nb_seats;
           END IF;

           SET in_nb_seats = in_nb_seats - v_reservation_seats;
        END LOOP seats_loop;
END;
$
DELIMITER ;



DROP PROCEDURE IF EXISTS fill_seances
;

/*
   Fille all seance seats with in_fille_procentage beetwen 0 and 100
*/
DELIMITER $
CREATE PROCEDURE fill_seances(
       IN in_fill_procentage INT UNSIGNED
)
BEGIN
        DECLARE v_id_seance INT UNSIGNED;
        DECLARE v_seance_available_seats INT UNSIGNED;
        DECLARE v_continue BOOLEAN DEFAULT TRUE;

        DECLARE seance_cursor CURSOR FOR
        SELECT seance.id, count_available_seats(seance.id)
        FROM seance
        ;

        DECLARE CONTINUE HANDLER
        FOR NOT FOUND
        SET v_continue = FALSE;

        IF (in_fill_procentage <= 0 OR in_fill_procentage > 100) THEN
           SIGNAL SQLSTATE '42000'
           SET MESSAGE_TEXT = 'in_fill_procentage must be beetwen 1 and 100'
           ;
        END IF;

        OPEN seance_cursor;
        
        seance_loop: LOOP
           FETCH seance_cursor
           INTO v_id_seance, v_seance_available_seats
           ;

           IF v_continue = FALSE THEN
              LEAVE seance_loop;
           END IF;

           SET v_seance_available_seats =  v_seance_available_seats * in_fill_procentage / 100;
           
           SELECT CONCAT('Create ', CAST(v_seance_available_seats AS CHAR), ' random seat reservations for seance ', CAST(v_id_seance AS CHAR)) AS 'result';
           
           CALL fill_seance(v_id_seance, v_seance_available_seats);

                     
        END LOOP seance_loop;
        
        CLOSE seance_cursor;
END;
$
DELIMITER ;

CALL fill_seances(20);