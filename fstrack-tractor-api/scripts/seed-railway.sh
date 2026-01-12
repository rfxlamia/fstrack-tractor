#!/usr/bin/env bash
# Seed dev_kasie user to Railway PostgreSQL
# Hash generated with bcrypt rounds=10

PGPASSWORD="$DATABASE_PASSWORD" psql -h "$DATABASE_HOST" -p "$DATABASE_PORT" -U "$DATABASE_USERNAME" -d "$DATABASE_NAME" <<EOF
-- Upsert dev user
INSERT INTO users (username, password_hash, full_name, role, is_first_time)
VALUES ('dev_kasie', '\$2b\$10\$Gr4uqpXqRkZw2/eiSjQe3ufACXe6zV0wqpP0cM8dX7yFViLpwtwim', 'Dev Kasie User', 'KASIE', true)
ON CONFLICT (username) DO UPDATE SET
  password_hash = '\$2b\$10\$Gr4uqpXqRkZw2/eiSjQe3ufACXe6zV0wqpP0cM8dX7yFViLpwtwim',
  full_name = 'Dev Kasie User',
  role = 'KASIE',
  is_first_time = true;

SELECT 'Dev user seeded successfully' AS result;
EOF

echo "✅ Dev user seeded: dev_kasie"
