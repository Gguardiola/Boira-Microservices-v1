CREATE TABLE IF NOT EXISTS posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT
);

-- Insert some sample data
INSERT INTO posts (title, content) VALUES
    ('First Postasdasd', 'This is the content of the first post.'),
    ('Second Post', 'This is the content of the second post.');