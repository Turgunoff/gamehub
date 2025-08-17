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

## 📱 Features

### MVP (3 oy)

- [x] Project structure setup
- [ ] Authentication system
- [ ] Basic tournament system
- [ ] Team management
- [ ] Chat functionality
- [ ] Payment integration

### Phase 1 (6 oy)

- [ ] Advanced tournament features
- [ ] Coaching platform
- [ ] Real-time features
- [ ] Push notifications

### Phase 2 (12 oy)

- [ ] Advanced matchmaking
- [ ] Video integration
- [ ] AI recommendations

## 🛠️ Development

### Dependencies qo'shish

```bash
flutter pub add flutter_bloc go_router supabase_flutter hive
```

### Supabase setup

- Database schema
- Authentication
- Real-time subscriptions

## 📚 Documentation

- [Technical Specification](docs/esports_app_technical_specification.md)
- [API Documentation](docs/api/)
- [Database Schema](docs/database/)

## 🤝 Contributing

1. Feature branch yarating
2. Clean Architecture prinsiplariga amal qiling
3. Test yozing
4. Pull request yuboring

## 📄 License

MIT License - see LICENSE file for details

---

**Development Status**: 🚧 In Progress  
**Version**: 0.1.0  
**Last Updated**: August 2025
