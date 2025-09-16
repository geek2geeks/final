@echo off
REM QuizzTok Development Environment Setup Script (Windows)
REM This script sets up the complete development environment

echo 🚀 Setting up QuizzTok Development Environment...
echo ================================================

REM Check if required tools are installed
echo [INFO] Checking dependencies...

where docker >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Docker not found. Please install Docker Desktop.
    pause
    exit /b 1
)

where docker-compose >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Docker Compose not found. Please install Docker Desktop.
    pause
    exit /b 1
)

where pnpm >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] pnpm not found. Please install pnpm: npm install -g pnpm
    pause
    exit /b 1
)

where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Node.js not found. Please install Node.js.
    pause
    exit /b 1
)

echo [SUCCESS] All dependencies are installed!

REM Setup environment files
echo [INFO] Setting up environment files...

if not exist ".env" (
    copy .env.example .env >nul
    echo [SUCCESS] Created root .env file
) else (
    echo [WARNING] Root .env file already exists, skipping...
)

if not exist "apps\api\.env" (
    copy apps\api\.env.example apps\api\.env >nul
    echo [SUCCESS] Created API .env file
) else (
    echo [WARNING] API .env file already exists, skipping...
)

if not exist "apps\web\.env.local" (
    copy apps\web\.env.example apps\web\.env.local >nul
    echo [SUCCESS] Created Web .env.local file
) else (
    echo [WARNING] Web .env.local file already exists, skipping...
)

REM Install dependencies
echo [INFO] Installing dependencies...
pnpm install --frozen-lockfile
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install dependencies
    pause
    exit /b 1
)
echo [SUCCESS] Dependencies installed successfully!

REM Setup SSL certificates
echo [INFO] Setting up SSL certificates...
cd infrastructure\docker\nginx

if exist "ssl\localhost.crt" if exist "ssl\localhost.key" (
    echo [WARNING] SSL certificates already exist, skipping...
) else (
    if exist "generate-ssl.ps1" (
        powershell -ExecutionPolicy Bypass -File generate-ssl.ps1
    ) else (
        echo [WARNING] No SSL generation script found, using existing certificates
    )
)

cd ..\..\..

REM Start Docker services
echo [INFO] Starting Docker services...

docker info >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not running. Please start Docker Desktop and try again.
    pause
    exit /b 1
)

docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d postgres redis
if %errorlevel% neq 0 (
    echo [ERROR] Failed to start Docker services
    pause
    exit /b 1
)

echo [INFO] Waiting for database to be ready...
timeout /t 10 /nobreak >nul

echo [SUCCESS] Docker services started!

REM Setup database
echo [INFO] Setting up database...
cd apps\api

call npx prisma generate
if %errorlevel% neq 0 (
    echo [ERROR] Failed to generate Prisma client
    cd ..\..
    pause
    exit /b 1
)

call npx prisma migrate dev --name init
if %errorlevel% neq 0 (
    echo [WARNING] Database migration may have failed
)

call npx prisma db seed
if %errorlevel% neq 0 (
    echo [WARNING] Database seeding may have failed
)

cd ..\..
echo [SUCCESS] Database setup completed!

REM Setup MCP configuration
echo [INFO] Setting up MCP configuration...
set CLAUDE_MCP_CONFIG=%cd%\tools\mcp-config\mcp-server-config.json
echo [SUCCESS] MCP configuration ready!

REM Validate setup
echo [INFO] Validating setup...

docker-compose ps | findstr "Up" >nul
if %errorlevel% equ 0 (
    echo [SUCCESS] Docker services are running
) else (
    echo [WARNING] Some Docker services may not be running
)

echo.
echo [SUCCESS] 🎉 Development environment setup completed!
echo.
echo [INFO] Next steps:
echo   1. Start the development servers:
echo      pnpm run dev
echo.
echo   2. Access the applications:
echo      - Web Frontend: https://localhost:3000
echo      - API Backend: https://localhost:3001
echo      - API Docs: https://localhost:3001/docs
echo.
echo   3. Database management:
echo      - Prisma Studio: cd apps/api ^&^& npx prisma studio
echo      - Direct access: docker-compose exec postgres psql -U quizztok quizztok_dev
echo.
echo   4. MCP Tools:
echo      - Configuration: .\tools\mcp-config\mcp-server-config.json
echo      - Generate worktree config: .\tools\mcp-config\generate-worktree-config.sh ^<name^>
echo.

pause