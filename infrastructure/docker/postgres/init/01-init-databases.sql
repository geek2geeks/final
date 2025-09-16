-- Initialize QuizzTok Development Database
-- This script runs when PostgreSQL container starts for the first time

-- Create additional databases for different environments
CREATE DATABASE quizztok_test;
CREATE DATABASE quizztok_staging;

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE quizztok_dev TO quizztok;
GRANT ALL PRIVILEGES ON DATABASE quizztok_test TO quizztok;
GRANT ALL PRIVILEGES ON DATABASE quizztok_staging TO quizztok;

-- Enable required extensions
\c quizztok_dev;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

\c quizztok_test;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

\c quizztok_staging;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";