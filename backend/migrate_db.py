"""
数据库迁移脚本 - 添加职位分类字段
"""
import sqlite3
import os

db_path = os.path.join(os.path.dirname(__file__), 'instance', 'recruitment.db')

print("=" * 60)
print("数据库迁移 - 添加职位分类字段")
print("=" * 60)
print(f"数据库路径: {db_path}")

conn = sqlite3.connect(db_path)
cursor = conn.cursor()

try:
    # 检查表结构
    cursor.execute("PRAGMA table_info(jobs)")
    columns = [col[1] for col in cursor.fetchall()]
    print(f"\n当前字段: {', '.join(columns)}")

    # 添加新字段
    if 'category' not in columns:
        cursor.execute("ALTER TABLE jobs ADD COLUMN category VARCHAR(50) DEFAULT '技术人员'")
        print("✓ 添加字段: category")
    else:
        print("- 字段已存在: category")

    if 'priority' not in columns:
        cursor.execute("ALTER TABLE jobs ADD COLUMN priority INTEGER DEFAULT 99")
        print("✓ 添加字段: priority")
    else:
        print("- 字段已存在: priority")

    if 'position_count' not in columns:
        cursor.execute("ALTER TABLE jobs ADD COLUMN position_count INTEGER DEFAULT 1")
        print("✓ 添加字段: position_count")
    else:
        print("- 字段已存在: position_count")

    conn.commit()
    print("\n✓ 数据库迁移成功！")

    # 验证
    cursor.execute("PRAGMA table_info(jobs)")
    columns = [col[1] for col in cursor.fetchall()]
    print(f"\n更新后字段: {', '.join(columns)}")

except Exception as e:
    print(f"\n✗ 迁移失败: {e}")
    conn.rollback()
finally:
    conn.close()

print("=" * 60)
