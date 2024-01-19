-- TABLES
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS users (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    username TEXT NOT NULL,
    lastname TEXT NOT NULL,
    password TEXT NOT NULL,
    birthday DATE NOT NULL,
    bioDesc VARCHAR(500),
    image_name VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS friends (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    friend_id UUID REFERENCES users(id),
    is_friend BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS wishlists (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    wishlist_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS items (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    item_name VARCHAR(255) NOT NULL,
    item_description VARCHAR(500),
    item_url VARCHAR(255),
    image_name VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS gifts (
    id SERIAL PRIMARY KEY,
    item_id INTEGER REFERENCES items(id),
    user_id UUID REFERENCES users(id),
    gift_name VARCHAR(255) NOT NULL,
    gifted_user_id UUID REFERENCES users(id),
    is_delivered BOOLEAN NOT NULL,
    expiration_date DATE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- INTERMEDIATE TABLES
CREATE TABLE IF NOT EXISTS user_gifts (
    id SERIAL PRIMARY KEY,
    user_id UUID  REFERENCES users(id),
    gift_id INTEGER REFERENCES gifts(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    is_implicated BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS item_wishlists (
    id SERIAL PRIMARY KEY,
    item_id INTEGER REFERENCES items(id),
    wishlist_id INTEGER REFERENCES wishlists(id),
    added_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
  
-- AUTHENTICATION TABLES AND FUNCTIONS
CREATE TABLE IF NOT EXISTS token_blacklist (
  token_id SERIAL PRIMARY KEY,
  token VARCHAR(500) NOT NULL,
  logout_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_sessions (
  session_id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  token VARCHAR(500) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION cleanup_blacklist_tokens()
RETURNS TRIGGER AS $$
BEGIN
  DELETE FROM token_blacklist WHERE logout_date <= CURRENT_TIMESTAMP - INTERVAL '48 hours';
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cleanup_blacklist_trigger
AFTER INSERT ON token_blacklist
EXECUTE FUNCTION cleanup_blacklist_tokens();

-- Create a function to clean up old user sessions
CREATE OR REPLACE FUNCTION cleanup_user_sessions()
RETURNS TRIGGER AS $$
BEGIN
  DELETE FROM user_sessions WHERE created_at <= CURRENT_TIMESTAMP - INTERVAL '48 hours';
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger to execute the cleanup function after each session insertion
CREATE TRIGGER cleanup_user_sessions_trigger
AFTER INSERT ON user_sessions
EXECUTE FUNCTION cleanup_user_sessions();

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_id ON users(id);

CREATE INDEX idx_friends_user_id ON friends(user_id);
CREATE INDEX idx_friends_friend_id ON friends(friend_id);

CREATE INDEX idx_wishlists_user_id ON wishlists(user_id);
CREATE INDEX idx_wishlists_name ON wishlists(wishlist_name);

CREATE INDEX idx_items_user_id ON items(user_id);
CREATE INDEX idx_items_name ON items(item_name);

CREATE INDEX idx_gifts_item_id ON gifts(item_id);
CREATE INDEX idx_gifts_user_id ON gifts(user_id);
CREATE INDEX idx_gifts_gifted_user_id ON gifts(gifted_user_id);

CREATE INDEX idx_user_gifts_user_id ON user_gifts(user_id);
CREATE INDEX idx_user_gifts_gift_id ON user_gifts(gift_id);

CREATE INDEX idx_item_wishlists_item_id ON item_wishlists(item_id);


