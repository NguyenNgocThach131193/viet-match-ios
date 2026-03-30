# Tổng Quan Dự Án

> Thông tin tổng quan về dự án VietMatch — tech stack, tính năng, kiến trúc

---

## Giới Thiệu

**VietMatch** là ứng dụng hẹn hò dành cho người Việt, được phát triển trên nền tảng iOS bằng Swift và SwiftUI. Ứng dụng áp dụng kiến trúc Clean Architecture kết hợp MVVM-C (Model-View-ViewModel-Coordinator), sử dụng Firebase làm backend.

---

## Thông Tin Nhanh

| Hạng mục | Chi tiết |
|----------|---------|
| **Tên dự án** | VietMatch |
| **Loại** | Monolith - iOS Native App |
| **Ngôn ngữ** | Swift 5.9+ |
| **UI Framework** | SwiftUI |
| **iOS Target** | iOS 16.0+ |
| **Device** | iPhone only |
| **Kiến trúc** | MVVM + Clean Architecture + Coordinator Pattern |
| **Backend** | Firebase (Auth, Firestore, Storage, FCM) |
| **Package Manager** | Swift Package Manager (SPM) |
| **DI Framework** | Swinject |
| **Xcode Project** | XcodeGen (project.yml) |
| **Bundle ID** | com.vietmatch.app |

---

## Tech Stack

| Danh mục | Công nghệ | Phiên bản | Mục đích |
|----------|-----------|-----------|---------|
| Ngôn ngữ | Swift | 5.9+ | Ngôn ngữ chính |
| UI | SwiftUI | iOS 16+ | Giao diện người dùng |
| Backend Auth | Firebase Auth | 11.0+ | Xác thực (Email, Google, Apple) |
| Database | Cloud Firestore | 11.0+ | NoSQL database thời gian thực |
| Storage | Firebase Storage | 11.0+ | Lưu trữ ảnh người dùng |
| Push | Firebase Cloud Messaging | 11.0+ | Thông báo đẩy |
| Analytics | Firebase Analytics | 11.0+ | Theo dõi sử dụng |
| Networking | Alamofire | 5.9+ | HTTP networking |
| Image Loading | Kingfisher | 7.12+ | Tải & cache ảnh |
| DI | Swinject | 2.9+ | Dependency Injection container |
| Reactive | Combine | Built-in | Reactive programming |
| Async | async/await | Built-in | Concurrency |
| Testing | XCTest | Built-in | Unit & UI Tests |
| Navigation | NavigationStack | Built-in | Coordinator-based navigation |

---

## Tính Năng Chính

### 1. Xác Thực (Authentication)
- Đăng nhập / Đăng ký bằng Email & mật khẩu
- Đăng nhập bằng Google (đang phát triển)
- Đăng nhập bằng Apple
- Đặt lại mật khẩu
- Xóa tài khoản

### 2. Hồ Sơ (Profile)
- Onboarding 4 bước: Thông tin cá nhân → Giới tính → Ảnh → Sở thích
- Tải lên tối đa 6 ảnh
- Chỉnh sửa hồ sơ (tên, bio, công việc, trường học)
- Cập nhật vị trí

### 3. Khám Phá (Discover)
- Swipe cards với hiệu ứng 3D
- Like / Dislike / Super Like
- Photo carousel trên mỗi card
- Tải danh sách hồ sơ (mặc định 20)

### 4. Kết Nối (Matches)
- Danh sách matches mới (horizontal scroll)
- Danh sách tất cả matches
- Thông báo khi có match mới
- Hủy match

### 5. Trò Chuyện (Chat)
- Tin nhắn real-time (Firestore listeners)
- Hỗ trợ text, image, GIF
- Danh sách cuộc trò chuyện với unread count
- Đánh dấu tin nhắn đã đọc

### 6. Cài Đặt (Settings)
- Tùy chỉnh khoảng cách tìm kiếm (1-160 km)
- Tùy chỉnh độ tuổi (18-100)
- Bật/tắt thông báo
- Đăng xuất / Xóa tài khoản

---

## Kiến Trúc Tổng Quan

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                     │
│  ┌──────────┐  ┌──────────────┐  ┌───────────────────┐  │
│  │  Views    │→│  ViewModels   │→│   Coordinators     │  │
│  │ (SwiftUI) │  │(@Observable) │  │  (Navigation)     │  │
│  └──────────┘  └──────────────┘  └───────────────────┘  │
├─────────────────────────────────────────────────────────┤
│                      Domain Layer                        │
│  ┌──────────────┐  ┌──────────┐  ┌──────────────────┐  │
│  │  Use Cases    │→│ Entities  │  │ Repo Protocols   │  │
│  │(Business Logic│  │ (Models)  │  │ (Abstractions)   │  │
│  └──────────────┘  └──────────┘  └──────────────────┘  │
├─────────────────────────────────────────────────────────┤
│                       Data Layer                         │
│  ┌──────────────┐  ┌──────────┐  ┌──────────────────┐  │
│  │ Repositories  │→│   DTOs    │→│ Firebase Services │  │
│  │(Implementations│ │ (Codable) │  │ (Remote/Local)   │  │
│  └──────────────┘  └──────────┘  └──────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## Firestore Data Model

| Collection | Mô tả | Subcollections |
|-----------|--------|---------------|
| `users` | Thông tin tài khoản (email, displayName, profileCompleted) | - |
| `profiles` | Hồ sơ chi tiết (name, age, bio, photos, location, interests) | - |
| `matches` | Các cặp match (userId, matchedUserId, createdAt) | `messages` |
| `matches/{id}/messages` | Tin nhắn trong mỗi match | - |
| `swipes` | Lịch sử swipe (swiperId, swipedUserId, direction) | - |

---

## Testing

| Loại | Số file | Phạm vi |
|------|---------|---------|
| Unit Tests | 5 files | DTO mapping, UseCase validation, ViewModel logic |
| Mocks | 3 files | AuthRepository, MatchRepository, ProfileRepository |
| UI Tests | 2 files | Auth flow, Discover flow (tab navigation) |

---

## Tài Liệu Hiện Có (Tại Root)

| File | Mô tả |
|------|-------|
| [ARCHITECTURE.md](../ARCHITECTURE.md) | Kiến trúc chi tiết với Mermaid diagrams |
| [GITFLOW.md](../GITFLOW.md) | GitFlow, branching strategy, conventional commits |
| [project.yml](../project.yml) | XcodeGen project configuration |

---

## Liên Kết Tài Liệu

- [Kiến trúc chi tiết](./architecture.md)
- [Cấu trúc thư mục](./source-tree-analysis.md)
- [Component inventory](./component-inventory.md)
- [Data models](./data-models.md)
- [Hướng dẫn phát triển](./development-guide.md)
