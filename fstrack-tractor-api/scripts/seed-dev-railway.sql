-- Seed dev_kasie user for staging
-- Hash generated with bcrypt rounds=10

INSERT INTO users (username, password_hash, full_name, role, is_first_time, created_at, updated_at)
VALUES (
  'dev_kasie',
  '$2b$10$Gr4uqpXqRkZw2/eiSjQe3ufACXe6zV0wqpP0cM8dX7yFViLpwtwim',
  'Dev Kasie User',
  'KASIE',
  true,
  NOW(),
  NOW()
)
ON CONFLICT (username) DO UPDATE SET
  password_hash = '$2b$10$Gr4uqpXqRkZw2/eiSjQe3ufACXe6zV0wqpP0cM8dX7yFViLpwtwim',
  full_name = 'Dev Kasie User',
  role = 'KASIE',
  is_first_time = true,
  updated_at = NOW();

SELECT 'Dev user seeded successfully: dev_kasie' AS result;
