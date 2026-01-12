 source suppression.sql
 source creation.sql
 source objects.sql

INSERT INTO movie (title, release_date, runtime, genre, description, global_rating, poster_url) VALUES
('Inception', '2010-07-16', '02:28:00', 'Sci-Fi',
 'A skilled thief enters dreams to steal secrets.',
 8.80, 'https://example.com/inception.jpg'),

('Interstellar', '2014-11-07', '02:49:00', 'Sci-Fi',
 'Explorers travel through a wormhole to save humanity.',
 8.60, 'https://example.com/interstellar.jpg'),

('The Dark Knight', '2008-07-18', '02:32:00', 'Action',
 'Batman faces the Joker in Gotham City.',
 9.00, 'https://example.com/dark_knight.jpg'),

('Gladiator', '2000-05-05', '02:35:00', 'Action',
 'A Roman general seeks revenge.',
 8.50, 'https://example.com/gladiator.jpg'),

('The Matrix', '1999-03-31', '02:16:00', 'Sci-Fi',
 'A hacker discovers the truth about reality.',
 8.70, 'https://example.com/matrix.jpg');

INSERT INTO actor (first_name, last_name, birthday, deathday, biography, photo_url) VALUES
('Leonardo', 'DiCaprio', '1974-11-11 00:00:00', NULL,
 'American actor and producer.',
 'https://example.com/dicaprio.jpg'),

('Joseph', 'Gordon-Levitt', '1981-02-17 00:00:00', NULL,
 'American actor and filmmaker.',
 'https://example.com/gordon_levitt.jpg'),

('Matthew', 'McConaughey', '1969-11-04 00:00:00', NULL,
 'American actor.',
 'https://example.com/mcconaughey.jpg'),

('Christian', 'Bale', '1974-01-30 00:00:00', NULL,
 'English actor.',
 'https://example.com/bale.jpg'),

('Heath', 'Ledger', '1979-04-04 00:00:00', '2008-01-22 00:00:00',
 'Australian actor.',
 'https://example.com/ledger.jpg'),

('Russell', 'Crowe', '1964-04-07 00:00:00', NULL,
 'Actor known for historical roles.',
 'https://example.com/crowe.jpg'),

('Keanu', 'Reeves', '1964-09-02 00:00:00', NULL,
 'Canadian actor.',
 'https://example.com/reeves.jpg'),

('Laurence', 'Fishburne', '1961-07-30 00:00:00', NULL,
 'American actor.',
 'https://example.com/fishburne.jpg');

INSERT INTO movie_actor (character_name, role, movie_id, actor_id) VALUES
('Dom Cobb', 'Lead', 1, 1),
('Arthur', 'Supporting', 1, 2),

('Cooper', 'Lead', 2, 3),

('Bruce Wayne / Batman', 'Lead', 3, 4),
('Joker', 'Antagonist', 3, 5),

('Maximus', 'Lead', 4, 6),

('Neo', 'Lead', 5, 7),
('Morpheus', 'Supporting', 5, 8);

CALL p_add_subscribe('basic', 50.00, 20, 0, 0); 
CALL p_add_subscribe('premium', 80.00, 30, 1, 0);
CALL p_add_subscribe('deluxe', 120.00, 40, 1, 1);

CALL p_add_user('Alice', 'Dupont', 'A.', 'alice.null@example.com', 'passAlice1');
CALL p_add_user('Bob', 'Martin', 'B.', 'bob.null@example.com', 'passBob1');

CALL p_add_user('Charlie', 'Durand', 'C.', 'charlie.basic@example.com', 'passCharlie1');
CALL p_add_user('Diane', 'Petit', 'D.', 'diane.basic@example.com', 'passDiane1');

CALL p_add_user('Lucas', 'Poitier', 'E.', 'lucas.prenium@example.com', 'passEve1');
CALL p_add_user('Jean-luc', 'Creshman', 'F.', 'jean-luc.prenium@example.com', 'passFrank1');

CALL p_add_user('Eve', 'Moreau', 'G.', 'eve.deluxe@example.com', 'passEve1');
CALL p_add_user('Frank', 'Lemoine', 'H.', 'frank.deluxe@example.com', 'passFrank1');

CALL p_add_sub_user('A.', 'premium', CURDATE() + INTERVAL 1 MONTH);
CALL p_add_sub_user('C.', 'deluxe', CURDATE() + INTERVAL 10 DAY);
CALL p_add_sub_user('E.', 'basic', CURDATE() + INTERVAL 2 DAY);
CALL p_add_sub_user('H.', 'premium', CURDATE() + INTERVAL 4 DAY);

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

CALL p_add_seance_for_movie(1, 1, '00:15:00', CURDATE() + INTERVAL 1 DAY + INTERVAL 10 HOUR, 9.50, '3D');
CALL p_add_seance_for_movie(2, 2, '00:15:00', CURDATE() + INTERVAL 1 DAY + INTERVAL 13 HOUR + INTERVAL 30 MINUTE, 13.00, 'IMAX');
CALL p_add_seance_for_movie(3, 3, '00:15:00', CURDATE() + INTERVAL 1 DAY + INTERVAL 17 HOUR, 8.50, 'STANDART');
CALL p_add_seance_for_movie(1, 4, '00:10:00', CURDATE() + INTERVAL 3 DAY + INTERVAL 14 HOUR, 9.00, '3D');
CALL p_add_seance_for_movie(2, 5, '00:15:00', CURDATE() + INTERVAL 3 DAY + INTERVAL 20 HOUR + INTERVAL 30 MINUTE, 14.00, 'IMAX');

CALL p_add_seance_for_movie(4, 1, '00:15:00', CURDATE() + INTERVAL 2 DAY + INTERVAL 10 HOUR, 9.00, '3D');
CALL p_add_seance_for_movie(5, 3, '00:10:00', CURDATE() + INTERVAL 2 DAY + INTERVAL 17 HOUR, 13.50, '4DX');
CALL p_add_seance_for_movie(6, 2, '00:15:00', CURDATE() + INTERVAL 2 DAY + INTERVAL 20 HOUR + INTERVAL 30 MINUTE, 10.00, 'STANDART');
CALL p_add_seance_for_movie(4, 5, '00:15:00', CURDATE() + INTERVAL 5 DAY + INTERVAL 13 HOUR + INTERVAL 30 MINUTE, 9.50, '3D');
CALL p_add_seance_for_movie(5, 4, '00:10:00', CURDATE() + INTERVAL 5 DAY + INTERVAL 18 HOUR, 14.00, 'IMAX');

CALL p_add_seance_for_movie(7, 2, '00:15:00', CURDATE() + INTERVAL 1 DAY + INTERVAL 11 HOUR, 13.00, 'IMAX');
CALL p_add_seance_for_movie(8, 1, '00:15:00', CURDATE() + INTERVAL 1 DAY + INTERVAL 15 HOUR, 12.00, '4DX');
CALL p_add_seance_for_movie(9, 5, '00:15:00', CURDATE() + INTERVAL 1 DAY + INTERVAL 19 HOUR, 10.00, 'STANDART');
CALL p_add_seance_for_movie(7, 3, '00:10:00', CURDATE() + INTERVAL 6 DAY + INTERVAL 14 HOUR, 13.50, 'IMAX');
CALL p_add_seance_for_movie(8, 4, '00:15:00', CURDATE() + INTERVAL 6 DAY + INTERVAL 20 HOUR + INTERVAL 30 MINUTE, 12.50, '4DX');

CALL p_add_seance_for_movie(28, 1, '00:15:00', CURDATE() + INTERVAL 2 DAY + INTERVAL 10 HOUR, 11.00, 'IMAX');
CALL p_add_seance_for_movie(29, 4, '00:15:00', CURDATE() + INTERVAL 2 DAY + INTERVAL 14 HOUR, 8.50, 'STANDART');
CALL p_add_seance_for_movie(30, 5, '00:10:00', CURDATE() + INTERVAL 2 DAY + INTERVAL 18 HOUR, 10.50, '3D');
CALL p_add_seance_for_movie(28, 2, '00:15:00', CURDATE() + INTERVAL 7 DAY + INTERVAL 20 HOUR + INTERVAL 30 MINUTE, 13.50, 'IMAX');
CALL p_add_seance_for_movie(30, 3, '00:15:00', CURDATE() + INTERVAL 7 DAY + INTERVAL 15 HOUR, 11.00, '4DX');




DROP PROCEDURE IF EXISTS p_create_random_reservation
;

/*
   Create random reservation on seance in_id_seance with 
   in_seats_nb random seats on seanse
*/
DELIMITER $
CREATE PROCEDURE p_create_random_reservation(
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

        IF f_count_available_seats(in_id_seance) < in_seats_nb THEN
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

              IF f_is_seat_available(in_id_seance, v_seat_number) THEN
                 LEAVE seat_loop;
              END IF;
           END LOOP seat_loop;

           INSERT INTO passage(id_reservation, seat) VALUES (v_id_reservation, v_seat_number);

           SET in_seats_nb = in_seats_nb - 1;
        END LOOP passage_loop;
END;

$
DELIMITER ;

DROP PROCEDURE IF EXISTS p_fill_seance
;

/*
   Reserve in_nb_seats with random number of reservation
   on seance with id in_id_seance
*/
DELIMITER $
CREATE PROCEDURE p_fill_seance(
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

           CALL p_create_random_reservation(in_id_seance, v_reservation_seats);
           
           IF v_reservation_seats > in_nb_seats THEN
              SET v_reservation_seats = in_nb_seats;
           END IF;

           SET in_nb_seats = in_nb_seats - v_reservation_seats;
        END LOOP seats_loop;
END;
$
DELIMITER ;



DROP PROCEDURE IF EXISTS p_fill_seances
;

/*
   Fille all seance seats with in_fille_procentage beetwen 0 and 100
*/
DELIMITER $
CREATE PROCEDURE p_fill_seances(
       IN in_fill_procentage INT UNSIGNED
)
BEGIN
        DECLARE v_id_seance INT UNSIGNED;
        DECLARE v_seance_available_seats INT UNSIGNED;
        DECLARE v_continue BOOLEAN DEFAULT TRUE;

        DECLARE seance_cursor CURSOR FOR
        SELECT seance.id, f_count_available_seats(seance.id)
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
           
           CALL p_fill_seance(v_id_seance, v_seance_available_seats);

                     
        END LOOP seance_loop;
        
        CLOSE seance_cursor;
END;
$
DELIMITER ;

CALL p_fill_seances(20);