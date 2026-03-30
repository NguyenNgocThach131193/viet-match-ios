# Data Models

> Domain entities, DTOs, Firestore schema và mapping strategy

---

## 1. Domain Entities

### User

```swift
struct User {
    let id: String
    let email: String
    let displayName: String
    let profileCompleted: Bool
    let createdAt: Date
    let lastActiveAt: Date
}
```

### Profile

```swift
struct Profile {
    let id: String
    let name: String
    let age: Int
    let bio: String
    let gender: Gender              // .male, .female, .other
    let interestedIn: Gender
    let photos: [String]            // URLs
    let location: Location?
    let interests: [String]
    let jobTitle: String?
    let company: String?
    let school: String?
    let distancePreference: Int     // km
    let ageRangeMin: Int
    let ageRangeMax: Int
}

struct Location {
    let latitude: Double
    let longitude: Double
    let city: String?
}
```

### Match

```swift
struct Match {
    let id: String
    let userId: String
    let matchedUserId: String
    let matchedProfile: Profile?
    let createdAt: Date
    let lastMessageAt: Date?
    let isNew: Bool
}
```

### Message & Conversation

```swift
struct Message {
    let id: String
    let matchId: String
    let senderId: String
    let content: String
    let type: MessageType           // .text, .image, .gif
    let createdAt: Date
    let isRead: Bool
}

struct Conversation {
    let id: String
    let match: Match
    let lastMessage: Message?
    let unreadCount: Int
}
```

### Swipe

```swift
struct Swipe {
    let id: String
    let swiperId: String
    let swipedUserId: String
    let direction: SwipeDirection    // .like, .dislike, .superLike
    let createdAt: Date
}
```

### AppNotification

```swift
struct AppNotification {
    let id: String
    let userId: String
    let type: NotificationType      // .newMatch, .newMessage, .superLike, .profileView
    let title: String
    let body: String
    let data: [String: String]?
    let createdAt: Date
    let isRead: Bool
}
```

---

## 2. Enums

| Enum | Cases | Sử dụng |
|------|-------|---------|
| **Gender** | male, female, other | Profile gender & preference |
| **SwipeDirection** | like, dislike, superLike | Swipe actions |
| **MessageType** | text, image, gif | Message content type |
| **NotificationType** | newMatch, newMessage, superLike, profileView | Push notification routing |

---

## 3. DTOs (Data Transfer Objects)

Tất cả DTOs conform `Codable` với custom `CodingKeys` (snake_case cho Firestore).

### UserDTO

```swift
struct UserDTO: Codable {
    let id: String
    let email: String
    let displayName: String         // CodingKey: "display_name"
    let profileCompleted: Bool      // CodingKey: "profile_completed"
    let createdAt: Double           // Timestamp → Date
    let lastActiveAt: Double        // CodingKey: "last_active_at"
}
```

### ProfileDTO

```swift
struct ProfileDTO: Codable {
    let id: String
    let name: String
    let age: Int
    let bio: String
    let gender: String
    let interestedIn: String        // CodingKey: "interested_in"
    let photos: [String]
    let latitude: Double?
    let longitude: Double?
    let city: String?
    let interests: [String]
    let jobTitle: String?           // CodingKey: "job_title"
    let company: String?
    let school: String?
    let distancePreference: Int     // CodingKey: "distance_preference"
    let ageRangeMin: Int            // CodingKey: "age_range_min"
    let ageRangeMax: Int            // CodingKey: "age_range_max"
}
```

### MatchDTO

```swift
struct MatchDTO: Codable {
    let id: String
    let userId: String              // CodingKey: "user_id"
    let matchedUserId: String       // CodingKey: "matched_user_id"
    let createdAt: Double           // Timestamp
    let lastMessageAt: Double?      // CodingKey: "last_message_at"
    let isNew: Bool                 // CodingKey: "is_new"
}
```

### MessageDTO

```swift
struct MessageDTO: Codable {
    let id: String
    let matchId: String             // CodingKey: "match_id"
    let senderId: String            // CodingKey: "sender_id"
    let content: String
    let type: String                // String → MessageType enum
    let createdAt: Double           // CodingKey: "created_at"
    let isRead: Bool                // CodingKey: "is_read"
}
```

---

## 4. Firestore Schema

```
Firestore Database
│
├── users/{userId}
│   ├── id: string
│   ├── email: string
│   ├── display_name: string
│   ├── profile_completed: boolean
│   ├── created_at: number (timestamp)
│   └── last_active_at: number (timestamp)
│
├── profiles/{userId}
│   ├── id: string
│   ├── name: string
│   ├── age: number
│   ├── bio: string
│   ├── gender: string ("male" | "female" | "other")
│   ├── interested_in: string
│   ├── photos: array<string>       // Storage URLs
│   ├── latitude: number?
│   ├── longitude: number?
│   ├── city: string?
│   ├── interests: array<string>
│   ├── job_title: string?
│   ├── company: string?
│   ├── school: string?
│   ├── distance_preference: number
│   ├── age_range_min: number
│   └── age_range_max: number
│
├── matches/{matchId}
│   ├── id: string
│   ├── user_id: string
│   ├── matched_user_id: string
│   ├── created_at: number (timestamp)
│   ├── last_message_at: number? (timestamp)
│   ├── is_new: boolean
│   └── messages/{messageId}         // Subcollection
│       ├── id: string
│       ├── match_id: string
│       ├── sender_id: string
│       ├── content: string
│       ├── type: string ("text" | "image" | "gif")
│       ├── created_at: number (timestamp)
│       └── is_read: boolean
│
└── swipes/{swipeId}
    ├── id: string
    ├── swiper_id: string
    ├── swiped_user_id: string
    ├── direction: string ("like" | "dislike" | "superLike")
    └── created_at: number (timestamp)
```

---

## 5. Firebase Storage

```
Firebase Storage
└── photos/
    └── {userId}/
        └── {UUID}.jpg              // JPEG format, metadata: image/jpeg
```

---

## 6. UserDefaults

| Key | Type | Mô tả |
|-----|------|-------|
| `has_completed_onboarding` | Bool | Đã hoàn thành onboarding |
| `current_user_id` | String | ID người dùng đang đăng nhập |
| `fcm_token` | String | FCM device token |
| `last_discover_refresh` | Date | Lần cuối refresh danh sách khám phá |

---

## 7. Mapping Strategy

### DTO → Domain

| Chuyển đổi | Logic |
|-----------|-------|
| Timestamp → Date | `Date(timeIntervalSince1970: dto.createdAt)` |
| String → Enum | `Gender(rawValue: dto.gender)` |
| lat/lng → Location | `Location(latitude:longitude:city:)` nếu cả hai tồn tại |
| String → MessageType | `MessageType(rawValue: dto.type)` |

### Domain → DTO

| Chuyển đổi | Logic |
|-----------|-------|
| Date → Timestamp | `entity.createdAt.timeIntervalSince1970` |
| Enum → String | `entity.gender.rawValue` |
| Location → fields | Flatten thành `latitude`, `longitude`, `city` |
