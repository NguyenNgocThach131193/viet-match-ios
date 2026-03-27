# VietMatch - Hướng Dẫn Phát Triển

> Ngày tạo: 2026-03-26 | Scan Level: Deep

---

## 1. Yêu Cầu Hệ Thống

| Yêu cầu | Chi tiết |
|----------|---------|
| **macOS** | macOS 13+ (Ventura trở lên) |
| **Xcode** | 15.0+ |
| **Swift** | 5.9+ |
| **iOS Target** | iOS 16.0+ |
| **Device** | iPhone only |

---

## 2. Cài Đặt & Thiết Lập

### Clone repository

```bash
git clone <repo-url>
cd viet-match-ios
```

### Mở dự án

```bash
open VietMatch.xcodeproj
```

Hoặc nếu sử dụng XcodeGen:

```bash
# Cài đặt XcodeGen (nếu chưa có)
brew install xcodegen

# Generate Xcode project từ project.yml
xcodegen generate

# Mở project
open VietMatch.xcodeproj
```

### Cài đặt Dependencies

Dependencies được quản lý qua **Swift Package Manager (SPM)**. Khi mở project trong Xcode, SPM tự động resolve packages:

| Package | Version | Mục đích |
|---------|---------|---------|
| Firebase iOS SDK | 11.0+ | Auth, Firestore, Storage, FCM, Analytics |
| Alamofire | 5.9+ | HTTP networking |
| Kingfisher | 7.12+ | Image loading & caching |
| Swinject | 2.9+ | Dependency Injection |

Nếu cần resolve thủ công:
- Xcode → File → Packages → Resolve Package Versions

### Cấu hình Firebase

1. Tạo project trên [Firebase Console](https://console.firebase.google.com)
2. Thêm iOS app với Bundle ID: `com.vietmatch.app`
3. Tải `GoogleService-Info.plist`
4. Đặt vào `VietMatch/App/Resources/GoogleService-Info.plist`
5. Enable các services: Authentication, Cloud Firestore, Storage, Cloud Messaging

### Firebase Auth Setup

- Enable Email/Password provider
- Enable Apple Sign-In provider
- Enable Google Sign-In provider (optional)

---

## 3. Build & Run

### Debug Build

```bash
# Build từ command line
xcodebuild -scheme VietMatch -destination 'platform=iOS Simulator,name=iPhone 15'

# Hoặc mở Xcode → Select scheme "VietMatch" → Run (Cmd+R)
```

### Configurations

| Config | Sử dụng |
|--------|---------|
| Debug | Development, Xcode Previews enabled |
| Release | App Store, optimized |

---

## 4. Testing

### Unit Tests

```bash
# Chạy tất cả unit tests
xcodebuild test -scheme VietMatch -destination 'platform=iOS Simulator,name=iPhone 15'
```

**Coverage:**

| Test File | Kiểm tra |
|-----------|----------|
| AuthRepositoryTests | DTO ↔ Domain mapping (User, Profile) |
| LoginUseCaseTests | Login validation (empty email/password, repo failure) |
| SwipeUseCaseTests | Swipe logic (like/dislike, match detection) |
| LoginViewModelTests | Form validation, login success/failure |
| DiscoverViewModelTests | Profile loading, state management |

### UI Tests

```bash
# Chạy UI tests
xcodebuild test -scheme VietMatch -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:VietMatchUITests
```

**Launch Arguments:**
- `--uitesting`: Enable UI testing mode
- `--authenticated`: Skip authentication (for authenticated-only tests)

**Coverage:**

| Test File | Kiểm tra |
|-----------|----------|
| AuthFlowUITests | Login screen elements, navigation to register, empty field error |
| DiscoverFlowUITests | Tab bar (4 tabs: Khám phá, Matches, Chat, Hồ sơ) |

### Mocks

3 mock repositories cho testing:
- `MockAuthRepository` - Configurable login/register results, call counting
- `MockMatchRepository` - Configurable swipe/match/discover results
- `MockProfileRepository` - Configurable profile/photo results

---

## 5. Kiến Trúc & Conventions

### Cấu trúc file mới

```
Feature mới → Tạo files theo pattern:
├── Domain/
│   ├── Entities/NewEntity.swift
│   ├── Repositories/NewRepositoryProtocol.swift
│   └── UseCases/Feature/NewUseCase.swift
├── Data/
│   ├── DTOs/NewEntityDTO.swift
│   └── Repositories/NewRepository.swift
└── Presentation/
    └── Screens/Feature/
        ├── FeatureView.swift
        └── FeatureViewModel.swift
```

### Naming Conventions

| Loại | Convention | Ví dụ |
|------|-----------|-------|
| Entity | PascalCase | `Profile`, `Match` |
| Protocol | PascalCase + Protocol | `AuthRepositoryProtocol` |
| UseCase | PascalCase + UseCase | `LoginUseCase` |
| ViewModel | PascalCase + ViewModel | `LoginViewModel` |
| DTO | PascalCase + DTO | `UserDTO` |
| View | PascalCase + View | `LoginView` |
| Coordinator | PascalCase + Coordinator | `AuthCoordinator` |

### Patterns sử dụng

| Pattern | Mô tả |
|---------|-------|
| **Clean Architecture** | 3 layers: Presentation → Domain ← Data |
| **MVVM-C** | View → ViewModel → UseCase, Coordinator handles navigation |
| **Repository Pattern** | Protocol in Domain, Implementation in Data |
| **DI (Swinject)** | All dependencies injected through container |
| **Coordinator Pattern** | Each feature has its own Coordinator |
| **DTO Pattern** | Separate DTOs for Firestore data (snake_case Codable) |

### Async Patterns

```swift
// UseCase: async/await
func execute(email: String, password: String) async throws -> User

// ViewModel: @MainActor + Task
@MainActor
class LoginViewModel: ObservableObject {
    func login() async {
        isLoading = true
        do {
            let user = try await loginUseCase.execute(...)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

// Real-time: Combine Publishers
func observeMessages(matchId: String) -> AnyPublisher<[Message], Error>
```

---

## 6. Git Workflow

Dự án sử dụng **GitFlow** (chi tiết trong [GITFLOW.md](../GITFLOW.md)):

| Nhánh | Mục đích |
|-------|---------|
| `main` | Production-ready, tagged releases |
| `develop` | Integration, TestFlight builds |
| `feature/*` | Tính năng mới |
| `bugfix/*` | Sửa lỗi |
| `release/*` | Chuẩn bị release |
| `hotfix/*` | Sửa lỗi khẩn cấp trên production |

### Commit Convention

```
<type>[optional scope]: <description>

# Types: feat, fix, docs, style, refactor, perf, test, chore
# Ví dụ:
feat(profile): integrate photo upload to Firebase Storage
fix(auth): fix memory leak in LoginUseCase
```

### PR Process

- Tất cả thay đổi qua Pull Request
- Tối thiểu 1 approver
- Squash and Merge cho feature → develop
- Tham chiếu ticket: `[VM-123]`

---

## 7. Constants & Configuration

### App Constants

```swift
// Firebase Collections
Constants.Firebase.usersCollection      = "users"
Constants.Firebase.profilesCollection   = "profiles"
Constants.Firebase.matchesCollection    = "matches"
Constants.Firebase.swipesCollection     = "swipes"
Constants.Firebase.messagesSubcollection = "messages"

// App Limits
Constants.App.maxPhotos          = 6
Constants.App.minAge             = 18
Constants.App.maxAge             = 100
Constants.App.defaultDiscoverLimit = 20
Constants.App.maxBioLength       = 500
Constants.App.defaultDistance     = 50
Constants.App.maxDistance         = 160
```

### Logger Categories

```swift
AppLogger.auth      // Authentication events
AppLogger.network   // Network requests/responses
AppLogger.ui        // UI events
AppLogger.data      // Data operations
AppLogger.general   // General logs
```

---

## 8. Troubleshooting

| Vấn đề | Giải pháp |
|--------|-----------|
| SPM resolve failed | File → Packages → Reset Package Caches |
| Firebase crash on launch | Kiểm tra GoogleService-Info.plist |
| Previews not working | Build target trước, ensure DEBUG compilation condition |
| Push notifications not working | Kiểm tra FCM token, APN certificate |
