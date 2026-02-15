@echo off
REM 启动招聘系统的所有服务 (Windows版本)

echo ======================================
echo 德元升中医馆 - 招聘管理系统
echo ======================================
echo.
echo 正在启动服务...
echo.

REM 启动公共页面服务 (5000端口)
echo [1/2] 启动公共页面服务 (端口 5000)...
cd backend
start "公共服务-5000" python app.py
cd ..

REM 等待1秒
timeout /t 1 /nobreak >nul

REM 启动管理后台服务 (5001端口)
echo [2/2] 启动管理后台服务 (端口 5001)...
cd backend
start "管理服务-5001" python admin_app.py
cd ..

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
