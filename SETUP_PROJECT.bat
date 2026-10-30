@echo off
setlocal
cd /d "%~dp0"
echo ============================================
echo   AURORA - FLUTTER PROJECT SETUP
echo ============================================
echo.
where flutter >nul 2>&1
if errorlevel 1 (
    echo ERROR: Flutter not found in PATH.
    echo Make sure C:\develop\flutter\bin is in User PATH.
    pause
    exit /b 1
)
echo [1/3] Checking Flutter...
flutter --version
if errorlevel 1 goto :fail
echo.
echo [2/3] Generating Android project files from your installed Flutter...
flutter create --platforms=android .
if errorlevel 1 goto :fail
echo.
echo [3/3] Resolving Flutter packages...
flutter pub get
if errorlevel 1 goto :fail
echo.
echo SUCCESS: Project is ready!
echo Open this folder in Android Studio.
echo For a connected phone or emulator run: flutter run
echo For checking prerequisites run: flutter doctor
echo.
pause
exit /b 0
:fail
echo.
echo A command failed. Read the error above and send a screenshot.
pause
exit /b 1
