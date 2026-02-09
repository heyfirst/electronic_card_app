# Image Optimization Guide

## ปัญหา: รูปภาพโหลดช้า

รูปภาพใน `assets/images/journey-of-us/` มีขนาดใหญ่มาก (บางรูปถึง 3.2MB) ทำให้โหลดช้า

## วิธีแก้

### 1. Optimize รูปภาพ (แนะนำ)

ใช้ script ที่เตรียมไว้:

```bash
# รัน script optimize
./scripts/optimize-images.sh

# หลัง optimize แล้ว rebuild
flutter clean
flutter build web --release
```

**Script จะ:**

- สำรองรูปเดิมไว้ก่อน
- ลดขนาดรูปให้เหลือไม่เกิน 1920px
- ลด quality เป็น 85% (ยังคงคุณภาพดี)
- ลบ metadata ที่ไม่จำเป็น
- ประหยัดพื้นที่ได้ 50-70%

### 2. ติดตั้ง ImageMagick (ถ้ายังไม่มี)

**macOS:**

```bash
brew install imagemagick
```

**Ubuntu/Debian:**

```bash
sudo apt-get install imagemagick
```

### 3. Manual Optimization (Alternative)

ถ้าต้องการ optimize รูปเอง:

```bash
# Optimize single image
magick input.jpg -resize 1920x1920> -quality 85 -strip output.jpg

# Optimize all JPG in current directory
for img in *.jpg; do
    magick "$img" -resize 1920x1920> -quality 85 -strip "optimized-$img"
done
```

## เทคนิคเพิ่มเติมที่ใช้แล้ว

### ✅ Image Precaching

- Precache รูปสำคัญใน `SplashScreen`
- Precache ทุกรูปใน `Gallery` เมื่อโหลด JSON
- Precache main logo ใน `MyHomePage`

### ✅ Nginx Cache Headers

```nginx
# JS/CSS - cache 1 ชั่วโมง + revalidate
location ~* \.(js|css)$ {
    expires 1h;
    add_header Cache-Control "public, must-revalidate, max-age=3600";
}

# Images - cache 7 วัน
location ~* \.(png|jpg|jpeg|gif|GIF|ico|svg)$ {
    expires 7d;
    add_header Cache-Control "public, max-age=604800, immutable";
}
```

### ✅ Gzip Compression

- เปิดใช้ gzip สำหรับ text files
- ลดขนาด JS/CSS/HTML ได้ 70-80%

## คำแนะนำเพิ่มเติม

### Progressive Loading

พิจารณาใช้ `FadeInImage` แทน `Image.asset`:

```dart
FadeInImage(
  placeholder: AssetImage('assets/images/placeholder.png'),
  image: AssetImage('assets/images/journey-of-us/2025/5.jpg'),
  fadeInDuration: Duration(milliseconds: 300),
)
```

### Lazy Loading

โหลดรูปเฉพาะที่แสดงบนหน้าจอ:

```dart
ListView.builder(
  itemCount: images.length,
  itemBuilder: (context, index) {
    return Image.asset(images[index]);
  },
)
```

### WebP Format (Future Enhancement)

WebP ให้ขนาดเล็กกว่า JPEG 25-35% แต่ยังคงคุณภาพเท่าเดิม:

```bash
# Convert to WebP
for img in *.jpg; do
    cwebp -q 85 "$img" -o "${img%.jpg}.webp"
done
```

## ผลลัพธ์ที่คาดหวัง

หลัง optimize:

- 🚀 โหลดเร็วขึ้น 2-3 เท่า
- 💾 ประหยัดพื้นที่ 50-70%
- 📱 Mobile-friendly มากขึ้น
- 🌐 ลด bandwidth cost

## ข้อควรระวัง

- **สำรองรูปเดิมก่อนเสมอ** - script จะสำรองให้อัตโนมัติ
- **ตรวจสอบคุณภาพ** - หลัง optimize ควรตรวจดูว่ารูปยังคมชัดพอ
- **Rebuild app** - อย่าลืม rebuild หลัง optimize

## Troubleshooting

### Script ไม่ทำงาน

```bash
# ตรวจสอบว่าติดตั้ง ImageMagick แล้ว
magick --version

# ให้สิทธิ์ execute
chmod +x scripts/optimize-images.sh
```

### รูปเสีย/เบลอ

- ลอง quality สูงขึ้น (90 แทน 85)
- อย่าลดขนาดถ้ารูปเล็กอยู่แล้ว

### ต้องการกู้รูปเดิม

```bash
# ใช้ backup ที่สร้างไว้
cp -r assets/images/journey-of-us-backup-YYYYMMDD-HHMMSS/* assets/images/journey-of-us/
```
