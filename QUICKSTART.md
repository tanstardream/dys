# 快速开始指南

## 第一次使用

### Windows用户

1. 双击运行 `start.bat`
2. 脚本会自动：
   - 检查Python环境
   - 创建虚拟环境
   - 安装所有依赖
   - 启动后端服务

### Linux/Mac用户

1. 打开终端，进入项目目录
2. 运行: `./start.sh`
3. 脚本会自动完成所有配置

## 访问系统

后端服务启动后，你可以：

1. **外部投递页面**: 在浏览器中打开 `frontend/index.html`
   - 查看职位列表
   - 提交简历

2. **管理后台**: 在浏览器中打开 `frontend/admin.html`
   - 默认账号: `admin`
   - 默认密码: `admin123`

## 初始化演示数据

如果你想快速体验系统，可以运行演示数据初始化脚本：

```bash
cd backend
python init_demo_data.py
```

这会创建6个示例职位供你测试。

## 常见问题

### Q: 提示找不到模块？
A: 确保已安装所有依赖：
```bash
cd backend
pip install -r requirements.txt
```

### Q: 无法连接到后端API？
A: 检查：
1. 后端服务是否正在运行（默认端口5000）
2. 前端页面中的API_URL是否正确（应该是 `http://localhost:5000/api`）

### Q: 上传文件失败？
A: 确保 `uploads/resumes/` 和 `uploads/generated/` 目录存在且有写入权限

### Q: 如何修改管理员密码？
A: 首次启动后，使用admin/admin123登录，然后在数据库中修改，或者删除数据库文件重新初始化

## 目录说明

```
dys/
├── backend/           # 后端代码
│   ├── models/       # 数据模型
│   ├── routes/       # API路由
│   ├── utils/        # 工具函数
│   ├── app.py        # 应用入口
│   └── requirements.txt
├── frontend/         # 前端页面
│   ├── index.html    # 外部页面
│   └── admin.html    # 管理后台
├── uploads/          # 文件存储
│   ├── resumes/      # 上传的简历
│   └── generated/    # 生成的简历
└── README.md         # 完整文档
```

## 下一步

1. 在管理后台发布一些职位
2. 在外部页面测试简历提交
3. 在管理后台查看和处理简历

更多详细信息请查看 [README.md](README.md)
