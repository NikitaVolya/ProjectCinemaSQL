

DROP EVENT IF EXISTS e_date_subscribes;

DROP TRIGGER IF EXISTS t_bf_up_seance;
DROP TRIGGER IF EXISTS t_bf_ins_seance;
DROP TRIGGER IF EXISTS t_bf_up_reservation;
DROP TRIGGER IF EXISTS t_bf_ins_reservation;
DROP TRIGGER IF EXISTS t_af_del_passage;
DROP TRIGGER IF EXISTS t_bf_up_passage;
DROP TRIGGER IF EXISTS t_bf_ins_passage;
DROP TRIGGER IF EXISTS t_actor_movie_life;

DROP FUNCTION IF EXISTS f_check_seance_is_ended;
DROP FUNCTION IF EXISTS f_check_seance_is_started;
DROP FUNCTION IF EXISTS f_check_on_seance_in_datetime;
DROP FUNCTION IF EXISTS f_count_available_seats;
DROP FUNCTION IF EXISTS f_count_reserved_seats;
DROP FUNCTION IF EXISTS f_is_seat_available;
DROP FUNCTION IF EXISTS f_search_id_user;
DROP FUNCTION IF EXISTS f_search_id_sub;

DROP PROCEDURE IF EXISTS p_seance_info;
DROP PROCEDURE IF EXISTS p_check_seance_movie_time;
DROP PROCEDURE IF EXISTS p_check_seance_type;
DROP PROCEDURE IF EXISTS p_check_passage_seat;
DROP PROCEDURE IF EXISTS p_add_seance_for_movie;
DROP PROCEDURE IF EXISTS p_seance_info;
DROP PROCEDURE IF EXISTS p_delete_sub_user;
DROP PROCEDURE IF EXISTS p_add_sub_user;
DROP PROCEDURE IF EXISTS p_authenticate_user;
DROP PROCEDURE IF EXISTS p_add_user;
DROP PROCEDURE IF EXISTS p_add_subscribe;



DROP TABLE IF EXISTS passage;
DROP TABLE IF EXISTS reservation;
DROP TABLE IF EXISTS seance;
DROP TABLE IF EXISTS salle;
DROP TABLE IF EXISTS cinema;

DROP TABLE IF EXISTS user;
DROP TABLE IF EXISTS subscribe;

DROP TABLE IF EXISTS movie_actor;
DROP TABLE IF EXISTS movie;
DROP TABLE IF EXISTS actor;

DROP DATABASE IF EXISTS cinema_db;