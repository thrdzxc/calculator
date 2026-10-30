@echo off
setlocal
cd /d "%~dp0"
echo AURORA - Running Flutter calculator
where flutter >nul 2>&1
if errorlevel 1 (
    echo Flutter was not found. Check Windows PATH.
    pause
    exit /b 1
)
if not exist android\app\src\main\AndroidManifest.xml (
    echo Android project files missing. Run SETUP_PROJECT.bat first.
    pause
    exit /b 1
)
flutter devices
echo.
echo Make sure your phone is connected with USB debugging, or start an Android emulator.
echo.
flutter run
pause
