# VietMatch - iOS Dating App Project Setup

## Context
Tạo codebase iOS cho app hẹn hò **VietMatch** (tham khảo Tinder) với kiến trúc MVVM + Clean Architecture, sử dụng Swift/SwiftUI, Swinject DI, Firebase backend, và Coordinator Pattern navigation.

---

## Tech Stack
- **Language:** Swift 5.9+, SwiftUI
- **iOS Target:** iOS 16+
- **Package Manager:** SPM
- **DI:** Swinject
- **Backend:** Firebase (Auth, Firestore, Storage, FCM)
- **Networking:** Alamofire
- **Image:** Kingfisher
- **Reactive:** Combine + async/await
- **Testing:** XCTest (Unit + UI)

---

## Project Structure (Clean Architecture Layers)

```
VietMatch/
├── VietMatch.xcodeproj
├── VietMatch/
│   ├── App/
│   │   ├── VietMatchApp.swift              # App entry point
│   │   ├── AppDelegate.swift               # Firebase setup
│   │   └── DI/
│   │       ├── AppContainer.swift          # Swinject root container
│   │       ├── DomainAssembly.swift        # Use cases registration
│   │       ├── DataAssembly.swift          # Repositories registration
│   │       └── PresentationAssembly.swift  # ViewModels registration
│   │
│   ├── Domain/                             # DOMAIN LAYER (innermost)
│   │   ├── Entities/
│   │   │   ├── User.swift
│   │   │   ├── Profile.swift
│   │   │   ├── Match.swift
│   │   │   ├── Message.swift
│   │   │   ├── Swipe.swift
│   │   │   └── Notification.swift
│   │   ├── UseCases/
│   │   │   ├── Auth/
│   │   │   │   ├── LoginUseCase.swift
│   │   │   │   ├── RegisterUseCase.swift
│   │   │   │   └── LogoutUseCase.swift
│   │   │   ├── Profile/
│   │   │   │   ├── GetProfileUseCase.swift
│   │   │   │   ├── UpdateProfileUseCase.swift
│   │   │   │   └── UploadPhotoUseCase.swift
│   │   │   ├── Matching/
│   │   │   │   ├── SwipeUseCase.swift
│   │   │   │   ├── GetDiscoverProfilesUseCase.swift
│   │   │   │   └── GetMatchesUseCase.swift
│   │   │   └── Chat/
│   │   │       ├── SendMessageUseCase.swift
│   │   │       ├── GetMessagesUseCase.swift
│   │   │       └── GetConversationsUseCase.swift
│   │   └── Repositories/                   # Protocol definitions only
│   │       ├── AuthRepositoryProtocol.swift
│   │       ├── ProfileRepositoryProtocol.swift
│   │       ├── MatchRepositoryProtocol.swift
│   │       └── ChatRepositoryProtocol.swift
│   │
│   ├── Data/                               # DATA LAYER
│   │   ├── Repositories/                   # Protocol implementations
│   │   │   ├── AuthRepository.swift
│   │   │   ├── ProfileRepository.swift
│   │   │   ├── MatchRepository.swift
│   │   │   └── ChatRepository.swift
│   │   ├── DataSources/
│   │   │   ├── Remote/
│   │   │   │   ├── FirebaseAuthService.swift
│   │   │   │   ├── FirestoreService.swift
│   │   │   │   ├── FirebaseStorageService.swift
│   │   │   │   └── FCMService.swift
│   │   │   └── Local/
│   │   │       └── UserDefaultsService.swift
│   │   ├── DTOs/
│   │   │   ├── UserDTO.swift
│   │   │   ├── ProfileDTO.swift
│   │   │   ├── MessageDTO.swift
│   │   │   └── MatchDTO.swift
│   │   └── Mappers/
│   │       ├── UserMapper.swift
│   │       └── MessageMapper.swift
│   │
│   ├── Presentation/                       # PRESENTATION LAYER
│   │   ├── Navigation/
│   │   │   ├── AppCoordinator.swift        # Root coordinator
│   │   │   ├── AuthCoordinator.swift
│   │   │   ├── MainTabCoordinator.swift
│   │   │   ├── DiscoverCoordinator.swift
│   │   │   ├── ChatCoordinator.swift
│   │   │   ├── ProfileCoordinator.swift
│   │   │   └── Coordinator.swift           # Base protocol
│   │   ├── Screens/
│   │   │   ├── Auth/
│   │   │   │   ├── LoginView.swift
│   │   │   │   ├── LoginViewModel.swift
│   │   │   │   ├── RegisterView.swift
│   │   │   │   └── RegisterViewModel.swift
│   │   │   ├── Onboarding/
│   │   │   │   ├── OnboardingView.swift
│   │   │   │   ├── OnboardingViewModel.swift
│   │   │   │   ├── ProfileSetupView.swift
│   │   │   │   └── PhotoUploadView.swift
│   │   │   ├── Discover/
│   │   │   │   ├── DiscoverView.swift      # Swipe card UI (Tinder-style)
│   │   │   │   ├── DiscoverViewModel.swift
│   │   │   │   └── CardView.swift          # Swipeable card component
│   │   │   ├── Matches/
│   │   │   │   ├── MatchesView.swift
│   │   │   │   ├── MatchesViewModel.swift
│   │   │   │   └── MatchCellView.swift
│   │   │   ├── Chat/
│   │   │   │   ├── ConversationsView.swift
│   │   │   │   ├── ConversationsViewModel.swift
│   │   │   │   ├── ChatView.swift
│   │   │   │   ├── ChatViewModel.swift
│   │   │   │   └── MessageBubbleView.swift
│   │   │   ├── Profile/
│   │   │   │   ├── ProfileView.swift
│   │   │   │   ├── ProfileViewModel.swift
│   │   │   │   └── EditProfileView.swift
│   │   │   └── Settings/
│   │   │       ├── SettingsView.swift
│   │   │       └── SettingsViewModel.swift
│   │   └── Components/                     # Reusable UI
│   │       ├── SwipeCardStack.swift
│   │       ├── GradientButton.swift
│   │       ├── ProfileImageView.swift
│   │       ├── LoadingView.swift
│   │       └── EmptyStateView.swift
│   │
│   ├── DesignSystem/                       # VietMatch brand
│   │   ├── Colors.swift                    # Brand colors (gradient pink/red like Tinder)
│   │   ├── Typography.swift                # Font styles
│   │   ├── Spacing.swift                   # Layout constants
│   │   └── Assets.xcassets/                # App icons, images
│   │
│   └── Core/                               # Shared utilities
│       ├── Extensions/
│       │   ├── View+Extensions.swift
│       │   ├── Color+Extensions.swift
│       │   └── String+Extensions.swift
│       ├── Networking/
│       │   ├── NetworkMonitor.swift
│       │   └── APIError.swift
│       └── Utils/
│           ├── Logger.swift
│           └── Constants.swift
│
├── VietMatchTests/
│   ├── Domain/
│   │   └── UseCases/
│   │       ├── LoginUseCaseTests.swift
│   │       └── SwipeUseCaseTests.swift
│   ├── Data/
│   │   └── Repositories/
│   │       └── AuthRepositoryTests.swift
│   ├── Presentation/
│   │   └── ViewModels/
│   │       ├── LoginViewModelTests.swift
│   │       └── DiscoverViewModelTests.swift
│   └── Mocks/
│       ├── MockAuthRepository.swift
│       ├── MockProfileRepository.swift
│       └── MockMatchRepository.swift
│
└── VietMatchUITests/
    ├── AuthFlowUITests.swift
    └── DiscoverFlowUITests.swift
```

---

## Implementation Steps

### Step 1: Project Skeleton
- Tạo folder structure đầy đủ theo Clean Architecture
- Setup `VietMatchApp.swift` entry point
- Tạo `Package.swift` dependencies (Firebase, Alamofire, Kingfisher, Swinject)

### Step 2: Domain Layer
- Định nghĩa Entities (User, Profile, Match, Message, Swipe)
- Tạo Repository protocols
- Implement Use Cases

### Step 3: Data Layer
- Firebase services (Auth, Firestore, Storage)
- Repository implementations
- DTOs và Mappers

### Step 4: DI Container (Swinject)
- `AppContainer` root container
- Assembly modules: Domain, Data, Presentation
- Environment-based injection (mock vs production)

### Step 5: Navigation (Coordinator Pattern)
- `Coordinator` base protocol
- `AppCoordinator` → AuthCoordinator / MainTabCoordinator
- Deep link support ready

### Step 6: Presentation Layer
- Auth screens (Login, Register)
- Onboarding flow (Profile setup, Photo upload)
- Discover screen (Tinder-style swipe cards)
- Matches & Chat screens
- Profile & Settings screens
- Reusable components

### Step 7: Design System
- Brand colors (gradient pink/coral like Tinder)
- Typography scale
- Spacing/layout tokens
- Custom components (GradientButton, SwipeCardStack)

### Step 8: Testing Setup
- Unit test targets with mock protocols
- UI test targets for critical flows
- Test DI assembly with mock implementations

---

## Key Architecture Decisions

1. **Clean Architecture layers**: Domain → Data → Presentation. Domain has zero dependencies.
2. **Coordinator Pattern**: Navigation logic tách khỏi Views, dùng NavigationStack (iOS 16+).
3. **Swinject Assemblies**: Mỗi layer có Assembly riêng, dễ swap mock/production.
4. **Protocol-oriented**: Tất cả repositories và services đều có protocol → dễ test và mock.
5. **Combine + async/await**: ViewModels dùng `@Published` + async/await cho Firebase calls.

---

## Verification
1. Project build thành công (⌘+B)
2. App launch hiển thị Auth flow
3. Navigate qua các tab (Discover, Matches, Chat, Profile)
4. Unit tests pass
5. DI container resolve tất cả dependencies không crash
