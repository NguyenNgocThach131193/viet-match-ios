# VietMatch - Phân Tích Cấu Trúc Thư Mục

> Ngày tạo: 2026-03-26 | Scan Level: Deep | Loại: Mobile (iOS Native)

---

## Cấu Trúc Tổng Quan

```
VietMatch/                          # [ENTRY] Ứng dụng iOS chính
├── App/                            # Khởi tạo ứng dụng & Dependency Injection
│   ├── VietMatchApp.swift          # [ENTRY POINT] SwiftUI App entry
│   ├── AppDelegate.swift           # Firebase configure, Push notifications
│   └── DI/                         # Swinject Dependency Injection
│       ├── AppContainer.swift      # Container chính, đăng ký tất cả assemblies
│       ├── DataAssembly.swift      # Đăng ký Firebase services & repositories
│       ├── DomainAssembly.swift    # Đăng ký 12 use cases
│       └── PresentationAssembly.swift  # Đăng ký coordinators & view models
│
├── Core/                           # Tiện ích dùng chung toàn ứng dụng
│   ├── Extensions/
│   │   ├── Color+Extensions.swift  # Custom color accessors (vmPrimary, vmBackground)
│   │   ├── String+Extensions.swift # Email/password validation, timeAgo (vi_VN)
│   │   └── View+Extensions.swift   # Button styles, card shadow, hideKeyboard
│   ├── Networking/
│   │   ├── APIError.swift          # Enum lỗi API (localized Vietnamese)
│   │   └── NetworkMonitor.swift    # Singleton theo dõi kết nối mạng (NWPathMonitor)
│   └── Utils/
│       ├── Constants.swift         # Firebase collection names, app limits
│       └── Logger.swift            # AppLogger categories (auth, network, ui, data)
│
├── DesignSystem/                   # Design tokens thống nhất
│   ├── Colors.swift                # VietMatchColors: primary #FE3C72, gradients
│   ├── Typography.swift            # VietMatchTypography: SF Rounded, 13 styles
│   └── Spacing.swift               # VietMatchSpacing: xxs(2) → xxxl(48), avatar sizes
│
├── Domain/                         # Business logic layer (0 dependencies)
│   ├── Entities/                   # Domain models
│   │   ├── User.swift              # User: id, email, displayName, profileCompleted
│   │   ├── Profile.swift           # Profile: name, age, bio, gender, photos, location
│   │   ├── Match.swift             # Match: userId, matchedUserId, matchedProfile
│   │   ├── Message.swift           # Message: content, type, Conversation struct
│   │   ├── Swipe.swift             # Swipe: direction (like/dislike/superLike)
│   │   └── Notification.swift      # AppNotification: type, title, body
│   ├── Repositories/               # Protocol definitions (abstractions)
│   │   ├── AuthRepositoryProtocol.swift    # Login, register, social auth, currentUser Publisher
│   │   ├── ProfileRepositoryProtocol.swift # CRUD profile, upload/delete photo, location
│   │   ├── MatchRepositoryProtocol.swift   # Swipe, matches, discover, observe real-time
│   │   └── ChatRepositoryProtocol.swift    # Send/get messages, conversations, observe
│   └── UseCases/                   # 12 use cases với business validation
│       ├── Auth/                   # LoginUseCase, RegisterUseCase, LogoutUseCase
│       ├── Chat/                   # SendMessage, GetMessages, GetConversations
│       ├── Matching/               # Swipe, GetMatches, GetDiscoverProfiles
│       └── Profile/                # GetProfile, UpdateProfile, UploadPhoto
│
├── Data/                           # Data access layer
│   ├── DTOs/                       # Data Transfer Objects (Codable, snake_case)
│   │   ├── UserDTO.swift           # UserDTO ↔ User mapping
│   │   ├── ProfileDTO.swift        # ProfileDTO ↔ Profile mapping (with Location)
│   │   ├── MatchDTO.swift          # MatchDTO ↔ Match mapping
│   │   └── MessageDTO.swift        # MessageDTO ↔ Message mapping
│   ├── Mappers/
│   │   ├── UserMapper.swift        # UserDTO ↔ User conversion
│   │   └── MessageMapper.swift     # MessageDTO ↔ Message conversion
│   ├── Repositories/               # Protocol implementations
│   │   ├── AuthRepository.swift    # Firebase Auth + Firestore "users" collection
│   │   ├── ProfileRepository.swift # Firestore "profiles" + Firebase Storage
│   │   ├── MatchRepository.swift   # Firestore "swipes", "matches", "profiles"
│   │   └── ChatRepository.swift    # Firestore "matches/{id}/messages" subcollection
│   └── DataSources/
│       ├── Remote/
│       │   ├── FirebaseAuthService.swift     # Email/password, Google, Apple sign-in
│       │   ├── FirestoreService.swift        # Generic CRUD + real-time observers
│       │   ├── FirebaseStorageService.swift  # Image upload/delete (photos/{userId})
│       │   └── FCMService.swift              # Push notifications, topic subscription
│       └── Local/
│           └── UserDefaultsService.swift     # Onboarding state, userId, FCM token
│
├── Presentation/                   # UI layer
│   ├── Navigation/                 # Coordinator pattern
│   │   ├── Coordinator.swift       # Base Coordinator protocol
│   │   ├── AppCoordinator.swift    # [ROOT] Auth state → route decision
│   │   ├── AuthCoordinator.swift   # Login ↔ Register ↔ ForgotPassword
│   │   ├── MainTabCoordinator.swift # 4 tabs: Discover, Matches, Chat, Profile
│   │   ├── DiscoverCoordinator.swift # Discover → ProfileDetail
│   │   ├── ChatCoordinator.swift   # Conversations → Chat(matchId)
│   │   └── ProfileCoordinator.swift # Profile → EditProfile → Settings
│   ├── Components/                 # Reusable UI components
│   │   ├── SwipeCardStack.swift    # Generic card stack with 3D scale effect
│   │   ├── GradientButton.swift    # Primary action button with gradient
│   │   ├── ProfileImageView.swift  # Circle avatar with Kingfisher loading
│   │   ├── LoadingView.swift       # Spinner + localized message
│   │   └── EmptyStateView.swift    # Icon + title + message + optional action
│   └── Screens/                    # Feature screens (View + ViewModel)
│       ├── Auth/                   # LoginView/VM, RegisterView/VM
│       ├── Onboarding/             # OnboardingView/VM, ProfileSetup, PhotoUpload (4 steps)
│       ├── Discover/               # DiscoverView/VM, CardView (photo carousel + swipe)
│       ├── Matches/                # MatchesView/VM, MatchCellView (compact/full)
│       ├── Chat/                   # ChatView/VM, ConversationsView/VM, MessageBubble
│       ├── Profile/                # ProfileView/VM, EditProfileView
│       └── Settings/               # SettingsView/VM (preferences, account)
│
VietMatchTests/                     # Unit Tests
├── Data/Repositories/
│   └── AuthRepositoryTests.swift   # DTO ↔ Domain mapping tests
├── Domain/UseCases/
│   ├── LoginUseCaseTests.swift     # Auth validation & error handling
│   └── SwipeUseCaseTests.swift     # Swipe logic & match detection
├── Presentation/ViewModels/
│   ├── LoginViewModelTests.swift   # Form validation & login flow
│   └── DiscoverViewModelTests.swift # Profile loading & state management
└── Mocks/
    ├── MockAuthRepository.swift    # Call counting + configurable results
    ├── MockMatchRepository.swift   # Configurable swipe/match/discover results
    └── MockProfileRepository.swift # Configurable profile/photo results

VietMatchUITests/                   # UI Integration Tests
├── AuthFlowUITests.swift           # Login screen elements, navigation to register
└── DiscoverFlowUITests.swift       # Tab bar existence, all 4 tabs verified
```

---

## Thư Mục Quan Trọng

| Thư mục | Mục đích | Số files |
|---------|---------|----------|
| `VietMatch/Domain/` | Business logic, entities, protocols | 16 files |
| `VietMatch/Data/` | Firebase services, repositories, DTOs | 14 files |
| `VietMatch/Presentation/` | Views, ViewModels, Coordinators | 28 files |
| `VietMatch/Core/` | Extensions, networking, utils | 6 files |
| `VietMatch/DesignSystem/` | Design tokens | 3 files |
| `VietMatch/App/` | Entry point, DI container | 5 files |
| `VietMatchTests/` | Unit tests + mocks | 8 files |
| `VietMatchUITests/` | UI tests | 2 files |

---

## Entry Points

| Entry Point | File | Mô tả |
|-------------|------|-------|
| App Entry | `VietMatch/App/VietMatchApp.swift` | SwiftUI @main, khởi tạo AppCoordinator |
| App Delegate | `VietMatch/App/AppDelegate.swift` | Firebase.configure(), FCM setup |
| DI Container | `VietMatch/App/DI/AppContainer.swift` | Swinject container registration |
| Root Navigation | `Presentation/Navigation/AppCoordinator.swift` | Auth state routing |
