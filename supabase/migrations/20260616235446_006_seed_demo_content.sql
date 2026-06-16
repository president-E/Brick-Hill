-- Insert sample items (need to use actual user IDs after signup)
-- Items will be associated with the first few users who sign up
-- For now, we'll use a placeholder approach - items need real creator_id

-- Insert sample games (same situation)
-- We'll insert these once a user exists

-- For testing, let's create a system to auto-populate demo content
-- when the first real user signs up

CREATE OR REPLACE FUNCTION public.seed_demo_content()
RETURNS void AS $$
DECLARE
    first_user_id UUID;
BEGIN
    -- Get the first user
    SELECT id INTO first_user_id FROM users ORDER BY created_at LIMIT 1;
    
    IF first_user_id IS NOT NULL THEN
        -- Insert sample items
        INSERT INTO items (creator_id, name, description, type_id, price_bucks, price_bits, is_public, is_approved, is_pending, special, special_edition, special_q) VALUES
            (first_user_id, 'Classic Fedora', 'A timeless classic.', 1, 5, 50, TRUE, TRUE, FALSE, FALSE, FALSE, NULL),
            (first_user_id, 'Simple Hat', 'Keep it simple.', 1, 10, 100, TRUE, TRUE, FALSE, FALSE, FALSE, NULL),
            (first_user_id, 'Golden Crown', 'Rule in style!', 1, 50, NULL, TRUE, TRUE, FALSE, TRUE, FALSE, NULL),
            (first_user_id, 'Neon Shades', 'Bright and flashy.', 2, 15, 150, TRUE, TRUE, FALSE, FALSE, FALSE, NULL),
            (first_user_id, 'Cool Face', 'Express yourself.', 2, 20, 200, TRUE, TRUE, FALSE, FALSE, FALSE, NULL),
            (first_user_id, 'Limited Sword', 'A rare collectible. Only 10 in existence!', 4, NULL, NULL, TRUE, TRUE, FALSE, TRUE, TRUE, 10),
            (first_user_id, 'Casual Shirt', 'Everyday wear.', 5, 8, 80, TRUE, TRUE, FALSE, FALSE, FALSE, NULL),
            (first_user_id, 'Dark Pants', 'Sleek and stylish.', 6, 12, 120, TRUE, TRUE, FALSE, FALSE, FALSE, NULL),
            (first_user_id, 'Beta Hood', 'Exclusive beta tester reward.', 1, NULL, 500, TRUE, TRUE, FALSE, TRUE, FALSE, NULL),
            (first_user_id, 'Designer Beret', 'For the creative minds.', 1, 25, 250, TRUE, TRUE, FALSE, FALSE, FALSE, NULL);

        -- Insert sample games
        INSERT INTO sets (creator_id, name, description, visits, playing, is_featured) VALUES
            (first_user_id, 'Welcome to Brick Hill', 'The official starting place. Explore and meet new friends!', 15000, 42, TRUE),
            (first_user_id, 'Obby Challenge', 'Can you beat this challenging obstacle course? Test your skills!', 8500, 23, TRUE),
            (first_user_id, 'Build Your House', 'Create the home of your dreams in this creative building game.', 5200, 15, TRUE),
            (first_user_id, 'Combat Arena', 'Battle other players in this action-packed arena!', 3200, 18, FALSE),
            (first_user_id, 'Hangout Place', 'Chill with friends in this relaxed social space.', 2100, 8, FALSE),
            (first_user_id, 'Racing Track', 'Race against others on this exciting track!', 1800, 11, FALSE);

        -- Insert sample forum threads
        INSERT INTO forum_threads (author_id, title, is_pinned, is_locked) VALUES
            (first_user_id, 'Welcome to Brick Hill!', TRUE, FALSE),
            (first_user_id, 'Rules and Guidelines', TRUE, TRUE),
            (first_user_id, 'Show off your builds!', FALSE, FALSE),
            (first_user_id, 'Item suggestions thread', FALSE, FALSE),
            (first_user_id, 'Looking for players for my game', FALSE, FALSE);

        -- Insert sample forum posts
        INSERT INTO forum_posts (thread_id, author_id, content) VALUES
            (1, first_user_id, 'Welcome to the Brick Hill community! We are excited to have you here. This is a place to create, play, and connect with others.'),
            (2, first_user_id, 'Please read and follow these rules to keep our community safe and fun for everyone.'),
            (3, first_user_id, 'Just finished my new house build! Check it out in my game!'),
            (4, first_user_id, 'I think we need more hat options in the shop. What do you all think?'),
            (5, first_user_id, 'Anyone want to team up for Combat Arena? I need 2 more players!');
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Call the seed function
SELECT public.seed_demo_content();