@echo off
setlocal

REM ==========================================
REM Load central configuration
REM ==========================================
call config.bat

REM ==========================================
REM Docker Image Configuration
REM ==========================================
set "IMAGE=%IMAGE_NAME%:%IMAGE_VERSION%"

echo.
echo ==========================================
echo Building Docker image
echo Image: %IMAGE%
echo ==========================================
echo.

docker build -t %IMAGE% -f ..\Dockerfile ..

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ==========================================
    echo Docker build failed!
    echo ==========================================
    echo.
    pause
    exit /b 1
)

REM ==========================================
REM Remove Existing Container
REM ==========================================
echo.
echo Removing existing container if it exists...
docker rm -f %CONTAINER_NAME% >nul 2>&1

REM ==========================================
REM Run Container
REM ==========================================
echo.
echo ==========================================
echo Starting container
echo ==========================================
echo.

docker run -d ^
    --name %CONTAINER_NAME% ^
    -p %HOST_PORT%:%CONTAINER_PORT% ^
    %IMAGE%

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ==========================================
    echo Failed to start container!
    echo ==========================================
    echo.
    pause
    exit /b 1
)

REM ==========================================
REM Success
REM ==========================================
echo.
echo ==========================================
echo Application started successfully!
echo ==========================================
echo.
echo Image:     %IMAGE%
echo Container: %CONTAINER_NAME%
echo Port:      %HOST_PORT%
echo.
echo Application:
echo http://localhost:%HOST_PORT%
echo.
echo Swagger:
echo http://localhost:%HOST_PORT%/swagger-ui/index.html
echo.
echo ==========================================

pause
endlocal