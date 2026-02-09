#!/bin/bash

# Script to optimize images for web using ImageMagick
# This will reduce file size while maintaining visual quality

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🖼️  Image Optimization Script"
echo "================================"

# Check if ImageMagick is installed
if ! command -v magick &> /dev/null && ! command -v convert &> /dev/null; then
    echo -e "${RED}❌ ImageMagick not found. Please install it first:${NC}"
    echo "   macOS: brew install imagemagick"
    echo "   Ubuntu: sudo apt-get install imagemagick"
    exit 1
fi

# Use 'magick' command if available (ImageMagick 7+), otherwise use 'convert' (ImageMagick 6)
if command -v magick &> /dev/null; then
    CONVERT_CMD="magick"
else
    CONVERT_CMD="convert"
fi

# Directory containing images
IMAGE_DIR="assets/images/journey-of-us"

if [ ! -d "$IMAGE_DIR" ]; then
    echo -e "${RED}❌ Directory $IMAGE_DIR not found${NC}"
    exit 1
fi

# Create backup directory
BACKUP_DIR="assets/images/journey-of-us-backup-$(date +%Y%m%d-%H%M%S)"
echo -e "${YELLOW}📦 Creating backup at: $BACKUP_DIR${NC}"
cp -r "$IMAGE_DIR" "$BACKUP_DIR"

# Counter for statistics
total_files=0
total_original_size=0
total_optimized_size=0

echo ""
echo "🔄 Starting optimization..."
echo ""

# Find and optimize all images
find "$IMAGE_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | while read -r file; do
    # Get original size
    original_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
    
    # Skip if file is already small (less than 200KB)
    if [ "$original_size" -lt 204800 ]; then
        echo -e "${GREEN}✓${NC} Skipping (already small): $(basename "$file")"
        continue
    fi
    
    echo -n "Processing: $(basename "$file") ($(numfmt --to=iec-i --suffix=B $original_size 2>/dev/null || echo "$original_size bytes"))..."
    
    # Create temporary file
    temp_file="${file}.tmp"
    
    # Optimize based on file type
    if [[ "$file" =~ \.(jpg|jpeg)$ ]]; then
        # For JPEG: resize if too large, reduce quality, strip metadata
        $CONVERT_CMD "$file" \
            -resize '1920x1920>' \
            -quality 85 \
            -sampling-factor 4:2:0 \
            -strip \
            -interlace Plane \
            "$temp_file"
    else
        # For PNG: resize and optimize
        $CONVERT_CMD "$file" \
            -resize '1920x1920>' \
            -strip \
            "$temp_file"
    fi
    
    # Check if optimization was successful
    if [ $? -eq 0 ] && [ -f "$temp_file" ]; then
        # Get new size
        new_size=$(stat -f%z "$temp_file" 2>/dev/null || stat -c%s "$temp_file" 2>/dev/null)
        
        # Only replace if new file is smaller
        if [ "$new_size" -lt "$original_size" ]; then
            mv "$temp_file" "$file"
            reduction=$((100 - (new_size * 100 / original_size)))
            echo -e " ${GREEN}✓${NC} Saved ${reduction}% ($(numfmt --to=iec-i --suffix=B $new_size 2>/dev/null || echo "$new_size bytes"))"
            
            total_files=$((total_files + 1))
            total_original_size=$((total_original_size + original_size))
            total_optimized_size=$((total_optimized_size + new_size))
        else
            rm "$temp_file"
            echo -e " ${YELLOW}⚠${NC}  No improvement"
        fi
    else
        [ -f "$temp_file" ] && rm "$temp_file"
        echo -e " ${RED}✗${NC} Failed"
    fi
done

echo ""
echo "================================"
echo -e "${GREEN}✅ Optimization complete!${NC}"
echo ""
echo "📊 Statistics:"
echo "  Files optimized: $total_files"

if [ "$total_files" -gt 0 ]; then
    total_saved=$((total_original_size - total_optimized_size))
    total_reduction=$((100 - (total_optimized_size * 100 / total_original_size)))
    
    echo "  Original size: $(numfmt --to=iec-i --suffix=B $total_original_size 2>/dev/null || echo "$total_original_size bytes")"
    echo "  Optimized size: $(numfmt --to=iec-i --suffix=B $total_optimized_size 2>/dev/null || echo "$total_optimized_size bytes")"
    echo "  Total saved: $(numfmt --to=iec-i --suffix=B $total_saved 2>/dev/null || echo "$total_saved bytes") ($total_reduction%)"
fi

echo ""
echo "💾 Backup saved at: $BACKUP_DIR"
echo ""
echo -e "${YELLOW}⚠️  Remember to rebuild your app:${NC}"
echo "   flutter clean && flutter build web --release"
