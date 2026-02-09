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

# Check assets files
echo "📂 Checking assets files..."
echo "=== Main images ==="
ls -lh assets/images/ 2>/dev/null || echo "⚠️  assets/images/ not found"
echo ""
echo "=== Journey of us ==="
if [ -d "assets/images/journey-of-us/" ]; then
    echo "Total files: $(find assets/images/journey-of-us/ -type f | wc -l | tr -d ' ')"
    ls -lh assets/images/journey-of-us/
else
    echo "⚠️  assets/images/journey-of-us/ not found"
fi
echo ""
echo "=== Preview images ==="
ls -lh assets/images/perview/ 2>/dev/null || echo "⚠️  assets/images/perview/ not found"
echo ""
echo "=== Icons ==="
ls -lh assets/icons/ 2>/dev/null || echo "⚠️  assets/icons/ not found"
echo ""
echo "=== Checking critical files ==="
[ -f "assets/images/main-logo.png" ] && echo "✓ main-logo.png exists" || echo "✗ main-logo.png missing"
[ -f "assets/images/mini-logo.png" ] && echo "✓ mini-logo.png exists" || echo "✗ mini-logo.png missing"
[ -f "assets/images/thank-you-logo.png" ] && echo "✓ thank-you-logo.png exists" || echo "✗ thank-you-logo.png missing"
[ -f "assets/icons/wedding-invitation.png" ] && echo "✓ wedding-invitation.png exists" || echo "✗ wedding-invitation.png missing"
[ -f "assets/images/journey-of-us/timeline_metadata.json" ] && echo "✓ timeline_metadata.json exists" || echo "✗ timeline_metadata.json missing"
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf build
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