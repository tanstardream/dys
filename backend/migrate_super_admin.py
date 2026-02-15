#!/usr/bin/env python3
"""
Update existing admin user to super_admin role
"""

import sqlite3
import os

# Get database path
db_path = os.path.join('backend', 'instance', 'recruitment.db')

if not os.path.exists(db_path):
    print(f"[!] Database not found at: {db_path}")
    print("[!] Please ensure the database exists before running this migration")
    exit(1)

print(f"[*] Connecting to database: {db_path}")
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Update admin user to super_admin
cursor.execute("SELECT id, username, role FROM users WHERE username = 'admin'")
admin = cursor.fetchone()

if admin:
    user_id, username, current_role = admin
    print(f"[*] Found admin user: ID={user_id}, username={username}, current_role={current_role}")

    if current_role != 'super_admin':
        cursor.execute("UPDATE users SET role = 'super_admin' WHERE id = ?", (user_id,))
        conn.commit()
        print(f"[+] Updated admin user role from '{current_role}' to 'super_admin'")
    else:
        print("[*] Admin user already has super_admin role")
else:
    print("[!] No admin user found in database")
    print("[!] Please run the application first to create the default admin user")

conn.close()
print("[✓] Migration completed")
