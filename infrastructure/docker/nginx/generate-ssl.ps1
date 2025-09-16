# PowerShell script to generate SSL certificates for local development

$sslDir = "ssl"
if (!(Test-Path $sslDir)) {
    New-Item -ItemType Directory -Path $sslDir | Out-Null
}

Write-Host "🔑 Generating SSL certificates for localhost..." -ForegroundColor Cyan

try {
    # Check if OpenSSL is available
    $null = Get-Command openssl -ErrorAction Stop

    # Generate private key
    Write-Host "Generating private key..." -ForegroundColor Yellow
    & openssl genrsa -out "$sslDir/localhost.key" 2048

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to generate private key"
    }

    # Generate self-signed certificate
    Write-Host "Generating certificate..." -ForegroundColor Yellow
    & openssl req -x509 -new -key "$sslDir/localhost.key" -out "$sslDir/localhost.crt" -days 365 -nodes -subj '/C=US/ST=Development/L=Local/O=QuizzTok/CN=localhost'

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to generate certificate"
    }

    Write-Host "✅ SSL certificates generated successfully!" -ForegroundColor Green
    Write-Host "📁 Certificates location: $sslDir" -ForegroundColor White
    Write-Host "🔒 Certificate: localhost.crt" -ForegroundColor White
    Write-Host "🔑 Private key: localhost.key" -ForegroundColor White
    Write-Host ""
    Write-Host "💡 To trust the certificate in your browser:" -ForegroundColor Cyan
    Write-Host "   - Chrome/Edge: chrome://settings/certificates → Authorities → Import localhost.crt" -ForegroundColor White
    Write-Host "   - Firefox: about:preferences#privacy → Certificates → View Certificates → Import" -ForegroundColor White

} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "💡 Make sure OpenSSL is installed and available in PATH" -ForegroundColor Yellow
    Write-Host "   You can install OpenSSL via: choco install openssl" -ForegroundColor Yellow
    exit 1
}