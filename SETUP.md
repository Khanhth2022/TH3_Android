# Hướng dẫn cài đặt

## 📋 Yêu cầu
- Flutter SDK (phiên bản >=3.10.7)
- Dart SDK
- Android Studio / Xcode (tùy platform)
- API Key từ [NewsAPI.org](https://newsapi.org/)

## 🔐 Thiết lập API Key

### Bước 1: Lấy API Key
1. Truy cập [NewsAPI.org](https://newsapi.org/)
2. Đăng ký tài khoản miễn phí
3. Copy API Key của bạn

### Bước 2: Cấu hình file .env
1. Copy file `.env.example` thành `.env`:
   ```bash
   cp .env.example .env
   ```
   
2. Mở file `.env` và thay thế `your_api_key_here` bằng API key thực của bạn:
   ```
   NEWS_API_KEY=your_actual_api_key_here
   ```

### Bước 3: Cài đặt dependencies
```bash
flutter pub get
```

### Bước 4: Chạy ứng dụng
```bash
flutter run
```

## ⚠️ Lưu ý bảo mật
- **KHÔNG BAO GIỜ** commit file `.env` lên GitHub
- File `.env` đã được thêm vào `.gitignore`
- Chỉ commit file `.env.example` (không chứa API key thật)
- Mỗi developer cần tạo file `.env` riêng từ `.env.example`

## 🚀 Triển khai lên GitHub
Khi push code lên GitHub, chỉ những file sau sẽ được upload:
- ✅ `.env.example` - Template không chứa key thật
- ✅ Code đã được cập nhật để đọc từ `.env`
- ❌ `.env` - Bị ignore, không upload (chứa API key thật)

## 🤝 Chia sẻ project với team
1. Push code lên GitHub (không bao gồm `.env`)
2. Chia sẻ repo URL với teammate
3. Teammate clone repo và tự tạo file `.env` từ `.env.example`
4. Mỗi người dùng API key riêng của mình
