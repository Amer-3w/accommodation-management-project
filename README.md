ad the report and presen# 🎓 EduStay - Student Accommodation Platform

<div align="center">
  <p><em>Connecting Students with Safe & Comfortable Housing</em></p>
  <p><em>منصة تربط الطلاب بأماكن سكن آمنة ومناسبة</em></p>
</div>

---

## 📋 Overview | نظرة عامة

**EduStay** is a comprehensive student accommodation management platform built with **Laravel** (backend API) and **Flutter** (mobile application). The platform connects university students with property owners, enabling students to search, book, pay for, and review accommodations — all from their mobile device.

**EduStay** هو منصة متكاملة لإدارة سكن الطلاب، تم بناؤها باستخدام Laravel للواجهة الخلفية و Flutter للتطبيق الجوال. تهدف المنصة إلى ربط الطلاب الجامعيين بأصحاب العقارات، مما يتيح للطلاب البحث عن السكن وحجزه ودفع ثمنه وتقييمه — كل ذلك من خلال أجهزتهم الجوالة.

---

## ✨ Key Features | المميزات الرئيسية

| Feature | Description |
|---------|-------------|
| 🏠 **Property Listings** | Browse, search, and filter accommodations by location, price, rooms, and more |
| 📅 **Booking System** | Book properties with date range selection and automatic price calculation |
| 💳 **Payments** | Secure payment processing with cash/card options |
| ⭐ **Reviews & Ratings** | Rate properties and read reviews from other students |
| 💬 **Messaging** | In-app chat between students and property owners |
| ❤️ **Favorites** | Save preferred properties for quick access |
| 📞 **WhatsApp Integration** | Contact property owners directly via WhatsApp |
| 🛟 **Support System** | Built-in support ticket system for assistance |
| 👥 **Role Management** | Three roles: Admin, Owner (property manager), User (student) |

---

## 🛠️ Tech Stack | التقنيات المستخدمة

### Backend
- **Framework:** Laravel 12
- **Language:** PHP 8.2
- **Database:** MySQL
- **Auth:** Laravel Sanctum (Bearer Token API)
- **Testing:** PHPUnit (12 tests, 39 assertions)

### Mobile
- **Framework:** Flutter
- **Language:** Dart
- **State Management:** Provider
- **HTTP Client:** http package
- **Maps:** Google Maps Flutter
- **Image Handling:** cached_network_image, image_picker

### Tools
- **Version Control:** Git & GitHub
- **Local Environment:** XAMPP
- **Package Manager:** Composer (PHP), Pub (Dart)

---

## 📊 Database Schema | هيكل قاعدة البيانات

The database is designed around **schema.sql** as the source of truth, containing **11 core tables**:

- `users` — User accounts with role-based access (admin, owner, user)
- `properties` — Property listings with pricing, location, amenities
- `property_images` — Multiple images per property
- `bookings` — Reservation records with full pricing breakdown
- `payments` — Payment tracking (cash/card)
- `messages` — In-app messaging between users
- `reviews` — Property ratings and reviews
- `favorites` — Saved properties per user
- `support_messages` — Help/support ticket system
- `user_whatsapp_numbers` — Multiple WhatsApp numbers per user
- `personal_access_tokens` — Sanctum authentication tokens

---

## 🚀 Installation Guide | دليل التثبيت

### Backend Setup

```bash
# 1. Navigate to backend directory
cd backend

# 2. Install PHP dependencies
composer install

# 3. Copy environment file
cp .env.example .env

# 4. Generate application key
php artisan key:generate

# 5. Configure your database in .env file
#    DB_DATABASE=EduStay
#    DB_USERNAME=root
#    DB_PASSWORD=

# 6. Run migrations (using schema.sql as reference)
php artisan migrate

# 7. Start the development server
php artisan serve
```

### Mobile Setup

```bash
# 1. Navigate to mobile directory
cd mobile

# 2. Install Flutter dependencies
flutter pub get

# 3. Run the app
flutter run
```

---

## 🗺️ API Endpoints | نقاط النهاية

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/register` | User registration |
| POST | `/api/login` | User login |
| GET | `/api/me` | Get current user |
| PUT | `/api/update-profile` | Update profile |
| POST | `/api/logout` | Logout |
| GET | `/api/properties` | List properties |
| GET | `/api/properties/{id}` | Property details |
| POST | `/api/bookings` | Create booking |
| GET | `/api/bookings` | User's bookings |
| POST | `/api/payments` | Process payment |
| GET | `/api/messages` | Get messages |
| POST | `/api/messages` | Send message |
| GET | `/api/reviews` | Get reviews |
| POST | `/api/reviews` | Submit review |
| POST | `/api/favorites` | Toggle favorite |
| POST | `/api/support` | Send support message |
| GET | `/api/whatsapp-numbers` | Get WhatsApp numbers |

---

## 🧪 Testing | الاختبارات

All backend tests pass successfully with PHPUnit:

```bash
cd backend && php artisan test
```

- ✅ 12 tests
- ✅ 39 assertions
- ✅ Authentication, booking overlap, role access, and payment ownership verified

---

## 📸 Screenshots | لقطات الشاشة

| Admin Panel | Mobile App |
|-------------|------------|
| ![Admin](Screenshots/admin%20panel/) | ![App](Screenshots/app/) |

---

## 📄 Documentation | التوثيق

- **Database Schema:** [`schema.sql`](schema.sql) — Source of truth for the database design
- **Presentation Guide:** Available in the project deliverables

---

## 👥 Team | فريق العمل

<!-- Add your team members here -->

| Name | University ID | Role |
|------|--------------|------|
| <!-- Name --> | <!-- ID --> | <!-- Role --> |

---

## 📬 Links | الروابط

- **GitHub Repository:** [github.com/Amer-3w/accommodation-management-project](https://github.com/Amer-3w/accommodation-management-project)
- **Video:** <!-- Add your video link here -->

---

## 📝 License | الترخيص

This project was developed as a graduation project for educational purposes.

---

<div align="center">
  <p>🎓 <strong>EduStay</strong> — Making Student Housing Easier</p>
  <p>🕌 <strong>إيدو ستاي</strong> — لتسهيل سكن الطلاب</p>
</div>