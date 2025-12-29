DELIMITER //

CREATE 
PROCEDURE IF NOT EXISTS p_add_subscribes(

    IN in_name VARCHAR(255) ,
    IN in_price DECIMAL(5,2),
    IN in_reduce SMALLINT(100),
    IN in_priority BOOLEAN ,
    IN in_reserved_place BOOLEAN 
)
BEGIN
    DECLARE v_name VARCHAR(255);

    SELECT name
    INTO v_name
    FROM users
    WHERE in_name = name
    ;

    IF v_name IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'le nom de subscribe est deja utilise';
    END IF;

    INSERT INTO subscribes (name, price, reduce, priority, reserved_place) VALUES (in_name, in_price, in_reduce,in_priority, in_reserved_place);
    

END;
//

CREATE
PROCEDURE IF NOT EXISTS p_add_users(

    IN in_first_name VARCHAR(255) ,
    IN in_last_name VARCHAR(255) ,
    IN in_surname VARCHAR(255 ),
    IN in_email VARCHAR(255) ,
    IN in_passwrd VARCHAR(255) ,
    IN in_id_sub INT UNSIGNED ,
    IN in_end_sub DATE 
)

BEGIN
    DECLARE v_test INT UNSIGNED;
    DECLARE v_hash varchar(64) ;
    DECLARE v_salt varchar(255);

    DECLARE EXIT HANDLER
    FOR NOT FOUND
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'error id of subscribe not found. Retry '
        ;
   
   
    IF (in_id_sub IS NOT NULL) THEN 
        SELECT id 
        INTO v_test
        FROM subscribes
        WHERE id = in_id_sub ;
    END IF;

    set v_salt = 'base_de_donne';

    SET v_hash = SHA2(CONCAT(v_salt, in_passwrd), 256);


    INSERT INTO users (first_name, last_name,surname,email,passwrd,id_sub,end_sub) VALUES (in_first_name,in_last_name,in_surname,in_email,v_hash,in_id_sub,in_end_sub);
    
END;

//


CREATE PROCEDURE p_update_sub_user(
    IN in_surname VARCHAR(255),
    IN in_subscribe VARCHAR(255),
    IN in_end_sub DATE
)
BEGIN
    DECLARE v_id_sub INT UNSIGNED;
    DECLARE v_id_user INT UNSIGNED;

    SET v_id_sub = f_id_sub(in_subscribe);
    SET v_id_user = f_id_user(in_surname);

    UPDATE users
    SET id_sub = v_id_sub,
        end_sub = in_end_sub
    WHERE id = v_id_user;
END;

//

DELIMITER ;