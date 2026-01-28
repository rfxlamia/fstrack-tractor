# CSV User Import Scripts

Scripts untuk import user dari file CSV ke production database FSTrack.

## 📋 CSV Format Requirements

### Required Columns
- `username` - VARCHAR(255), required, unique
- `password` - VARCHAR, required, min 8 chars + 1 digit
- `fullname` - VARCHAR(255), required
- `role_id` - VARCHAR(32), required, FK to roles table
- `plantation_group_id` - VARCHAR(10), optional, FK to plantation_groups table

### Optional Columns
- `index` - VARCHAR(255)
- `email` - VARCHAR(255), basic email format if provided
- `phone` - VARCHAR(16)
- `address` - TEXT
- `picture_url` - TEXT, valid URL format if provided

## 🔧 Usage

### Validate CSV File
```bash
npm run csv:validate -- --file=users.csv
```

**Exit Codes:**
- `0` = Validation passed
- `1` = Validation failed

### Import CSV File (Coming Soon)
```bash
npm run csv:import -- --file=users.csv
```

## 📊 Validation Rules

### Username
- Required, cannot be empty
- Max 255 characters
- Must be unique (not exist in database)
- No duplicates within file

### Password
- Required, cannot be empty
- Minimum 8 characters
- Must contain at least 1 digit
- Stored as plain text in CSV, will be hashed with bcrypt during import

### Fullname
- Required, cannot be empty
- Max 255 characters

### Role ID
- Required, cannot be empty
- Must exist in `roles` table
- Case-sensitive

### Plantation Group ID
- Optional (can be empty)
- If provided, must exist in `plantation_groups` table

### Optional Fields
- `email`: Valid email format if provided
- `picture_url`: Valid URL format if provided

## 📝 Valid Role IDs (from Production)

```
MASTER_LOKASI
OPERATOR
SUPERADMIN
OPERATOR_PG1
KASIE_PG
KASIE_FE
ASSISTANT_MANAGER
KABAG_FIELD_ESTABLISHMENT
MANAGER
MANAGER_FE_PG
MANDOR
ADMINISTRASI
ADMINISTRASI_PG
PG_MANAGER
DEPUTY
```

## 📍 Valid Plantation Group IDs (Examples)

```
ALL      - All groups (special)
MG1      - Management Group 1
PG1      - Plantation Group 1
PG2      - Plantation Group 2
PG3      - Plantation Group 3
```

## 📄 CSV Example

```csv
username,password,fullname,role_id,plantation_group_id,index,email,phone,address,picture_url
newuser001,Password123,New User One,OPERATOR,PG1,0001,newuser@example.com,081234567890,Jakarta,
newuser002,Password123,New User Two,KASIE_FE,MG1,0002,newuser2@example.com,081234567891,Bandung,
newuser003,Password123,New User Three,MANDOR,PG2,0003,newuser3@example.com,081234567892,
```

## ❌ Error Examples

### Missing Required Column
```
❌ Validation Failed

Line 1: header 'role_id' missing required column

Total: 1 error found
```

### Password Too Short
```
❌ Validation Failed

Line 3: password '123' too short (minimum 8 characters)

Total: 1 error found
```

### Invalid Role ID
```
❌ Validation Failed

Line 5: role_id 'SUPERVISOR' is not valid (must exist in roles table)

Total: 1 error found
```

### Duplicate Username
```
❌ Validation Failed

Line 7: username 'duplicate' duplicate username within file (first occurrence at line 3)

Total: 1 error found
```

### Username Already Exists
```
❌ Validation Failed

Line 3: username 'tyastono' already exists in database

Total: 1 error found
```

## ✅ Success Example

```
✅ Validation Passed

Total rows: 3
Roles breakdown: OPERATOR (1), KASIE_FE (1), MANDOR (1)
Ready for import
```

## 🧪 Testing

### Run Unit Tests
```bash
npm test -- scripts/__tests__/csv-validator.spec.ts
```

### Test with Fixtures
```bash
# Valid CSV
npm run csv:validate -- --file=scripts/__tests__/fixtures/valid-users.csv

# Invalid password
npm run csv:validate -- --file=scripts/__tests__/fixtures/invalid-password.csv

# Invalid role
npm run csv:validate -- --file=scripts/__tests__/fixtures/invalid-role.csv

# Duplicate username
npm run csv:validate -- --file=scripts/__tests__/fixtures/duplicate-username.csv

# Missing headers
npm run csv:validate -- --file=scripts/__tests__/fixtures/invalid-headers.csv
```

## 📁 Files

```
scripts/
├── lib/
│   ├── db-connection.ts          # Database connection utility
│   └── csv-validator.ts          # Shared validation logic
├── __tests__/
│   ├── fixtures/
│   │   ├── valid-users.csv
│   │   ├── invalid-password.csv
│   │   ├── invalid-role.csv
│   │   ├── duplicate-username.csv
│   │   └── invalid-headers.csv
│   ├── csv-validator.spec.ts     # Unit tests
│   └── validate-csv.spec.ts      # Integration tests
├── validate-csv.ts               # Main validation script
├── sample-users.csv              # Template for admins
└── README.md                     # This file
```

## ⚠️ Important Notes

1. **Passwords are plain text in CSV** - They will be hashed with bcrypt during import
2. **Production database connection** - Scripts connect directly to production database
3. **Unique usernames** - Validation prevents duplicate usernames in database
4. **Role validation** - All role_ids must exist in production roles table
5. **Optional fields** - Can be left empty, but must have correct format if provided

## 🔐 Security

- Passwords are stored as plain text in CSV files
- During import, passwords are hashed with bcrypt (cost factor: 10)
- Never commit CSV files with real passwords to version control
- Use `.gitignore` to exclude CSV files with user data

## 🚀 Next Steps

After validation passes:
1. Review the validation output
2. Fix any errors in the CSV file
3. Run validation again until all errors are resolved
4. Run the import script (coming in Story 6.2)