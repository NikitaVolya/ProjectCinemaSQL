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
