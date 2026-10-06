@echo off
REM ==========================================
REM Arquivo Central de Configuracoes
REM ==========================================

REM Docker & App Configuration
set DOCKER_USER=loesterbotelho
set IMAGE_NAME=desafio-frontend
set IMAGE_VERSION=1.0.0
set CONTAINER_NAME=desafio-frontend
set HOST_PORT=80
set CONTAINER_PORT=80

REM Test Configuration (Newman)
set POSTMAN_COLLECTION=desafio.postman_collection.json