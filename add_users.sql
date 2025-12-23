CALL p_add_subscribes('basic', 50.00, 20, 0, 0); 
CALL p_add_subscribes('premium', 80.00, 30, 1, 0);
CALL p_add_subscribes('deluxe', 120.00, 40, 1, 1);

CALL p_add_users('Alice', 'Dupont', 'A.', 'alice.null@example.com', 'passAlice1', NULL, NULL);
CALL p_add_users('Bob', 'Martin', 'B.', 'bob.null@example.com', 'passBob1', NULL, NULL);

CALL p_add_users('Charlie', 'Durand', 'C.', 'charlie.basic@example.com', 'passCharlie1', 0, '2025-12-31');
CALL p_add_users('Diane', 'Petit', 'D.', 'diane.basic@example.com', 'passDiane1', 0, '2025-12-31');

CALL p_add_users('Lucas', 'Poitier', 'E.', 'lucas.prenium@example.com', 'passEve1', 1, '2025-12-31');
CALL p_add_users('Jean-luc', 'Creshman', 'F.', 'jean-luc.prenium@example.com', 'passFrank1', 1, '2025-12-31');

CALL p_add_users('Eve', 'Moreau', 'E.', 'eve.deluxe@example.com', 'passEve1', 2, '2025-12-31');
CALL p_add_users('Frank', 'Lemoine', 'F.', 'frank.deluxe@example.com', 'passFrank1', 2, '2025-12-31');
