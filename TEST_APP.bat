@echo off
setlocal
cd /d "%~dp0"
where flutter >nul 2>&1
if errorlevel 1 (
    echo ERROR: Flutter not found. See README.md.
    pause
    exit /b 1
)
echo [1/2] Checking project with Flutter analyzer...
flutter analyze
if errorlevel 1 goto :failed
echo.
echo [2/2] Running calculator unit tests...
flutter test
if errorlevel 1 goto :failed
echo.
echo SUCCESS: Flutter analyzer and tests passed.
pause
exit /b 0
:failed
echo.
echo Checks failed. Read the messages above and share a screenshot.
pause
exit /b 1
