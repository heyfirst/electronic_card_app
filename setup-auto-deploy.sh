#!/bin/bash

# Setup GitHub repository secrets for auto deployment

echo "🔧 Setting up GitHub repository for auto deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📋 Instructions to set up auto deployment:${NC}"
echo
echo -e "${YELLOW}1. Get your Fly.io API Token:${NC}"
echo "   flyctl auth token"
echo

echo -e "${YELLOW}2. Add the token to GitHub repository secrets:${NC}"
echo "   - Go to your GitHub repository"
echo "   - Navigate to Settings > Secrets and variables > Actions"
echo "   - Click 'New repository secret'"
echo "   - Name: FLY_API_TOKEN"
echo "   - Value: [paste your token from step 1]"
echo

echo -e "${YELLOW}3. Push to main branch:${NC}"
echo "   git add ."
echo "   git commit -m \"Add auto deployment\""
echo "   git push origin main"
echo

echo -e "${GREEN}✨ After setup, every push to main branch will trigger auto deployment!${NC}"
echo

# Optional: Get the current fly token if logged in
if command -v flyctl &> /dev/null && flyctl auth whoami &> /dev/null; then
    echo -e "${BLUE}🔑 Your current Fly.io API token:${NC}"
    flyctl auth token
    echo
    echo -e "${YELLOW}💡 Copy this token and add it to GitHub secrets as 'FLY_API_TOKEN'${NC}"
else
    echo -e "${RED}⚠️  Please login to Fly.io first: flyctl auth login${NC}"
fi