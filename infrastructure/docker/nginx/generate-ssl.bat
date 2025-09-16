@echo off
REM Generate SSL certificates for local HTTPS development
REM This script creates self-signed certificates for localhost

set SSL_DIR=ssl
if not exist "%SSL_DIR%" mkdir "%SSL_DIR%"

echo 🔑 Generating SSL certificates for localhost...

REM Generate private key
openssl genrsa -out "%SSL_DIR%/localhost.key" 2048
if %errorlevel% neq 0 (
    echo ❌ Failed to generate private key
    exit /b 1
)

REM Generate certificate signing request
openssl req -new -key "%SSL_DIR%/localhost.key" -out "%SSL_DIR%/localhost.csr" -subj "/C=US/ST=Development/L=Local/O=QuizzTok/OU=Development/CN=localhost"
if %errorlevel% neq 0 (
    echo ❌ Failed to generate certificate signing request
    exit /b 1
)

REM Create extensions file for SAN
(
echo authorityKeyIdentifier=keyid,issuer
echo basicConstraints=CA:FALSE
echo keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
echo subjectAltName = @alt_names
echo.
echo [alt_names]
echo DNS.1 = localhost
echo DNS.2 = *.localhost
echo IP.1 = 127.0.0.1
echo IP.2 = ::1
) > "%SSL_DIR%/localhost.ext"

REM Generate self-signed certificate
openssl x509 -req -in "%SSL_DIR%/localhost.csr" -signkey "%SSL_DIR%/localhost.key" -out "%SSL_DIR%/localhost.crt" -days 365 -extensions v3_req -extfile "%SSL_DIR%/localhost.ext"
if %errorlevel% neq 0 (
    echo ❌ Failed to generate certificate
    exit /b 1
)

REM Clean up
del "%SSL_DIR%/localhost.csr" 2>nul
del "%SSL_DIR%/localhost.ext" 2>nul

echo ✅ SSL certificates generated successfully!
echo 📁 Certificates location: %SSL_DIR%
echo 🔒 Certificate: localhost.crt
echo 🔑 Private key: localhost.key
echo.
echo 💡 To trust the certificate in your browser:
echo    - Chrome/Edge: chrome://settings/certificates → Authorities → Import localhost.crt
echo    - Firefox: about:preferences#privacy → Certificates → View Certificates → Import