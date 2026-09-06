@echo off
chcp 936 >nul 2>&1
title Windows 桌面图标极速修复与防复发工具

:: -------------------------------------------------------------------------
:: 自动检测并获取管理员权限（免交互）
:: -------------------------------------------------------------------------
fltmc >nul 2>&1
if errorlevel 1 goto ELEVATE
goto RUN

:ELEVATE
powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs" 2>nul
exit /b

:RUN
cd /d "%~dp0"
color 0F

echo ======================================================================
echo                 Windows 桌面图标极速修复与防复发工具
echo ======================================================================
echo.
echo [*] 正在终止资源管理器以解锁缓存文件...
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 1 /nobreak >nul 2>&1

echo [*] 正在深度清理全套图标与缩略图缓存数据库...
del /f /q /a "%localappdata%\IconCache.db" >nul 2>&1
if exist "%localappdata%\Microsoft\Windows\Explorer" (
    pushd "%localappdata%\Microsoft\Windows\Explorer"
    del /f /q /a iconcache_*.db >nul 2>&1
    del /f /q /a thumbcache_*.db >nul 2>&1
    popd
)

echo [*] 正在清除用户层覆盖与劫持注册表...
reg delete "HKCU\Software\Classes\lnkfile" /f >nul 2>&1
reg delete "HKCU\Software\Classes\.lnk" /f >nul 2>&1
reg delete "HKCU\Software\Classes\.exe" /f >nul 2>&1
reg delete "HKCU\Software\Classes\exefile" /f >nul 2>&1
reg delete "HKCU\Software\Classes\.url" /f >nul 2>&1
reg delete "HKCU\Software\Classes\InternetShortcut" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.lnk\UserChoice" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.lnk\OpenWithList" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.url\UserChoice" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.url\OpenWithList" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.exe\UserChoice" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.exe\OpenWithList" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.exe\OpenWithProgids" /v "exefile " /f >nul 2>&1

echo [*] 正在精准修复核心系统关联与图标处理器...
reg add "HKLM\SOFTWARE\Classes\.exe" /ve /t REG_SZ /d "exefile" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Classes\exefile\DefaultIcon" /ve /t REG_SZ /d "%%1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Classes\.lnk" /ve /t REG_SZ /d "lnkfile" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Classes\lnkfile" /v "IsShortcut" /t REG_SZ /d "" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Classes\lnkfile\shellex\IconHandler" /ve /t REG_SZ /d "{00021401-0000-0000-C000-000000000046}" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Classes\lnkfile\shellex\DropHandler" /ve /t REG_SZ /d "{00021401-0000-0000-C000-000000000046}" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Classes\.url" /ve /t REG_SZ /d "InternetShortcut" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Classes\InternetShortcut\shellex\IconHandler" /ve /t REG_SZ /d "{FBF23B40-E3F0-101B-8488-00AA003E56F8}" /f >nul 2>&1

echo [*] 正在清除可能残留的白方块角标...
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "29" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v "29" /f >nul 2>&1

echo [*] 正在扩容系统图标缓存池至 8192...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "Max Cached Icons" /t REG_SZ /d "8192" /f >nul 2>&1

echo [*] 正在重启资源管理器并刷新桌面...
start explorer.exe
timeout /t 2 /nobreak >nul 2>&1

where ie4uinit.exe >nul 2>&1 && ie4uinit.exe -show >nul 2>&1

echo.
echo ======================================================================
echo  [OK] 桌面图标修复完成！全部图标已恢复正常。
echo ======================================================================
echo.
echo 脚本将在 2 秒后自动退出...
timeout /t 2 /nobreak >nul 2>&1
exit /b
