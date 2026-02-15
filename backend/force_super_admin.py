#!/usr/bin/env python3
"""
强制更新admin用户为super_admin并验证
"""

import sqlite3
import os

# Get database path
db_path = os.path.join('backend', 'instance', 'recruitment.db')

if not os.path.exists(db_path):
    print(f"[!] Database not found at: {db_path}")
    exit(1)

print(f"[*] Connecting to database: {db_path}")
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Show all users and their roles
print("\n[*] Current users in database:")
cursor.execute("SELECT id, username, email, role FROM users")
users = cursor.fetchall()
for user in users:
    print(f"  ID={user[0]}, username={user[1]}, email={user[2]}, role={user[3]}")

# Update admin to super_admin
print("\n[*] Updating admin user to super_admin...")
cursor.execute("UPDATE users SET role = 'super_admin' WHERE username = 'admin'")
conn.commit()

# Verify the update
cursor.execute("SELECT id, username, role FROM users WHERE username = 'admin'")
admin = cursor.fetchone()

if admin:
    print(f"\n[+] SUCCESS! Admin user updated:")
    print(f"    ID: {admin[0]}")
    print(f"    Username: {admin[1]}")
    print(f"    Role: {admin[2]}")
else:
    print("\n[!] ERROR: Admin user not found!")

conn.close()

print("\n[*] Please logout and login again to get new permissions")
print("    Username: admin")
print("    Password: admin123")
