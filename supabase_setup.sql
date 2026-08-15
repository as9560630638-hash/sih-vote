-- Table for ideas
CREATE TABLE ideas (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  submitted_by TEXT NOT NULL,
  votes INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Table for tracking who voted for what (max 2 votes per user)
CREATE TABLE votes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  voter_name TEXT NOT NULL,
  idea_id UUID REFERENCES ideas(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(voter_name, idea_id)
);

-- Enable RLS
ALTER TABLE ideas ENABLE ROW LEVEL SECURITY;
ALTER TABLE votes ENABLE ROW LEVEL SECURITY;

-- Allow all operations via anon key (simple app, no auth)
CREATE POLICY "Allow all on ideas" ON ideas FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on votes" ON votes FOR ALL USING (true) WITH CHECK (true);

-- Function to increment vote count
CREATE OR REPLACE FUNCTION increment_vote(idea_row_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE ideas SET votes = votes + 1 WHERE id = idea_row_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to decrement vote count  
CREATE OR REPLACE FUNCTION decrement_vote(idea_row_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE ideas SET votes = votes - 1 WHERE id = idea_row_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
