#!/usr/bin/env python3
"""
测试下载性能
"""
import time
import os

# 模拟文件查找和读取
start = time.time()

# 测试1: 数据库查询速度
print(f"[1] 开始时间: {time.time() - start:.3f}s")

# 测试2: 文件路径检查
file_path = "/home/ubuntu/project/dys/uploads/resumes/test.pdf"
print(f"[2] 路径检查: {time.time() - start:.3f}s")

# 测试3: 文件存在性检查
exists = os.path.exists(file_path)
print(f"[3] 文件存在检查: {time.time() - start:.3f}s - {exists}")

# 测试4: 文件大小
if exists:
    size = os.path.getsize(file_path)
    print(f"[4] 文件大小: {size / 1024:.2f} KB")

print(f"\n总耗时: {time.time() - start:.3f}s")
