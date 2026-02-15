# 安装说明

本文档说明如何使用 `pyproject.toml` 安装和管理德元升招聘管理系统。

## 前置要求

- Python 3.9 或更高版本
- pip 或 uv（推荐使用 uv，更快的包管理器）

## 安装方法

### 方法一：使用 uv（推荐）

```bash
# 安装uv（如果还没有安装）
pip install uv

# 同步安装所有依赖
uv sync

# 或者只安装核心依赖
uv pip install -e .

# 安装开发依赖
uv pip install -e ".[dev]"
```

### 方法二：使用 pip

```bash
# 安装核心依赖
pip install -e .

# 安装开发依赖
pip install -e ".[dev]"
```

## 运行应用

### 方法一：直接运行 Python 模块

```bash
python -m backend.app
```

### 方法二：使用安装的命令行工具（推荐）

```bash
# 先安装项目
pip install -e .

# 然后使用命令启动
dys-server
```

### 方法三：传统方式

```bash
cd backend
python app.py
```

## 开发工具

安装开发依赖后，可以使用以下工具：

### 代码格式化

```bash
# 格式化所有Python文件
black backend/

# 检查但不修改
black --check backend/
```

### 代码检查

```bash
# 运行flake8检查代码质量
flake8 backend/
```

### 类型检查

```bash
# 运行mypy进行类型检查
mypy backend/
```

### 运行测试

```bash
# 运行所有测试
pytest

# 运行测试并生成覆盖率报告
pytest --cov=backend --cov-report=html
```

## 依赖说明

### 核心依赖

- **flask** (>=3.0.0) - Web框架
- **flask-cors** (>=4.0.0) - 跨域资源共享
- **flask-sqlalchemy** (>=3.1.0) - SQLAlchemy集成
- **pyjwt** (>=2.8.0) - JWT令牌认证
- **python-docx** (>=1.1.0) - Word文档生成
- **werkzeug** (>=3.0.0) - WSGI工具库

### 开发依赖

- **pytest** (>=8.0.0) - 测试框架
- **pytest-cov** (>=4.1.0) - 测试覆盖率
- **black** (>=24.0.0) - 代码格式化
- **flake8** (>=7.0.0) - 代码检查
- **mypy** (>=1.8.0) - 类型检查

## 构建和分发

### 构建软件包

```bash
# 安装构建工具
pip install build

# 构建wheel和源代码分发包
python -m build
```

构建的文件将出现在 `dist/` 目录中。

### 安装构建的包

```bash
pip install dist/dys_recruitment-0.1.0-py3-none-any.whl
```

## 项目元数据

- **项目名称**: dys-recruitment
- **版本**: 0.1.0
- **Python要求**: >=3.9
- **许可证**: MIT
- **作者**: 德元升中医馆

## 更新依赖

### 查看过时的包

```bash
pip list --outdated
```

### 更新依赖版本

编辑 `pyproject.toml` 中的版本号，然后重新安装：

```bash
pip install -e . --upgrade
```

## 常见问题

### Q: 为什么推荐使用 uv？

A: uv 是一个用 Rust 编写的极快的 Python 包管理器，比 pip 快 10-100 倍。

### Q: 如何锁定依赖版本？

A: 使用 uv 的话，会自动生成 `uv.lock` 文件。使用 pip 的话，可以运行：

```bash
pip freeze > requirements.txt
```

### Q: 如何在生产环境部署？

A: 参考 `DEPLOYMENT.md` 文档，其中包含详细的生产环境部署指南。

## 相关文档

- [README.md](README.md) - 项目概述
- [QUICKSTART.md](QUICKSTART.md) - 快速开始指南
- [DEPLOYMENT.md](DEPLOYMENT.md) - 部署指南
- [RUNNING.md](RUNNING.md) - 运行说明
