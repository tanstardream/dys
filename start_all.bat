@echo off
REM 启动招聘系统的所有服务 (Windows版本)
REM 用法:
REM   start_all.bat           # 后台运行（默认）
REM   start_all.bat -f        # 前台运行显示日志
REM   start_all.bat stop      # 停止所有服务

setlocal enabledelayedexpansion

set "PROJECT_DIR=%~dp0"
set "BACKEND_DIR=%PROJECT_DIR%backend"
set "LOG_DIR=%PROJECT_DIR%logs"

REM 创建日志目录
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

set "LOG_FILE_PUBLIC=%LOG_DIR%\public.log"
set "LOG_FILE_ADMIN=%LOG_DIR%\admin.log"

REM 解析参数
if "%1"=="-f" goto foreground
if "%1"=="--foreground" goto foreground
if "%1"=="stop" goto stop
if "%1"=="-h" goto help
if "%1"=="--help" goto help
goto background

:background
echo ======================================
echo 德元升中医馆 - 招聘管理系统
echo ======================================
echo.
echo 正在后台启动服务...
echo.

cd "%BACKEND_DIR%"

echo [1/2] 启动公共页面服务 (端口 5000)...
start "公共服务-5000" /MIN cmd /c "python app.py > \"%LOG_FILE_PUBLIC%\" 2>&1"
echo   已启动

timeout /t 2 /nobreak >nul

echo [2/2] 启动管理后台服务 (端口 5001)...
start "管理服务-5001" /MIN cmd /c "python admin_app.py > \"%LOG_FILE_ADMIN%\" 2>&1"
echo   已启动

echo.
echo ======================================
echo 服务启动完成！
echo ======================================
echo.
echo 访问地址：
echo   公共求职页面:  http://localhost:5000/
echo   管理后台:      http://localhost:5001/
echo.
echo 日志文件：
echo   公共服务: %LOG_FILE_PUBLIC%
echo   管理服务: %LOG_FILE_ADMIN%
echo.
echo 提示：
echo   - 服务已在后台运行
echo   - 查看日志: type "%LOG_FILE_PUBLIC%"
echo   - 查看日志: type "%LOG_FILE_ADMIN%"
echo   - 停止服务: start_all.bat stop
echo   - 或在任务管理器中结束进程
echo ======================================
echo.
pause
goto :eof

:foreground
echo ======================================
echo 德元升中医馆 - 招聘管理系统
echo ======================================
echo.
echo 正在前台启动服务（显示日志）...
echo.

cd "%BACKEND_DIR%"

echo [1/2] 启动公共页面服务 (端口 5000)...
start "公共服务-5000" python app.py

timeout /t 2 /nobreak >nul

echo [2/2] 启动管理后台服务 (端口 5001)...
start "管理服务-5001" python admin_app.py

echo.
echo ======================================
echo 服务启动完成！
echo ======================================
echo.
echo 访问地址：
echo   公共求职页面:  http://localhost:5000/
echo   管理后台:      http://localhost:5001/
echo.
echo 提示：两个服务已在独立窗口中启动
echo 关闭对应窗口即可停止服务
echo ======================================
echo.
pause
goto :eof

:stop
echo 正在停止服务...
taskkill /FI "WindowTitle eq 公共服务-5000*" /T /F 2>nul
taskkill /FI "WindowTitle eq 管理服务-5001*" /T /F 2>nul
echo 所有服务已停止
pause
goto :eof

:help
echo 用法: %~nx0 [选项]
echo.
echo 选项:
echo   (无参数)        后台运行服务（默认）
echo   -f, --foreground 前台运行并显示日志
echo   stop            停止所有服务
echo   -h, --help      显示此帮助信息
echo.
echo 示例:
echo   %~nx0           # 后台运行
echo   %~nx0 -f        # 前台运行查看日志
echo   %~nx0 stop      # 停止服务
echo.
pause
goto :eof
