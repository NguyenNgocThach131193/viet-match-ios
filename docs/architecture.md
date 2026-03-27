# VietMatch - Tài Liệu Kiến Trúc

> Ngày tạo: 2026-03-26 | Scan Level: Deep | Loại: Mobile (iOS Native)

---

## 1. Tóm Tắt

VietMatch là ứng dụng hẹn hò iOS được xây dựng theo kiến trúc **Clean Architecture + MVVM-C**, sử dụng **Firebase** làm backend. Ứng dụng chia thành 3 layer chính (Presentation, Domain, Data) với nguyên tắc dependency inversion thông qua **Swinject**.

---

## 2. Kiến Trúc Pattern

### Clean Architecture (3 Layers)

Sắp xếp từ **High-level** (ít thay đổi, gần business rules) đến **Low-level** (thay đổi thường xuyên, gần infrastructure):

| Level | Layer | Trách nhiệm | Dependencies |
|-------|-------|-------------|-------------|
| Highest | **Domain** | Business logic (UseCases), Entities, Repository protocols | Không có — layer độc lập nhất |
| Mid | **Presentation** | UI (SwiftUI), ViewModels, Navigation (Coordinators) | Domain |
| Lowest | **Data** | Firebase services, Repository implementations, DTOs, Mappers | Domain (protocols) |

> **Nguyên tắc DIP:** Domain (high-level) định nghĩa protocols. Data (low-level) implements chúng. Đổi Firebase → Supabase chỉ sửa Data layer — Domain và Presentation không thay đổi.

```mermaid
graph TB
    subgraph Presentation ["Presentation Layer"]
        Views["Views - SwiftUI"]
        ViewModels["ViewModels - ObservableObject"]
        Coordinators["Coordinators - Navigation"]
        Components["Reusable Components"]
    end

    subgraph Domain ["Domain Layer"]
        UseCases["Use Cases - Business Logic"]
        Entities["Entities - Models"]
        RepoProtocols["Repository Protocols"]
    end

    subgraph Data ["Data Layer"]
        Repositories["Repository Implementations"]
        DTOs["DTOs + Mappers"]
        Remote["Firebase Services"]
        Local["UserDefaults"]
    end

    Views --> ViewModels
    ViewModels --> UseCases
    Coordinators --> Views
    UseCases --> RepoProtocols
    UseCases --> Entities
    Repositories -.->|implements| RepoProtocols
    Repositories --> DTOs
    DTOs --> Remote
    DTOs --> Local
    DTOs -->|map to| Entities

    style Presentation fill:#FFE0E6,stroke:#FE3C72,stroke-width:2px
    style Domain fill:#FFF3E0,stroke:#FF8A65,stroke-width:2px
    style Data fill:#E3F2FD,stroke:#2196F3,stroke-width:2px
```

### MVVM-C Pattern

```
View (SwiftUI) → ViewModel (@MainActor, @Published) → UseCase → Repository → Firebase
     ↑
Coordinator (Navigation, NavigationStack)
```

#### Data Flow (Ví dụ: Swipe Right)

```mermaid
sequenceDiagram
    participant V as View - SwiftUI
    participant VM as ViewModel
    participant UC as UseCase
    participant R as Repository
    participant DS as Firebase Service

    V->>VM: User action - swipe right
    VM->>UC: swipeUseCase.execute
    UC->>R: matchRepository.swipe
    R->>DS: firestoreService.setDocument
    DS-->>R: Success / Match found
    R-->>UC: Match result
    UC-->>VM: Match result
    VM-->>V: Published update showMatchAlert = true
    V->>V: Re-render UI
```

### Dependency Flow

```
Presentation → Domain ← Data
     ↓              ↑
   Swinject Container (DI)
```

---

## 3. Dependency Injection (Swinject)

### AppContainer

```swift
AppContainer
├── DataAssembly        // Firebase services + Repository implementations
├── DomainAssembly      // 12 Use Cases (inject repositories)
└── PresentationAssembly // Coordinators + ViewModels (inject use cases)
```

### Đăng Ký

| Assembly | Đăng ký | Số lượng |
|----------|---------|---------|
| **DataAssembly** | FirebaseAuthService, FirestoreService, FirebaseStorageService, FCMService, UserDefaultsService, 4 Repositories | 9 |
| **DomainAssembly** | LoginUseCase, RegisterUseCase, LogoutUseCase, GetProfileUseCase, UpdateProfileUseCase, UploadPhotoUseCase, SwipeUseCase, GetMatchesUseCase, GetDiscoverProfilesUseCase, SendMessageUseCase, GetMessagesUseCase, GetConversationsUseCase | 12 |
| **PresentationAssembly** | AppCoordinator, 6 ViewModels (Login, Register, Onboarding, Discover, Matches, Chat, Conversations, Profile, Settings) | ~10 |

```mermaid
graph LR
    subgraph DI ["AppContainer - Swinject"]
        DataAssembly["DataAssembly<br/>--------<br/>FirebaseAuthService<br/>FirestoreService<br/>StorageService<br/>FCMService<br/>UserDefaultsService<br/>--------<br/>AuthRepository<br/>ProfileRepository<br/>MatchRepository<br/>ChatRepository"]

        DomainAssembly["DomainAssembly<br/>--------<br/>LoginUseCase<br/>RegisterUseCase<br/>LogoutUseCase<br/>GetProfileUseCase<br/>UpdateProfileUseCase<br/>UploadPhotoUseCase<br/>SwipeUseCase<br/>GetMatchesUseCase<br/>GetDiscoverProfilesUseCase<br/>SendMessageUseCase<br/>GetMessagesUseCase<br/>GetConversationsUseCase"]

        PresentationAssembly["PresentationAssembly<br/>--------<br/>AppCoordinator<br/>LoginViewModel<br/>RegisterViewModel<br/>OnboardingViewModel<br/>DiscoverViewModel<br/>MatchesViewModel<br/>ChatViewModel<br/>ConversationsViewModel<br/>ProfileViewModel<br/>SettingsViewModel"]
    end

    DataAssembly -->|provides repos| DomainAssembly
    DomainAssembly -->|provides use cases| PresentationAssembly

    style DI fill:#F3E5F5,stroke:#9C27B0,stroke-width:2px
```

---

## 4. Navigation (Coordinator Pattern)

### Phân Cấp Coordinator

```
AppCoordinator (Root)
│
├── [Chưa xác thực] → AuthCoordinator
│   ├── LoginView
│   ├── RegisterView
│   └── ForgotPasswordView
│
├── [Chưa onboard] → OnboardingView (4 steps)
│   ├── Step 1: ProfileSetupView (name, age, bio)
│   ├── Step 2: Gender selection
│   ├── Step 3: PhotoUploadView (max 6 photos)
│   └── Step 4: Interests selection (15 options)
│
└── [Đã xác thực] → MainTabCoordinator (4 tabs)
    ├── Tab 1: DiscoverCoordinator
    │   ├── DiscoverView (swipe cards)
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

### Route Enums

| Coordinator | Routes |
|-------------|--------|
| AppCoordinator | login, register, onboarding, mainTab, profileDetail, chat, editProfile, settings |
| AuthCoordinator | login, register, forgotPassword |
| DiscoverCoordinator | discover, profileDetail(profileId) |
| ChatCoordinator | conversations, chat(matchId) |
| ProfileCoordinator | profile, editProfile, settings |

```mermaid
graph TD
    App["VietMatchApp"] --> AppCoord["AppCoordinator"]

    AppCoord -->|not authenticated| AuthCoord["AuthCoordinator"]
    AppCoord -->|not onboarded| Onboarding["OnboardingView"]
    AppCoord -->|authenticated| MainTab["MainTabCoordinator"]

    AuthCoord --> Login["LoginView"]
    AuthCoord --> Register["RegisterView"]
    AuthCoord --> ForgotPW["ForgotPasswordView"]

    Onboarding --> Step1["ProfileSetup"]
    Onboarding --> Step2["GenderSelection"]
    Onboarding --> Step3["PhotoUpload"]
    Onboarding --> Step4["Interests"]

    MainTab --> DiscoverCoord["DiscoverCoordinator"]
    MainTab --> MatchesTab["MatchesView"]
    MainTab --> ChatCoord["ChatCoordinator"]
    MainTab --> ProfileCoord["ProfileCoordinator"]

    DiscoverCoord --> Discover["DiscoverView - Swipe Cards"]
    DiscoverCoord --> ProfileDetail["ProfileDetailView"]

    ChatCoord --> Conversations["ConversationsView"]
    ChatCoord --> Chat["ChatView - Messages"]

    ProfileCoord --> Profile["ProfileView"]
    ProfileCoord --> EditProfile["EditProfileView"]
    ProfileCoord --> Settings["SettingsView"]

    style AppCoord fill:#FE3C72,color:#fff,stroke:#E91E63
    style MainTab fill:#FF8A65,color:#fff,stroke:#FF6B6B
    style AuthCoord fill:#2196F3,color:#fff,stroke:#1976D2
    style DiscoverCoord fill:#4CAF50,color:#fff,stroke:#388E3C
    style ChatCoord fill:#9C27B0,color:#fff,stroke:#7B1FA2
    style ProfileCoord fill:#FF9800,color:#fff,stroke:#F57C00
```

---

## 5. Domain Layer

### Entities

| Entity | Thuộc tính chính | Enums liên quan |
|--------|-----------------|----------------|
| **User** | id, email, displayName, profileCompleted, createdAt, lastActiveAt | - |
| **Profile** | id, name, age, bio, gender, interestedIn, photos, location, interests, jobTitle, company, school, distancePreference, ageRange | Gender (male/female/other) |
| **Match** | id, userId, matchedUserId, matchedProfile, createdAt, lastMessageAt, isNew | - |
| **Message** | id, matchId, senderId, content, type, createdAt, isRead | MessageType (text/image/gif) |
| **Conversation** | id, match, lastMessage, unreadCount | - |
| **Swipe** | id, swiperId, swipedUserId, direction, createdAt | SwipeDirection (like/dislike/superLike) |
| **AppNotification** | id, userId, type, title, body, data, isRead | NotificationType (newMatch/newMessage/superLike/profileView) |

### Repository Protocols

| Protocol | Phương thức | Real-time |
|----------|------------|-----------|
| **AuthRepositoryProtocol** | login, register, loginWithGoogle, loginWithApple, logout, resetPassword, deleteAccount | currentUser Publisher |
| **ProfileRepositoryProtocol** | getProfile, updateProfile, uploadPhoto, deletePhoto, updateLocation | - |
| **MatchRepositoryProtocol** | swipe, getMatches, getDiscoverProfiles, unmatch | observeMatches Publisher |
| **ChatRepositoryProtocol** | sendMessage, getMessages, getConversations, markAsRead | observeMessages, observeConversations Publishers |

### Use Cases (12)

| Nhóm | Use Cases | Validation |
|------|-----------|------------|
| **Auth** | LoginUseCase, RegisterUseCase, LogoutUseCase | Email/password not empty, password >= 6 chars |
| **Profile** | GetProfileUseCase, UpdateProfileUseCase, UploadPhotoUseCase | - |
| **Matching** | SwipeUseCase, GetMatchesUseCase, GetDiscoverProfilesUseCase | - |
| **Chat** | SendMessageUseCase, GetMessagesUseCase, GetConversationsUseCase | Message not empty (trimmed) |

---

## 6. Data Layer

### Firebase Services

| Service | Firebase Product | Chức năng |
|---------|-----------------|-----------|
| **FirebaseAuthService** | Firebase Auth | Email/password, Google, Apple sign-in |
| **FirestoreService** | Cloud Firestore | Generic CRUD, real-time observers, filters |
| **FirebaseStorageService** | Firebase Storage | Upload/delete images (JPEG, path: photos/{userId}/{UUID}.jpg) |
| **FCMService** | Cloud Messaging | Push permissions, token, topic subscribe |
| **UserDefaultsService** | UserDefaults | Onboarding state, userId, FCM token, last refresh |

```mermaid
graph TB
    subgraph Firebase ["Firebase Backend"]
        Auth["Firebase Auth<br/>--------<br/>Email/Password<br/>Google Sign-In<br/>Apple Sign-In"]

        Firestore["Cloud Firestore<br/>--------<br/>users/<br/>profiles/<br/>matches/<br/>matches/messages/<br/>swipes/"]

        Storage["Firebase Storage<br/>--------<br/>photos/userId/"]

        FCM["Cloud Messaging<br/>--------<br/>New Match<br/>New Message<br/>Super Like"]
    end

    subgraph Services ["Swift Services"]
        AuthSvc["FirebaseAuthService"]
        FirestoreSvc["FirestoreService"]
        StorageSvc["FirebaseStorageService"]
        FCMSvc["FCMService"]
    end

    AuthSvc --> Auth
    FirestoreSvc --> Firestore
    StorageSvc --> Storage
    FCMSvc --> FCM

    style Firebase fill:#FFF8E1,stroke:#FFA000,stroke-width:2px
    style Services fill:#E8F5E9,stroke:#4CAF50,stroke-width:2px
```

### Firestore Collections

```
Firestore
├── users/                  # Thông tin tài khoản
│   └── {userId}            # UserDTO: email, display_name, profile_completed, created_at
│
├── profiles/               # Hồ sơ chi tiết
│   └── {userId}            # ProfileDTO: name, age, bio, gender, photos[], location, interests[]
│
├── matches/                # Các cặp match
│   └── {matchId}           # MatchDTO: user_id, matched_user_id, created_at, is_new
│       └── messages/       # Subcollection tin nhắn
│           └── {messageId} # MessageDTO: sender_id, content, type, is_read
│
└── swipes/                 # Lịch sử swipe
    └── {swipeId}           # swiper_id, swiped_user_id, direction, created_at
```

### DTO Mapping

Tất cả DTOs sử dụng `Codable` với custom `CodingKeys` (snake_case ↔ camelCase):

```
UserDTO ↔ User          (timestamp Double ↔ Date)
ProfileDTO ↔ Profile    (lat/lng ↔ Location struct)
MatchDTO ↔ Match        (timestamp Double ↔ Date)
MessageDTO ↔ Message    (type String ↔ MessageType enum)
```

### UserDefaults Keys

| Key | Type | Mục đích |
|-----|------|---------|
| `has_completed_onboarding` | Bool | Trạng thái onboarding |
| `current_user_id` | String | ID người dùng đang đăng nhập |
| `fcm_token` | String | Firebase Cloud Messaging token |
| `last_discover_refresh` | Date | Thời gian refresh danh sách khám phá |

---

## 7. Presentation Layer

### ViewModels

| ViewModel | Use Cases | @Published Properties |
|-----------|-----------|----------------------|
| **LoginViewModel** | LoginUseCase | email, password, isLoading, errorMessage, showError |
| **RegisterViewModel** | RegisterUseCase | displayName, email, password, confirmPassword, isLoading, passwordMismatch |
| **OnboardingViewModel** | UpdateProfileUseCase, UploadPhotoUseCase | currentStep, name, age, bio, gender, selectedPhotos, interests |
| **DiscoverViewModel** | GetDiscoverProfilesUseCase, SwipeUseCase | profiles, currentIndex, isLoading, showMatchAlert, matchedProfile |
| **MatchesViewModel** | GetMatchesUseCase | matches, isLoading, errorMessage |
| **ChatViewModel** | GetMessagesUseCase, SendMessageUseCase | messages, messageText, isLoading, isSending |
| **ConversationsViewModel** | GetConversationsUseCase | conversations, isLoading, errorMessage |
| **ProfileViewModel** | GetProfileUseCase, UpdateProfileUseCase, LogoutUseCase | profile, isLoading, isEditing, editName/Bio/JobTitle |
| **SettingsViewModel** | LogoutUseCase | distancePreference, ageRange, showLogoutConfirmation |

### Reusable Components

| Component | Props | Mô tả |
|-----------|-------|-------|
| **SwipeCardStack** | data, onSwipeLeft/Right, content builder | Card stack với 3D scale effect |
| **GradientButton** | title, icon, isLoading, action | Primary button với gradient |
| **ProfileImageView** | url, size, showBorder | Circle avatar (Kingfisher) |
| **LoadingView** | message | Spinner + message |
| **EmptyStateView** | icon, title, message, actionTitle, action | Empty state với optional CTA |

---

## 8. Design System

### Colors

| Token | Hex | Sử dụng |
|-------|-----|---------|
| primary | #FE3C72 | Brand color chính (Hot Pink) |
| primaryLight | #FF6B6B | Gradient start |
| primaryDark | #E91E63 | Gradient end |
| secondary | #FF8A65 | Secondary actions |
| accent | #FFD54F | Highlights |
| background | #FAFAFA | App background |
| success | #4CAF50 | Like / success |
| error | #F44336 | Dislike / error |
| info | #2196F3 | Super Like |

### Typography

Font family: **SF Pro Rounded** (system rounded design)

| Style | Size | Weight |
|-------|------|--------|
| largeTitle | 34 | Bold |
| title1 | 28 | Bold |
| title2 | 22 | Semibold |
| headline | 17 | Semibold |
| body | 17 | Regular |
| cardName | 28 | Bold |
| cardAge | 24 | Light |

---

## 9. Async & Reactive Patterns

| Pattern | Sử dụng |
|---------|---------|
| **async/await** | Tất cả UseCase.execute(), Repository methods |
| **Combine Publishers** | Real-time Firestore observers (matches, messages, conversations) |
| **@Published** | ViewModel state management |
| **@MainActor** | Tất cả ViewModels (UI updates on main thread) |

---

## 10. Error Handling

| Error Type | Cases | Localization |
|------------|-------|-------------|
| **AuthError** | invalidCredentials, userNotFound, emailAlreadyInUse, weakPassword, unknown | Vietnamese |
| **ChatError** | emptyMessage, matchNotFound, sendFailed | Vietnamese |
| **APIError** | networkError, serverError(Int), decodingError, unauthorized, notFound, unknown | Vietnamese |

---

## 11. Testing Strategy

| Layer | Test Type | Coverage |
|-------|-----------|----------|
| **Data** | DTO mapping tests | UserDTO, ProfileDTO (location mapping) |
| **Domain** | UseCase logic tests | LoginUseCase (validation, error), SwipeUseCase (match detection) |
| **Presentation** | ViewModel tests | LoginViewModel (form validation), DiscoverViewModel (profile loading) |
| **E2E** | UI tests | Auth flow (elements, navigation), Discover flow (tabs) |
| **Mocks** | 3 mock repositories | Configurable results, call counting |
