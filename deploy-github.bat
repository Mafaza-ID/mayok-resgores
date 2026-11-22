@echo off
setlocal EnableExtensions
chcp 65001 >nul
cd /d "%~dp0"
title Upload Mayok Gores Gores ke GitHub
echo ==============================================
echo   UPLOAD GAME KE GITHUB PAGES (OTOMATIS)
echo ==============================================
echo.
where git >nul 2>&1
if errorlevel 1 goto NOGIT
set /p GHUSER=Username GitHub Anda : 
if "%GHUSER%"=="" goto NOUSER
set REPO=mayok-gores-gores
set /p REPO=Nama repository [Enter = mayok-gores-gores] : 
set SITE=https://%GHUSER%.github.io/%REPO%/
echo.
echo Link game nanti: %SITE%
powershell -NoProfile -ExecutionPolicy Bypass -Command "$p='index.html'; $t=[IO.File]::ReadAllText($p); $t=$t.Replace('https://USERNAME.github.io/REPO/','%SITE%'); [IO.File]::WriteAllText($p,$t,(New-Object Text.UTF8Encoding $false))"
if not exist ".git" git init
git config user.name >nul 2>&1 || git config user.name "%GHUSER%"
git config user.email >nul 2>&1 || git config user.email "%GHUSER%@users.noreply.github.com"
git add -A
git commit -m "Mayok Gores Gores" >nul 2>&1
git branch -M main
set GH=
where gh >nul 2>&1 && set GH=gh
if not defined GH if exist "%ProgramFiles%\GitHub CLI\gh.exe" set GH="%ProgramFiles%\GitHub CLI\gh.exe"
if defined GH goto GHCLI
where winget >nul 2>&1
if errorlevel 1 goto MANUAL
echo Memasang GitHub CLI otomatis, mohon tunggu...
winget install --id GitHub.cli -e --silent --accept-source-agreements --accept-package-agreements
if exist "%ProgramFiles%\GitHub CLI\gh.exe" set GH="%ProgramFiles%\GitHub CLI\gh.exe"
if not defined GH goto MANUAL

:GHCLI
%GH% auth status >nul 2>&1
if errorlevel 1 %GH% auth login -h github.com -p https -w
%GH% auth status >nul 2>&1
if errorlevel 1 goto MANUAL
%GH% auth setup-git
%GH% repo create %GHUSER%/%REPO% --public --source=. --remote=origin --push
if not errorlevel 1 goto PAGES
echo Repository sudah ada, mencoba push langsung...
git remote remove origin >nul 2>&1
git remote add origin https://github.com/%GHUSER%/%REPO%.git
git push -u origin main
if errorlevel 1 goto FAIL

:PAGES
%GH% api -X POST repos/%GHUSER%/%REPO%/pages -f "source[branch]=main" -f "source[path]=/" >nul 2>&1
if errorlevel 1 %GH% api -X PUT repos/%GHUSER%/%REPO%/pages -f "source[branch]=main" -f "source[path]=/" >nul 2>&1
goto DONE

:MANUAL
echo.
echo [MODE MANUAL] Browser dibuka untuk membuat repository.
echo Buat repository PUBLIC bernama %REPO% tanpa README, lalu kembali ke sini.
start "" "https://github.com/new?name=%REPO%&visibility=public"
pause
git remote remove origin >nul 2>&1
git remote add origin https://github.com/%GHUSER%/%REPO%.git
git push -u origin main
if errorlevel 1 goto FAIL
echo.
echo Terakhir, aktifkan GitHub Pages: Branch main, Folder root, lalu Save.
start "" "https://github.com/%GHUSER%/%REPO%/settings/pages"
goto DONE

:DONE
echo.
echo ==============================================
echo   SELESAI! Tunggu 1-2 menit lalu buka:
echo   %SITE%
echo ==============================================
start "" "%SITE%"
pause
exit /b 0

:NOUSER
echo Username tidak boleh kosong.
pause
exit /b 1

:NOGIT
echo Git belum terpasang. Mencoba memasang otomatis...
where winget >nul 2>&1
if errorlevel 1 (
  start "" "https://git-scm.com/download/win"
  echo Pasang Git dari browser, lalu jalankan file ini lagi.
  pause
  exit /b 1
)
winget install --id Git.Git -e --silent --accept-source-agreements --accept-package-agreements
echo Git terpasang. TUTUP jendela ini lalu jalankan deploy-github.bat lagi.
pause
exit /b 0

:FAIL
echo.
echo Upload gagal. Pastikan login GitHub benar dan repository milik Anda.
pause
exit /b 1
