# VietMatch - Architecture Documentation

## 1. Clean Architecture Layers

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

---

## 2. Dependency Injection Flow (Swinject)

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

## 3. Navigation Flow (Coordinator Pattern)

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

## 4. Data Flow (MVVM Pattern)

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

---

## 5. Firebase Services Map

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

---

## 6. Project Module Map

```mermaid
graph TD
    subgraph SG_App ["App"]
        Entry["VietMatchApp.swift"]
        Delegate["AppDelegate.swift"]
        Container["AppContainer + Assemblies"]
    end

    subgraph SG_Domain ["Domain - 0 dependencies"]
        E["Entities: User, Profile, Match, Message, Swipe"]
        P["Protocols: Auth, Profile, Match, Chat"]
        U["UseCases: 12 use cases"]
    end

    subgraph SG_Data ["Data"]
        S["Services: Firebase + UserDefaults"]
        RI["Repos: Auth, Profile, Match, Chat"]
        D["DTOs + Mappers"]
    end

    subgraph SG_UI ["Presentation"]
        Nav["Navigation: 6 Coordinators"]
        Screens["Screens: 7 modules"]
        Comp["Components: 5 reusable views"]
    end

    subgraph SG_Design ["Design System"]
        DesignTokens["Colors + Typography + Spacing"]
    end

    subgraph SG_Tests ["Tests"]
        UT["Unit Tests: UseCases, ViewModels, DTOs"]
        UIT["UI Tests: Auth Flow, Discover Flow"]
        Mocks["Mocks: Auth, Profile, Match Repos"]
    end

    SG_App --> SG_Domain
    SG_App --> SG_Data
    SG_App --> SG_UI
    SG_UI --> SG_Domain
    SG_Data --> SG_Domain
    SG_UI --> SG_Design
    SG_Tests --> SG_Domain
    SG_Tests --> SG_Data
    SG_Tests --> SG_UI

    style SG_App fill:#FE3C72,color:#fff
    style SG_Domain fill:#FFF3E0,stroke:#FF8A65
    style SG_Data fill:#E3F2FD,stroke:#2196F3
    style SG_UI fill:#FFE0E6,stroke:#FE3C72
    style SG_Design fill:#F3E5F5,stroke:#9C27B0
    style SG_Tests fill:#E8F5E9,stroke:#4CAF50
```

---

## 7. Folder Structure

```
VietMatch/
├── App/
│   ├── VietMatchApp.swift
│   ├── AppDelegate.swift
│   └── DI/
│       ├── AppContainer.swift
│       ├── DataAssembly.swift
│       ├── DomainAssembly.swift
│       └── PresentationAssembly.swift
│
├── Domain/
│   ├── Entities/          (User, Profile, Match, Message, Swipe, Notification)
│   ├── UseCases/          (Auth, Profile, Matching, Chat)
│   └── Repositories/      (Protocol definitions only)
│
├── Data/
│   ├── Repositories/      (Protocol implementations)
│   ├── DataSources/
│   │   ├── Remote/        (Firebase Auth, Firestore, Storage, FCM)
│   │   └── Local/         (UserDefaults)
│   ├── DTOs/              (UserDTO, ProfileDTO, MessageDTO, MatchDTO)
│   └── Mappers/           (UserMapper, MessageMapper)
│
├── Presentation/
│   ├── Navigation/        (Coordinator, App, Auth, MainTab, Discover, Chat, Profile)
│   ├── Screens/           (Auth, Onboarding, Discover, Matches, Chat, Profile, Settings)
│   └── Components/        (SwipeCardStack, GradientButton, ProfileImage, Loading, EmptyState)
│
├── DesignSystem/          (Colors, Typography, Spacing)
│
├── Core/
│   ├── Extensions/        (View, Color, String)
│   ├── Networking/        (NetworkMonitor, APIError)
│   └── Utils/             (Logger, Constants)
│
├── VietMatchTests/        (Unit Tests + Mocks)
└── VietMatchUITests/      (UI Tests)
```

---

## 8. Tech Stack

| Category | Technology |
|----------|-----------|
| Language | Swift 5.9+ |
| UI Framework | SwiftUI |
| iOS Target | iOS 16+ |
| Architecture | MVVM + Clean Architecture |
| Navigation | Coordinator Pattern + NavigationStack |
| DI | Swinject |
| Backend | Firebase (Auth, Firestore, Storage, FCM) |
| Networking | Alamofire |
| Image Loading | Kingfisher |
| Reactive | Combine + async/await |
| Package Manager | SPM |
| Testing | XCTest (Unit + UI) |
