# GameHub Pro - Gaming va Esports Platformasi

## 🎮 Loyiha haqida

GameHub Pro - professional gaming va esports platformasi. O'yinchilar uchun turnirlar tashkil etish, jamoalar yaratish va coaching xizmatlarini ta'minlovchi mobil ilova.

## 🏗️ Project Structure (Clean Architecture)

```
lib/
├── core/                    # Core functionality
│   ├── config/             # App configuration
│   ├── constants/           # App constants
│   ├── errors/              # Error handling
│   ├── router/              # Navigation routing
│   ├── services/            # Core services (Network, etc.)
│   ├── theme/               # App theming
│   ├── utils/               # Utility functions
│   └── widgets/             # Shared widgets
│
├── features/                 # Feature modules
│   ├── auth/                # Authentication
│   │   ├── data/            # Data layer
│   │   │   ├── datasources/ # Remote/Local data sources
│   │   │   ├── models/      # Data models
│   │   │   └── repositories/# Repository implementations
│   │   ├── domain/          # Business logic layer
│   │   │   ├── entities/    # Business entities
│   │   │   ├── repositories/# Repository interfaces
│   │   │   └── usecases/    # Business use cases
│   │   └── presentation/    # UI layer
│   │       ├── bloc/        # State management
│   │       ├── pages/       # Screen pages
│   │       └── widgets/     # Feature-specific widgets
│   │
│   ├── tournaments/         # Tournament management
│   ├── teams/               # Team management
│   ├── chat/                # Chat functionality
│   ├── coaching/            # Coaching platform
│   ├── profile/             # User profiles
│   └── home/                # Home dashboard
│
└── shared/                  # Shared resources
    ├── models/              # Shared data models
    ├── widgets/             # Shared UI components
    ├── utils/               # Shared utilities
    └── constants/           # Shared constants
```

## 🎯 Clean Architecture Principles

### 1. **Data Layer** (`data/`)

- **Datasources**: API calls, local storage
- **Models**: Data transfer objects (DTOs)
- **Repositories**: Data access implementations

### 2. **Domain Layer** (`domain/`)

- **Entities**: Business objects
- **Repository Interfaces**: Abstract data access
- **Use Cases**: Business logic implementation

### 3. **Presentation Layer** (`presentation/`)

- **Bloc**: State management
- **Pages**: Screen implementations
- **Widgets**: UI components

## 🚀 Texnik Stack

- **Framework**: Flutter 3.19+
- **State Management**: Flutter Bloc 8.1+
- **Navigation**: Go Router
- **Backend**: Supabase
- **Local Storage**: Hive
- **Architecture**: Clean Architecture

## 🔐 Authentication System

### Email OTP Authentication

- **Email + OTP**: Email kiritib, 6 xonali kod bilan tasdiqlash
- **Avtomatik Registration**: Yangi foydalanuvchilar avtomatik ro'yxatdan o'tadi
- **Seamless Login**: Mavjud foydalanuvchilar to'g'ridan-to'g'ri tizimga kirishadi
- **Social Login**: Google va Discord orqali kirish
- **Secure**: Parol kerak emas, OTP bilan xavfsiz

### How It Works

1. Foydalanuvchi email kiritadi
2. 6 xonali kod email ga yuboriladi
3. Kod kiritilganda:
   - Agar user mavjud bo'lsa → Login
   - Agar user mavjud bo'lmasa → Avtomatik registration + Login
4. User profili avtomatik yaratiladi

### Afzalliklari

- **Xavfsizlik**: Parol saqlash va eslash muammosi yo'q
- **Qulaylik**: Email + OTP bilan tez kirish
- **Avtomatik**: Registration/login jarayoni avtomatik
- **Platform**: Barcha platformalarda ishlaydi
- **UX**: Foydalanuvchi uchun oddiy va tushunarli

### Texnik Tafsilotlar

- **OTP Type**: Email OTP (6 xonali kod)
- **Provider**: Supabase Auth
- **Storage**: User profili avtomatik yaratiladi
- **Error Handling**: Barcha xatoliklar handle qilinadi
- **Validation**: Email format va kod uzunligi tekshiriladi

## 📱 Features

### MVP (3 oy)

- [x] Project structure setup
- [x] Authentication system (Email OTP + Social)
- [x] User profile management
- [x] Onboarding system
- [x] Navigation system
- [x] Error handling
- [x] Users table structure
- [x] OTP system (6 xonali kod)
- [x] OTP verification page
- [x] Single long OTP input field
- [x] Countdown timer
- [x] Timer disposal handling
- [ ] Basic tournament system
- [ ] Team management
- [ ] Chat functionality
- [ ] Payment integration

### Phase 1 (6 oy)

- [ ] Advanced tournament features
- [ ] Coaching platform
- [ ] Real-time features
- [ ] Push notifications
- [ ] Advanced user profiles
- [ ] Team management
- [ ] Chat system
- [ ] Advanced error handling
- [ ] Advanced OTP system

### Phase 2 (12 oy)

- [ ] Advanced matchmaking
- [ ] Video integration
- [ ] AI recommendations
- [ ] Advanced analytics
- [ ] Advanced coaching
- [ ] Advanced tournaments
- [ ] Advanced navigation
- [ ] Advanced authentication

## 🛠️ Development

### Dependencies qo'shish

```bash
flutter pub add flutter_bloc go_router supabase_flutter hive flutter_animate
```

### Supabase setup

- Database schema
- Authentication (Email OTP enabled, Magic Link o'rniga)
- Real-time subscriptions
- Email templates (6 xonali kod uchun)
- Rate limiting
- Users table (SQL script mavjud)
- Onboarding system
- Error handling system
- OTP verification system

## 🎯 Keyingi Qadamlar

### 1. Supabase Console Configuration

- [ ] Email OTP ni yoqish (Magic Link o'rniga)
- [ ] Email template larni sozlash (6 xonali kod uchun)
- [ ] Rate limiting ni sozlash
- [ ] Google va Discord OAuth ni sozlash
- [ ] Users table yaratish (SQL script mavjud)
- [ ] Onboarding system ni sozlash
- [ ] Error handling system ni sozlash

### 2. Authentication Testing

- [ ] OTP flow ni test qilish (6 xonali kod)
- [ ] OTP verification page test qilish
- [ ] Countdown timer test qilish
- [ ] Email editing functionality test qilish
- [ ] Error handling test qilish
- [ ] User profile creation test qilish
- [ ] Social login test qilish
- [ ] Onboarding flow test qilish
- [ ] Error handling test qilish
- [ ] Magic Link emas, OTP test qilish

### 3. Core Features

- [ ] Home page yaratish
- [ ] Navigation drawer qo'shish
- [ ] User profile management
- [ ] Tournament system

### 4. Testing

- [ ] Authentication flow test qilish
- [ ] Error handling test qilish
- [ ] UI/UX test qilish
- [ ] Performance test qilish
- [ ] Navigation test qilish
- [ ] Error handling test qilish
- [ ] OTP system test qilish (6 xonali kod)
- [ ] OTP verification page UI test qilish
- [ ] Countdown timer functionality test qilish
- [ ] Timer disposal test qilish

## 📚 Documentation

- [Technical Specification](docs/esports_app_technical_specification.md)
- [API Documentation](docs/api/)
- [Database Schema](docs/database/)
- [Authentication Flow](docs/authentication.md)
- [Users Table Schema](docs/users_table.md)
- [Onboarding System](docs/onboarding.md)
- [Error Handling](docs/error_handling.md)
- [OTP System](docs/otp_system.md)
- [OTP Verification Page](docs/otp_verification.md)

## 🤝 Contributing

1. Feature branch yarating
2. Clean Architecture prinsiplariga amal qiling
3. Test yozing
4. Pull request yuboring
5. Authentication flow ni test qiling
6. OTP system ni test qiling (6 xonali kod)
7. OTP verification page ni test qiling
8. Countdown timer ni test qiling
9. User profile system ni test qiling
10. Onboarding system ni test qiling
11. Error handling system ni test qiling
12. Magic Link emas, OTP test qilish

## 📄 License

MIT License - see LICENSE file for details

## 🔐 Authentication Flow

```
Email Input → Send OTP → OTP Verification Page → Verify OTP → Auto Login/Register → Home
```

**Features:**

- ✅ Email validation
- ✅ 6-digit OTP (Magic Link emas)
- ✅ Separate OTP verification page
- ✅ Single long OTP input field
- ✅ 60-second countdown timer
- ✅ Email editing functionality
- ✅ Timer disposal handling
- ✅ Auto user creation
- ✅ Profile management
- ✅ Error handling
- ✅ Social login (Google/Discord)
- ✅ Onboarding system
- ✅ Navigation system
- ✅ Users table management
- ✅ OTP expiration handling
- ✅ OTP rate limiting

---

**Development Status**: 🚧 In Progress  
**Version**: 0.4.2  
**Last Updated**: August 2025  
**Current Focus**: OTP verification page completed with single long input field, countdown timer, and email editing. Users table structure ready. Ready for Supabase Console configuration and testing.
