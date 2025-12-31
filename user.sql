DROP TABLE IF EXISTS user ;
DROP TABLE IF EXISTS subscribe ;



CREATE TABLE subscribe (
       id INT UNSIGNED ,
       name VARCHAR(255) NOT NULL,
       price DECIMAL(5,2)NOT NULL,
       priority BOOLEAN DEFAULT 0,
       reserved_place BOOLEAN DEFAULT 0,
       PRIMARY KEY (id),
       CONSTRAINT chk_price CHECK (price > 0)
);



CREATE TABLE user (
       id INT UNSIGNED ,
       first_name VARCHAR(255) NOT NULL,
       last_name VARCHAR(255) NOT NULL,
       surname VARCHAR(255 )NOT NULL,
       email VARCHAR(255) NOT NULL,
       passwrd VARCHAR(255) NOT NULL,
       id_sub INT UNSIGNED DEFAULT NULL,
       end_sub DATE DEFAULT NULL,
       PRIMARY KEY (id),
       CONSTRAINT fk_id_sub_id FOREIGN KEY (id_sub) REFERENCES subscribe(id)
);


