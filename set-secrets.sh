#!/bin/bash

# Set secrets for fly.io deployment

echo "🔐 Setting up secrets for fly.io deployment..."

# Check if flyctl is installed
if ! command -v flyctl &> /dev/null; then
    echo "❌ flyctl not found. Please install it first:"
    echo "   curl -L https://fly.io/install.sh | sh"
    exit 1
fi

# Check if logged in
if ! flyctl auth whoami &> /dev/null; then
    echo "❌ Not logged in to fly.io. Please run:"
    echo "   flyctl auth login"
    exit 1
fi

# Set API_BASE_URL secret
echo "📡 Setting API_BASE_URL..."
flyctl secrets set API_BASE_URL="https://wedding-card-online-service.fly.dev/api"

# Set other secrets (add as needed)
echo "🔑 Setting additional secrets..."
# flyctl secrets set JWT_SECRET="your-jwt-secret-here"
# flyctl secrets set DATABASE_URL="your-database-url-here"

# List current secrets (without values for security)
echo "✅ Current secrets:"
flyctl secrets list

echo "🎉 Secrets setup complete!"