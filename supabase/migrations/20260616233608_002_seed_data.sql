-- Insert some sample users
INSERT INTO users (id, username, description, bucks, bits) VALUES
    (1, 'admin', 'Welcome to Brick Hill!', 10000, 5000),
    (2, 'builder', 'I love building games!', 500, 100),
    (3, 'designer', 'Creating cool items is my passion.', 2500, 800),
    (4, 'gamer', 'Let us play some games!', 100, 50);

-- Insert sample items
INSERT INTO items (creator_id, name, description, type_id, price_bucks, price_bits, is_public, is_approved, is_pending, special, special_edition, special_q) VALUES
    (1, 'Classic Fedora', 'A timeless classic.', 1, 5, 50, TRUE, TRUE, FALSE, FALSE, FALSE, NULL),
    (1, 'Simple Hat', 'Keep it simple.', 1, 10, 100, TRUE, TRUE, FALSE, FALSE, FALSE, NULL),
    (1, 'Golden Crown', 'Rule in style!', 1, 50, NULL, TRUE, TRUE, FALSE, TRUE, FALSE, NULL),
    (3, 'Neon Shades', 'Bright and flashy.', 2, 15, 150, TRUE, TRUE, FALSE, FALSE, FALSE, NULL),
    (3, 'Cool Face', 'Express yourself.', 2, 20, 200, TRUE, TRUE, FALSE, FALSE, FALSE, NULL),
    (1, 'Limited Sword', 'A rare collectible. Only 10 in existence!', 4, NULL, NULL, TRUE, TRUE, FALSE, TRUE, TRUE, 10),
    (1, 'Casual Shirt', 'Everyday wear.', 5, 8, 80, TRUE, TRUE, FALSE, FALSE, FALSE, NULL),
    (3, 'Dark Pants', 'Sleek and stylish.', 6, 12, 120, TRUE, TRUE, FALSE, FALSE, FALSE, NULL),
    (1, 'Beta Hood', 'Exclusive beta tester reward.', 1, NULL, 500, TRUE, TRUE, FALSE, TRUE, FALSE, NULL),
    (3, 'Designer Beret', 'For the creative minds.', 1, 25, 250, TRUE, TRUE, FALSE, FALSE, FALSE, NULL);

-- Insert sample games
INSERT INTO sets (creator_id, name, description, visits, playing, is_featured) VALUES
    (1, 'Welcome to Brick Hill', 'The official starting place. Explore and meet new friends!', 15000, 42, TRUE),
    (2, 'Obby Challenge', 'Can you beat this challenging obstacle course? Test your skills!', 8500, 23, TRUE),
    (2, 'Build Your House', 'Create the home of your dreams in this creative building game.', 5200, 15, TRUE),
    (4, 'Combat Arena', 'Battle other players in this action-packed arena!', 3200, 18, FALSE),
    (2, 'Hangout Place', 'Chill with friends in this relaxed social space.', 2100, 8, FALSE),
    (4, 'Racing Track', 'Race against others on this exciting track!', 1800, 11, FALSE);

-- Insert sample forum threads
INSERT INTO forum_threads (author_id, title, is_pinned, is_locked) VALUES
    (1, 'Welcome to Brick Hill!', TRUE, FALSE),
    (1, 'Rules and Guidelines', TRUE, TRUE),
    (2, 'Show off your builds!', FALSE, FALSE),
    (3, 'Item suggestions thread', FALSE, FALSE),
    (4, 'Looking for players for my game', FALSE, FALSE);

-- Insert sample forum posts
INSERT INTO forum_posts (thread_id, author_id, content) VALUES
    (1, 1, 'Welcome to the Brick Hill community! We are excited to have you here. This is a place to create, play, and connect with others.'),
    (2, 1, 'Please read and follow these rules to keep our community safe and fun for everyone.'),
    (3, 2, 'Just finished my new house build! Check it out in my game "Build Your House"!'),
    (4, 3, 'I think we need more hat options in the shop. What do you all think?'),
    (5, 4, 'Anyone want to team up for Combat Arena? I need 2 more players!');