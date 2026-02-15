# 招聘网站系统 - 启动成功！

## 当前状态

✅ 后端服务已启动
- 服务地址: http://localhost:5000
- 状态: 运行中
- 演示数据: 已创建6个示例职位

## 如何访问系统

### 1. 外部求职者页面
在浏览器中打开: `F:\project\python\dys\frontend\index.html`

功能:
- 浏览职位列表
- 查看职位详情
- 提交简历（上传文件或在线填写）

### 2. 管理后台
在浏览器中打开: `F:\project\python\dys\frontend\admin.html`

登录信息:
- 用户名: `admin`
- 密码: `admin123`

功能:
- 数据统计看板
- 职位管理（发布/编辑/删除）
- 简历管理（查看/筛选/更新状态/下载）

## 已创建的示例职位

1. Python后端开发工程师 - 北京 - 15K-30K
2. 前端开发工程师 - 上海 - 12K-25K
3. 产品经理 - 深圳 - 18K-35K
4. UI/UX设计师 - 杭州 - 10K-20K
5. 测试工程师 - 北京 - 10K-18K
6. 数据分析师（实习） - 北京 - 150-250/天

## 下次启动

如果后端服务停止了，重新启动的方法:

**方法1: 使用启动脚本**
```bash
# Windows
双击运行 start.bat

# Linux/Mac
./start.sh
```

**方法2: 手动启动**
```bash
cd F:\project\python\dys\backend
python app.py
```

## 测试流程建议

1. 先访问外部页面，查看职位列表
2. 选择一个职位，尝试提交简历
3. 登录管理后台，查看刚提交的简历
4. 尝试更新简历状态、添加备注
5. 尝试发布新职位

## 注意事项

- 后端服务需要保持运行，前端页面才能正常工作
- 数据保存在 `backend/recruitment.db` SQLite数据库中
- 上传的简历保存在 `uploads/resumes/` 目录
- 自动生成的简历保存在 `uploads/generated/` 目录

## 需要帮助？

查看详细文档:
- README.md - 完整文档
- QUICKSTART.md - 快速开始
- PROJECT_SUMMARY.md - 项目总结

祝使用愉快！🎉
