
@echo off
cls


set "JAVA_HOME=C:\dev\jdk-25.0.4.1"
set "MAVEN_HOME=C:\dev\maven-3.10.0"
set "GRADLE_HOME=C:\dev\gradle-9.8.0"
set "NODE_HOME=C:\dev\node-v24.21.0-win-x64"

set "PATH=%JAVA_HOME%\bin;%MAVEN_HOME%\bin;%GRADLE_HOME%\bin;%NODE_HOME%;%PATH%"

echo ===================================================
echo     Development Environment Configured
echo ===================================================
echo.

echo Java:
java -version
echo.
echo.

echo Maven:
call mvn -v
echo.
echo.

echo Gradle:
call gradle -v
echo.
echo.

echo Node.js:
call node -v
echo.
echo.

echo ===================================================
echo Ready to code!
echo ===================================================
echo.

cmd /k