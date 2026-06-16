-- Enable RLS on item_types table
ALTER TABLE item_types ENABLE ROW LEVEL SECURITY;

-- Add RLS policy for item_types (read-only for authenticated users)
CREATE POLICY "item_types_select" ON item_types FOR SELECT TO authenticated USING (true);

-- Fix forum_posts RLS policy (users can only post as themselves)
DROP POLICY IF EXISTS "forum_posts_insert" ON forum_posts;
CREATE POLICY "forum_posts_insert" ON forum_posts FOR INSERT TO authenticated WITH CHECK (auth.uid()::text = author_id::text);

-- Fix forum_threads RLS policies
DROP POLICY IF EXISTS "forum_threads_insert" ON forum_threads;
CREATE POLICY "forum_threads_insert" ON forum_threads FOR INSERT TO authenticated WITH CHECK (auth.uid()::text = author_id::text);

DROP POLICY IF EXISTS "forum_threads_update" ON forum_threads;
CREATE POLICY "forum_threads_update" ON forum_threads FOR UPDATE TO authenticated USING (auth.uid()::text = author_id::text) WITH CHECK (auth.uid()::text = author_id::text);