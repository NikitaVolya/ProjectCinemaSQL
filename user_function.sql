DELIMITER //

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
        SET MESSAGE_TEXT = 'error id subscribe not found. Retry '
        ;

        SELECT id 
        INTO v_id_sub
        FROM subscribes
        WHERE name = in_name_sub;

        RETURN v_id_sub ; 

END ; 
//

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
        SET MESSAGE_TEXT = 'error id users not found. Retry '
        ;

SELECT id 
INTO v_id_user
FROM users
WHERE surname = in_name_user;

RETURN v_id_user ; 

END ; 
//

DELIMITER ; 