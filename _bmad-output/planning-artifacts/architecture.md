---
type: architecture
project: VietMatch
version: 1.0
date: 2026-04-01
---

# VietMatch — Architecture Decision Document

## 1. Tóm Tắt Kiến Trúc

VietMatch sử dụng **Clean Architecture + MVVM-C** trên iOS với Firebase làm backend. Ba layer chính tách biệt hoàn toàn qua dependency inversion:

```
Presentation Layer  →  Domain Layer  ←  Data Layer
(SwiftUI + MVVM-C)    (Pure Swift)       (Firebase)
```

**Starter Template:** Dự án đã bootstrap từ kiến trúc nền này — không dùng external starter template. XcodeGen (`project.yml`) dùng để quản lý project configuration.

---

## 2. Layer Architecture

### 2.1 Domain Layer (Tầng Cao Nhất — Không Phụ Thuộc)

**Trách nhiệm:** Business logic, business rules, abstractions
**Phụ thuộc:** Không có — hoàn toàn độc lập với Firebase, SwiftUI

**Thành phần:**

| Loại | Ví dụ | Mô tả |
|------|-------|-------|
| Entities | `User`, `Profile`, `Match`, `Message`, `Conversation`, `Swipe` | Domain models (pure Swift structs) |
| Repository Protocols | `AuthRepositoryProtocol`, `ProfileRepositoryProtocol`, `MatchRepositoryProtocol`, `ChatRepositoryProtocol` | Abstractions — Data layer implements |
| Use Cases | 12 use cases (xem mục 4) | Business logic, validation, orchestration |

**Nguyên tắc Use Case:**
- Mỗi UseCase chỉ làm một việc (Single Responsibility)
- Inject Protocol, không inject Implementation
- Throw typed errors (AuthError, ChatError, APIError)
- Không có UI code, không import SwiftUI

### 2.2 Data Layer (Tầng Thấp Nhất — Firebase)

**Trách nhiệm:** Firebase integration, DTOs, Repository implementations
**Phụ thuộc:** Domain protocols (implement chúng)

**Thành phần:**

| Loại | Ví dụ | Mô tả |
|------|-------|-------|
| Firebase Services | `FirebaseAuthService`, `FirestoreService`, `FirebaseStorageService`, `FCMService` | Wrappers cho Firebase SDK |
| Repository Implementations | `AuthRepository`, `ProfileRepository`, `MatchRepository`, `ChatRepository` | Implement Domain protocols |
| DTOs | `UserDTO`, `ProfileDTO`, `MatchDTO`, `MessageDTO` | Codable structs cho Firestore (snake_case) |
| Mappers | `UserMapper`, `MessageMapper` | DTO ↔ Domain entity conversion |
| Local | `UserDefaultsService` | Onboarding state, userId, FCM token |

**Quy tắc DTO:**
- Tất cả DTOs conform `Codable` với custom `CodingKeys` (snake_case)
- Timestamp: `Double` trong DTO → `Date` trong Entity
- Enum: `String` trong DTO → typed Enum trong Entity
- Location: flat `latitude`/`longitude` trong DTO → `Location` struct trong Entity

### 2.3 Presentation Layer (UI + Navigation)

**Trách nhiệm:** SwiftUI Views, ViewModels, Coordinators
**Phụ thuộc:** Domain (inject UseCases)

**Thành phần:**

| Loại | Ví dụ | Mô tả |
|------|-------|-------|
| Views | `LoginView`, `DiscoverView`, `ChatView` | SwiftUI views, zero business logic |
| ViewModels | `LoginViewModel`, `DiscoverViewModel` | @MainActor, @Published state |
| Coordinators | `AppCoordinator`, `AuthCoordinator`, `MainTabCoordinator` | Navigation graph management |
| Components | `SwipeCardStack`, `GradientButton`, `ProfileImageView` | Reusable UI |
| Design System | `VietMatchColors`, `VietMatchTypography`, `VietMatchSpacing` | Design tokens |

---

## 3. Dependency Injection (Swinject)

### AppContainer Structure

```swift
AppContainer
├── DataAssembly        // Firebase services + Repository implementations
├── DomainAssembly      // 13 Use Cases (inject repositories)
└── PresentationAssembly // Coordinators + ViewModels (inject use cases)
```

### Quy Tắc Đăng Ký

- **DataAssembly:** Đăng ký services và repositories. FirestoreService, StorageService là `shared` (singleton).
- **DomainAssembly:** Đăng ký Use Cases, inject repository protocols.
- **PresentationAssembly:** Đăng ký Coordinators và ViewModels, inject use cases.

### Vấn Đề Đã Biết

- `resolver.resolve(...)!` force-unwrap trong PresentationAssembly — cần thay bằng `precondition` với message rõ ràng (DI-1)
- ViewModels được tạo mới mỗi lần resolve — lifecycle phải được quản lý cẩn thận khi user logout/login

---

## 4. Use Cases (13 Use Cases)

| Nhóm | Use Case | Validation | Throws |
|------|----------|------------|--------|
| **Auth** | `LoginUseCase` | email không rỗng, password >= 6 chars | `AuthError` |
| | `RegisterUseCase` | email, password, displayName không rỗng | `AuthError` |
| | `LogoutUseCase` | - | `AuthError` |
| | `DeleteAccountUseCase` | - | `AuthError` |
| **Profile** | `GetProfileUseCase` | - | `APIError` |
| | `UpdateProfileUseCase` | - | `APIError` |
| | `UploadPhotoUseCase` | - | `APIError` |
| | `DeletePhotoUseCase` | - | `APIError` |
| **Matching** | `SwipeUseCase` | - | `APIError` |
| | `GetMatchesUseCase` | - | `APIError` |
| | `GetDiscoverProfilesUseCase` | - | `APIError` |
| **Chat** | `SendMessageUseCase` | message.content không rỗng (trimmed) | `ChatError` |
| | `GetMessagesUseCase` | - | `ChatError` |
| | `GetConversationsUseCase` | - | `ChatError` |

---

## 5. Navigation (Coordinator Pattern)

### Phân Cấp

```
AppCoordinator (Root — Auth state machine)
│
├── [Unauthenticated] → AuthCoordinator
│   ├── LoginView
│   ├── RegisterView
│   └── ForgotPasswordView
│
├── [Authenticated, not onboarded] → OnboardingView (4 steps inline)
│
└── [Authenticated + onboarded] → MainTabCoordinator
    ├── Tab 1: DiscoverCoordinator
    │   ├── DiscoverView
    │   └── ProfileDetailView
    ├── Tab 2: MatchesView
    ├── Tab 3: ChatCoordinator
    │   ├── ConversationsView
    │   └── ChatView(matchId)
    └── Tab 4: ProfileCoordinator
        ├── ProfileView
        ├── EditProfileView
        └── SettingsView
```

### AppCoordinator Auth State Machine

AppCoordinator lắng nghe `AuthRepository.currentUser` Publisher và routing theo:

| Auth State | Route |
|-----------|-------|
| `nil` (not authenticated) | AuthCoordinator |
| `user.profileCompleted == false` | OnboardingView |
| `user.profileCompleted == true` | MainTabCoordinator |

### Quy Tắc Navigation

- Coordinator sở hữu NavigationStack/TabView
- View gọi `coordinator.navigate(to:)`, không tự push/present
- Deep link (từ push notification) qua AppCoordinator
- Match alert → navigate to ChatView phải đi qua ChatCoordinator

---

## 6. Auth Session Service (Kiến Trúc Bắt Buộc)

**Vấn đề hiện tại:** userId đang được lấy từ `UserDefaults` với fallback `?? ""`, dẫn đến phantom userId.

**Giải pháp kiến trúc bắt buộc:**

```swift
protocol AuthSessionServiceProtocol {
    var currentUserId: String? { get }
    var currentUserIdPublisher: AnyPublisher<String?, Never> { get }
}
```

- Inject `AuthSessionServiceProtocol` vào Coordinators và ViewModels thay vì đọc UserDefaults trực tiếp
- Gate tất cả authenticated screens: chỉ hiển thị khi `currentUserId != nil`
- Cold start: Firebase `Auth.auth().currentUser` restore → re-persist userId qua AuthSessionService
- Logout → AuthSessionService publish `nil` → AppCoordinator route về AuthCoordinator

---

## 7. Async & Reactive Patterns

| Pattern | Khi nào dùng | Ví dụ |
|---------|-------------|-------|
| `async/await` | Tất cả UseCase methods, Repository one-shot operations | `loginUseCase.execute(email:password:)` |
| `Combine Publisher` | Real-time Firestore streams | `chatRepo.observeMessages(matchId:)` |
| `@Published` | ViewModel state cho SwiftUI binding | `@Published var isLoading: Bool` |
| `@MainActor` | Tất cả ViewModels — đảm bảo UI updates trên main thread | `@MainActor class LoginViewModel` |

### In-Flight Guard Pattern (Bắt Buộc)

```swift
// Pattern bắt buộc cho tất cả async actions trong ViewModels
func performAction() async {
    guard !isLoading else { return }
    isLoading = true
    defer { isLoading = false }
    // ... async work
}
```

---

## 8. Firebase Architecture

### Collections Schema

```
Firestore
├── users/{userId}          UserDTO: email, display_name, profile_completed, timestamps
├── profiles/{userId}       ProfileDTO: name, age, bio, gender, photos[], location, interests[]
├── matches/{matchId}       MatchDTO: user_id, matched_user_id, is_new, timestamps
│   └── messages/{msgId}    MessageDTO: sender_id, content, type, is_read, created_at
└── swipes/{swipeId}        swiper_id, swiped_user_id, direction, created_at
```

### Firebase Storage

```
photos/{userId}/{UUID}.jpg    // JPEG preferred, PNG fallback
```

### Match Detection Logic

```
SwipeUseCase.execute(swiperId, swipedUserId, direction: .like)
    → Save swipe to Firestore
    → Query: swipes where swiperId == swipedUserId AND direction == .like
    → If found: create Match record, return Match
    → If not found: return nil (no match yet)
```

---

## 9. Error Handling

| Error Type | Cases | Hiển thị |
|------------|-------|---------|
| `AuthError` | invalidCredentials, userNotFound, emailAlreadyInUse, weakPassword, networkError, unknown | Vietnamese alert |
| `ChatError` | emptyMessage, matchNotFound, sendFailed | Vietnamese toast/alert |
| `APIError` | networkError, serverError(Int), decodingError, unauthorized, notFound, unknown | Vietnamese alert |

**Nguyên tắc:**
- Firebase errors phải được map sang typed errors trước khi bubble up đến ViewModel
- ViewModel catch error → set `errorMessage: String?` → View hiển thị alert
- Không để Firebase `localizedDescription` tiếng Anh xuất hiện trong UI

---

## 10. Testing Architecture

### Mock Strategy

```swift
// Domain protocols → Mockable
class MockAuthRepository: AuthRepositoryProtocol {
    var loginResult: Result<User, AuthError> = .success(...)
    var loginCallCount: Int = 0
    func login(email:password:) async throws -> User { ... }
}
```

### Test Targets

| Target | Test Type | Layer |
|--------|-----------|-------|
| `VietMatchTests` | Unit Tests | Domain + Presentation |
| `VietMatchUITests` | UI Integration | Presentation (E2E flows) |

### Launch Arguments (UI Tests)

| Argument | Tác dụng |
|----------|---------|
| `--uitesting` | Enable mock injection |
| `--authenticated` | Skip auth screens |

---

## 11. XcodeGen Configuration

Dự án sử dụng `project.yml` (XcodeGen) để tạo `.xcodeproj`. **Tất cả file Swift mới phải được thêm vào `project.yml`** — không chỉnh sửa `.xcodeproj` trực tiếp.

Khi thêm file mới:
1. Tạo file `.swift`
2. Thêm vào `project.yml` dưới đúng group/target
3. Chạy `xcodegen generate`
4. Verify file xuất hiện trong Xcode project navigator

---

## 12. Quyết Định Kiến Trúc Quan Trọng

| Quyết định | Lựa chọn | Lý do |
|-----------|---------|-------|
| Backend | Firebase | All-in-one: Auth + DB + Storage + Push — giảm complexity |
| Architecture | Clean Architecture + MVVM-C | Testability, scalability, separation of concerns |
| Navigation | Coordinator | Decoupled từ SwiftUI NavigationStack, testable |
| DI | Swinject | Mature, supports assemblies pattern |
| Reactive | Combine (built-in) | Real-time streams không cần thêm dependency |
| Concurrency | async/await (Swift 5.5+) | Modern, readable, composable |
| Image loading | Kingfisher | Async loading + memory/disk cache |
| Project config | XcodeGen | No merge conflicts trong .xcodeproj |
