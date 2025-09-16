#!/bin/bash

# Generate SSL certificates for local HTTPS development
# This script creates self-signed certificates for localhost

SSL_DIR="./ssl"
mkdir -p "$SSL_DIR"

# Generate private key
openssl genrsa -out "$SSL_DIR/localhost.key" 2048

# Generate certificate signing request
openssl req -new -key "$SSL_DIR/localhost.key" -out "$SSL_DIR/localhost.csr" -subj "/C=US/ST=Development/L=Local/O=QuizzTok/OU=Development/CN=localhost"

# Create extensions file for SAN
cat > "$SSL_DIR/localhost.ext" << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = *.localhost
IP.1 = 127.0.0.1
IP.2 = ::1
EOF

# Generate self-signed certificate
openssl x509 -req -in "$SSL_DIR/localhost.csr" -signkey "$SSL_DIR/localhost.key" -out "$SSL_DIR/localhost.crt" -days 365 -extensions v3_req -extfile "$SSL_DIR/localhost.ext"

# Set proper permissions
chmod 600 "$SSL_DIR/localhost.key"
chmod 644 "$SSL_DIR/localhost.crt"

# Clean up
rm "$SSL_DIR/localhost.csr" "$SSL_DIR/localhost.ext"

echo "✅ SSL certificates generated successfully!"
echo "📁 Certificates location: $SSL_DIR"
echo "🔒 Certificate: localhost.crt"
echo "🔑 Private key: localhost.key"
echo ""
echo "💡 To trust the certificate in your browser:"
echo "   - Chrome/Edge: chrome://settings/certificates → Authorities → Import localhost.crt"
echo "   - Firefox: about:preferences#privacy → Certificates → View Certificates → Import"