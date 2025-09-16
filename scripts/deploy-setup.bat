@echo off
echo ========================================
echo QuizzTok Live Deployment Setup Script
echo ========================================
echo.

REM Check if required tools are installed
where heroku >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: Heroku CLI is not installed!
    echo Please install from: https://devcenter.heroku.com/articles/heroku-cli
    exit /b 1
)

where gh >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: GitHub CLI is not installed!
    echo Please install from: https://cli.github.com/
    exit /b 1
)

echo [1/5] Setting up GitHub Secrets...
echo.
echo Please enter your deployment credentials:
echo.

set /p VERCEL_TOKEN="Vercel Token: "
set /p VERCEL_ORG_ID="Vercel Org ID: "
set /p VERCEL_PROJECT_ID="Vercel Project ID: "
set /p HEROKU_API_KEY="Heroku API Key: "
set /p HEROKU_EMAIL="Heroku Email: "

echo.
echo [2/5] Configuring GitHub Secrets...

gh secret set VERCEL_TOKEN --body "%VERCEL_TOKEN%"
gh secret set VERCEL_ORG_ID --body "%VERCEL_ORG_ID%"
gh secret set VERCEL_PROJECT_ID --body "%VERCEL_PROJECT_ID%"
gh secret set HEROKU_API_KEY --body "%HEROKU_API_KEY%"
gh secret set HEROKU_EMAIL --body "%HEROKU_EMAIL%"
gh secret set HEROKU_PRODUCTION_APP_NAME --body "quizztok-api-prod"
gh secret set HEROKU_STAGING_APP_NAME --body "quizztok-api-staging"

echo.
echo [3/5] Creating Heroku Applications...

REM Set Heroku auth
set HEROKU_API_KEY=%HEROKU_API_KEY%

REM Create production app
heroku create quizztok-api-prod --region us
if %ERRORLEVEL% neq 0 (
    echo Production app might already exist, continuing...
)

REM Create staging app
heroku create quizztok-api-staging --region us
if %ERRORLEVEL% neq 0 (
    echo Staging app might already exist, continuing...
)

echo.
echo [4/5] Adding Heroku Add-ons...

REM Production add-ons
heroku addons:create heroku-postgresql:mini -a quizztok-api-prod
heroku addons:create heroku-redis:mini -a quizztok-api-prod

REM Staging add-ons
heroku addons:create heroku-postgresql:mini -a quizztok-api-staging
heroku addons:create heroku-redis:mini -a quizztok-api-staging

echo.
echo [5/5] Configuring Heroku Environment Variables...

REM Generate random JWT secrets
for /f %%i in ('powershell -Command "[System.Convert]::ToBase64String((1..32 | ForEach-Object {Get-Random -Maximum 256}))"') do set JWT_SECRET_PROD=%%i
for /f %%i in ('powershell -Command "[System.Convert]::ToBase64String((1..32 | ForEach-Object {Get-Random -Maximum 256}))"') do set JWT_SECRET_STAGING=%%i

REM Production config
heroku config:set NODE_ENV=production PORT=3000 CORS_ORIGIN=https://quizztok-web.vercel.app JWT_SECRET=%JWT_SECRET_PROD% -a quizztok-api-prod

REM Staging config
heroku config:set NODE_ENV=staging PORT=3000 CORS_ORIGIN=https://quizztok-web-staging.vercel.app JWT_SECRET=%JWT_SECRET_STAGING% -a quizztok-api-staging

echo.
echo ========================================
echo Deployment Setup Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Push to main branch to trigger deployment
echo 2. Check GitHub Actions for deployment status
echo 3. Visit your apps:
echo    - Frontend: https://quizztok-web.vercel.app
echo    - Backend: https://quizztok-api-prod.herokuapp.com/health
echo.
pause