DELIMITER //

CREATE
FUNCTION IF NOT EXISTS f_id_sub(
    IN in_name_sub VARCHAR(255)
)
RETURNS INT UNSIGNED

BEGIN

DECLARE v_id_sub INT UNSIGNED;

SELECT id 
INTO v_id_sub
FROM subscribes
WHERE name = in_name_sub;

RETURN v_id_sub ; 

END ; 
//
DELIMITER ; 