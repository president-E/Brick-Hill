-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Item Types
CREATE TABLE item_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    display_name VARCHAR(100) NOT NULL
);

-- Users table (linked to Supabase Auth)
CREATE TABLE users (
    id BIGINT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    avatar_items JSONB DEFAULT '{"hats": [], "face": 0, "head": 0, "tool": 0}',
    avatar_colors JSONB DEFAULT '{"head": "F3B700", "torso": "B1B1B1", "left_arm": "F3B700", "right_arm": "F3B700", "left_leg": "E9EAEE", "right_leg": "E9EAEE"}',
    bucks INTEGER DEFAULT 10,
    bits INTEGER DEFAULT 0,
    power INTEGER DEFAULT 0,
    theme INTEGER DEFAULT 1,
    is_verified_designer BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    last_online TIMESTAMPTZ DEFAULT NOW()
);

-- Items table
CREATE TABLE items (
    id SERIAL PRIMARY KEY,
    creator_id BIGINT NOT NULL REFERENCES users(id),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    type_id INTEGER NOT NULL REFERENCES item_types(id),
    price_bucks INTEGER,
    price_bits INTEGER,
    is_public BOOLEAN DEFAULT TRUE,
    is_approved BOOLEAN DEFAULT FALSE,
    is_pending BOOLEAN DEFAULT TRUE,
    special BOOLEAN DEFAULT FALSE,
    special_edition BOOLEAN DEFAULT FALSE,
    special_q INTEGER,
    average_price INTEGER,
    thumbnail_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Sets (Games) table
CREATE TABLE sets (
    id SERIAL PRIMARY KEY,
    creator_id BIGINT NOT NULL REFERENCES users(id),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    visits INTEGER DEFAULT 0,
    playing INTEGER DEFAULT 0,
    max_players INTEGER,
    is_featured BOOLEAN DEFAULT FALSE,
    thumbnail_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Crates (User Inventory)
CREATE TABLE crates (
    id SERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    item_id INTEGER NOT NULL REFERENCES items(id),
    acquired_at TIMESTAMPTZ DEFAULT NOW()
);

-- Friends table
CREATE TABLE friends (
    id SERIAL PRIMARY KEY,
    from_id BIGINT NOT NULL REFERENCES users(id),
    to_id BIGINT NOT NULL REFERENCES users(id),
    is_pending BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(from_id, to_id),
    CHECK (from_id != to_id)
);

-- Trades table
CREATE TABLE trades (
    id SERIAL PRIMARY KEY,
    sender_id BIGINT NOT NULL REFERENCES users(id),
    receiver_id BIGINT NOT NULL REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'pending',
    sender_items INTEGER[] DEFAULT '{}',
    receiver_items INTEGER[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Messages table
CREATE TABLE messages (
    id SERIAL PRIMARY KEY,
    author_id BIGINT NOT NULL REFERENCES users(id),
    recipient_id BIGINT NOT NULL REFERENCES users(id),
    subject VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Forum Threads
CREATE TABLE forum_threads (
    id SERIAL PRIMARY KEY,
    author_id BIGINT NOT NULL REFERENCES users(id),
    title VARCHAR(200) NOT NULL,
    category_id INTEGER,
    is_locked BOOLEAN DEFAULT FALSE,
    is_pinned BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Forum Posts
CREATE TABLE forum_posts (
    id SERIAL PRIMARY KEY,
    thread_id INTEGER NOT NULL REFERENCES forum_threads(id) ON DELETE CASCADE,
    author_id BIGINT NOT NULL REFERENCES users(id),
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE items ENABLE ROW LEVEL SECURITY;
ALTER TABLE sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE crates ENABLE ROW LEVEL SECURITY;
ALTER TABLE friends ENABLE ROW LEVEL SECURITY;
ALTER TABLE trades ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE forum_threads ENABLE ROW LEVEL SECURITY;
ALTER TABLE forum_posts ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users
CREATE POLICY "users_select" ON users FOR SELECT TO authenticated USING (true);
CREATE POLICY "users_insert" ON users FOR INSERT TO authenticated WITH CHECK (auth.uid()::text = id::text);
CREATE POLICY "users_update" ON users FOR UPDATE TO authenticated USING (auth.uid()::text = id::text) WITH CHECK (auth.uid()::text = id::text);

-- RLS Policies for items (public read)
CREATE POLICY "items_select" ON items FOR SELECT TO authenticated USING (true);
CREATE POLICY "items_insert" ON items FOR INSERT TO authenticated WITH CHECK (auth.uid()::text = creator_id::text);
CREATE POLICY "items_update" ON items FOR UPDATE TO authenticated USING (auth.uid()::text = creator_id::text);

-- RLS Policies for sets (public read)
CREATE POLICY "sets_select" ON sets FOR SELECT TO authenticated USING (true);
CREATE POLICY "sets_insert" ON sets FOR INSERT TO authenticated WITH CHECK (auth.uid()::text = creator_id::text);
CREATE POLICY "sets_update" ON sets FOR UPDATE TO authenticated USING (auth.uid()::text = creator_id::text);

-- RLS Policies for crates (own inventory)
CREATE POLICY "crates_select" ON crates FOR SELECT TO authenticated USING (auth.uid()::text = user_id::text);
CREATE POLICY "crates_insert" ON crates FOR INSERT TO authenticated WITH CHECK (auth.uid()::text = user_id::text);
CREATE POLICY "crates_delete" ON crates FOR DELETE TO authenticated USING (auth.uid()::text = user_id::text);

-- RLS Policies for friends
CREATE POLICY "friends_select" ON friends FOR SELECT TO authenticated USING (auth.uid()::text = from_id::text OR auth.uid()::text = to_id::text);
CREATE POLICY "friends_insert" ON friends FOR INSERT TO authenticated WITH CHECK (auth.uid()::text = from_id::text);
CREATE POLICY "friends_update" ON friends FOR UPDATE TO authenticated USING (auth.uid()::text = to_id::text);
CREATE POLICY "friends_delete" ON friends FOR DELETE TO authenticated USING (auth.uid()::text = from_id::text OR auth.uid()::text = to_id::text);

-- RLS Policies for trades
CREATE POLICY "trades_select" ON trades FOR SELECT TO authenticated USING (auth.uid()::text = sender_id::text OR auth.uid()::text = receiver_id::text);
CREATE POLICY "trades_insert" ON trades FOR INSERT TO authenticated WITH CHECK (auth.uid()::text = sender_id::text);
CREATE POLICY "trades_update" ON trades FOR UPDATE TO authenticated USING (auth.uid()::text = receiver_id::text);

-- RLS Policies for messages
CREATE POLICY "messages_select" ON messages FOR SELECT TO authenticated USING (auth.uid()::text = author_id::text OR auth.uid()::text = recipient_id::text);
CREATE POLICY "messages_insert" ON messages FOR INSERT TO authenticated WITH CHECK (auth.uid()::text = author_id::text);

-- RLS Policies for forum_threads (public read)
CREATE POLICY "forum_threads_select" ON forum_threads FOR SELECT TO authenticated USING (true);
CREATE POLICY "forum_threads_insert" ON forum_threads FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "forum_threads_update" ON forum_threads FOR UPDATE TO authenticated USING (true);

-- RLS Policies for forum_posts (public read)
CREATE POLICY "forum_posts_select" ON forum_posts FOR SELECT TO authenticated USING (true);
CREATE POLICY "forum_posts_insert" ON forum_posts FOR INSERT TO authenticated WITH CHECK (true);

-- Insert default item types
INSERT INTO item_types (name, display_name) VALUES
    ('hat', 'Hat'),
    ('face', 'Face'),
    ('head', 'Head'),
    ('tool', 'Tool'),
    ('shirt', 'Shirt'),
    ('pants', 'Pants'),
    ('tshirt', 'T-Shirt');

-- Create indexes for better performance
CREATE INDEX idx_items_creator ON items(creator_id);
CREATE INDEX idx_items_type ON items(type_id);
CREATE INDEX idx_items_public_approved ON items(is_public, is_approved) WHERE is_public = TRUE AND is_approved = TRUE;

CREATE INDEX idx_sets_creator ON sets(creator_id);
CREATE INDEX idx_sets_playing ON sets(playing DESC);

CREATE INDEX idx_crates_user ON crates(user_id);
CREATE INDEX idx_crates_item ON crates(item_id);

CREATE INDEX idx_friends_from ON friends(from_id);
CREATE INDEX idx_friends_to ON friends(to_id);

CREATE INDEX idx_trades_sender ON trades(sender_id);
CREATE INDEX idx_trades_receiver ON trades(receiver_id);

CREATE INDEX idx_messages_recipient ON messages(recipient_id);
CREATE INDEX idx_messages_author ON messages(author_id);

CREATE INDEX idx_forum_threads_author ON forum_threads(author_id);
CREATE INDEX idx_forum_posts_thread ON forum_posts(thread_id);