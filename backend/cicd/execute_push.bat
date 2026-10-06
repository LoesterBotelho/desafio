@echo off
setlocal

REM ==========================================
REM Load central configuration
REM ==========================================
call config.bat

REM ==========================================
REM Docker Hub Image
REM ==========================================
set "FULL_IMAGE=%DOCKER_USER%/%IMAGE_NAME%:%IMAGE_VERSION%"

echo.
echo ==========================================
echo Docker Hub Login
echo ==========================================
echo.

docker login

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Docker login failed!
    echo.
    pause
    exit /b 1
)

echo.
echo ==========================================
echo Building Docker Image
echo ==========================================
echo Image: %FULL_IMAGE%
echo ==========================================
echo.

docker build -t %FULL_IMAGE% -f ..\Dockerfile ..

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Docker build failed!
    echo.
    pause
    exit /b 1
)

echo.
echo ==========================================
echo Pushing Image to Docker Hub
echo ==========================================
echo.

docker push %FULL_IMAGE%

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Docker push failed!
    echo.
    pause
    exit /b 1
)

echo.
echo ==========================================
echo Process completed successfully!
echo ==========================================
echo.
echo Image:
echo %FULL_IMAGE%
echo.

pause
endlocal