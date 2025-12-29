DROP TRIGGER IF EXISTS trg_actor_movie_life;

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