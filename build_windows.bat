@echo off
echo ===================================================
echo   ScanDigitize Enterprise - Windows Build Script
echo ===================================================
echo.

echo 1. Fetching Flutter Dependencies...
call flutter pub get

echo 2. Running Static Analysis...
call flutter analyze

echo 3. Building Release Windows Desktop Executable...
call flutter build windows --release

echo.
echo ===================================================
echo   BUILD COMPLETE!
echo   Executable Location:
echo   build\windows\x64\runner\Release\scandigitize.exe
echo ===================================================
pause
