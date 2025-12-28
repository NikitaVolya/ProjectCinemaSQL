DROP TRIGGER IF EXISTS trg_movie_runtime_insert;
DROP TRIGGER IF EXISTS trg_movie_runtime_update;
DROP TRIGGER IF EXISTS trg_movie_rating_insert;
DROP TRIGGER IF EXISTS trg_actor_movie_life;
DROP TRIGGER IF EXISTS trg_movie_rating_update;
DROP TRIGGER IF EXISTS trg_cinema_begin;
DROP TRIGGER IF EXISTS trg_actor_deathday_insert;
DROP TRIGGER IF EXISTS trg_actor_deathday_update;

DELIMITER $
CREATE TRIGGER trg_movie_runtime_insert
BEFORE INSERT ON movie
FOR EACH ROW
BEGIN
    IF NEW.runtime IS NOT NULL AND
    NEW.runtime <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Runtime doit étre positif';
    END IF;  
END 
$
DELIMITER ;


DELIMITER $
CREATE TRIGGER trg_movie_runtime_update
BEFORE UPDATE ON movie
FOR EACH ROW
BEGIN
    IF NEW.runtime IS NOT NULL AND
    NEW.runtime <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Runtime doit étre positif';
    END IF;
END;
$
DELIMITER ;


DELIMITER $
CREATE TRIGGER trg_movie_rating_insert
BEFORE INSERT ON movie
FOR EACH ROW
BEGIN
    IF NEW.global_rating IS NOT NULL AND
    NEW.global_rating < 0 OR NEW.global_rating > 10 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Global rating doit étre entre 0 et 10';
    END IF;
END;
$
DELIMITER ;


DELIMITER $
CREATE TRIGGER trg_movie_rating_update
BEFORE UPDATE ON movie
FOR EACH ROW
BEGIN
    IF NEW.global_rating IS NOT NULL AND
    NEW.global_rating < 0 OR NEW.global_rating > 10 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Global rating doit étre entre 0 et 10';
    END IF;
END;
$
DELIMITER ;


DELIMITER $
CREATE TRIGGER trg_cinema_begin
BEFORE INSERT ON movie
FOR EACH ROW
BEGIN
    IF NEW.release_date IS NOT NULL AND
    NEW.release_date < 1888 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'L''année de sortie doit étre postérieure à 1888 (année du premier film)';
    END IF;
END;
$
DELIMITER ;


DELIMITER $
CREATE TRIGGER trg_actor_deathday_insert
BEFORE INSERT ON actor
FOR EACH ROW
BEGIN
    IF NEW.deathday IS NOT NULL AND
    NEW.deathday < NEW.birthday THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La date de décès ne peut pas être antérieure à la date de naissance';
    END IF;
END;
$
DELIMITER ;


DELIMITER $
CREATE TRIGGER trg_actor_deathday_update
BEFORE UPDATE ON actor
FOR EACH ROW
BEGIN
    IF NEW.deathday IS NOT NULL AND
    NEW.deathday < NEW.birthday THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La date de décès ne peut pas être antérieure à la date de naissance';
    END IF;
END
$
DELIMITER ;


DELIMITER $
CREATE TRIGGER trg_actor_movie_life
BEFORE INSERT ON movie_actor
FOR EACH ROW
BEGIN
    DECLARE actor_birthday DATETIME;
    DECLARE actor_deathday DATETIME;
    DECLARE movie_release_date DATE;

    SELECT birthday, deathday INTO actor_birthday, actor_deathday
    FROM actor
    WHERE id = NEW.actor_id;

    SELECT release_date INTO movie_release_date
    FROM movie
    WHERE id = NEW.movie_id;

    IF actor_birthday IS NOT NULL AND
       NEW.role IS NOT NULL AND
       NEW.role = 'Lead' AND
       actor_deathday IS NOT NULL AND
       movie_release_date IS NOT NULL AND
       movie_release_date BETWEEN 1000 AND 9999 AND
       movie_release_date > YEAR(actor_deathday) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Un acteur décédé avant l\'année de sortie du film ne peut pas être assigné à un rôle principal';
    END IF;
END
$
DELIMITER ;