#!/bin/bash

# Deploy script for Flutter web app to fly.io

echo "🚀 Starting deployment to fly.io..."

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

# Set up secrets first (optional)
read -p "🔐 Do you want to set up secrets? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ./set-secrets.sh
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get

# Build Flutter web with API configuration from secrets
echo "🔨 Building Flutter web app..."
# Get API_BASE_URL from fly secrets
API_BASE_URL=$(flyctl secrets list | grep API_BASE_URL | awk '{print $2}')
flutter build web --release --dart-define=API_BASE_URL="$API_BASE_URL"

# Deploy to fly.io with build args from secrets
echo "🚀 Deploying to fly.io..."
flyctl deploy --build-arg API_BASE_URL="$API_BASE_URL"

# Check status
echo "✅ Deployment complete!"
echo "🌐 App URL: https://$(flyctl info --name ben-mae-the-wedding | grep Hostname | awk '{print $2}')"

echo "📊 App status:"
flyctl status