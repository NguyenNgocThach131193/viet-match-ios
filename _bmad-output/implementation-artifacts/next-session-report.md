# Next Session — Remaining Stories Report

**Date:** 2026-04-01  
**Branch:** develop  
**Context:** Session 2 của implementation sprint. Stories 3.3, 3.5, 3.6, 4.4, 5.1, 5.3, 2.6 đã được implement.

---

## ✅ Đã hoàn thành trong session này

| Story | Mô tả | Files thay đổi chính |
|-------|-------|----------------------|
| 3.3 | Match alert "Nhắn tin ngay" → navigate ChatView(matchId) | DiscoverView, ProfileDetailView, DiscoverViewModel, ProfileDetailViewModel, DiscoverCoordinator, MainTabCoordinator |
| 3.5 | Matches list tap → navigate to ChatView | MatchesView |
| 3.6 | Discover empty state: text + "Làm mới danh sách" CTA | DiscoverView |
| 4.4 | Cross-tab: Matches → Chat navigation | MainTabCoordinator, MatchesView |
| 5.3 | DeleteAccountUseCase (4-step: photos → profile → user → auth) | DeleteAccountUseCase (NEW), ProfileRepositoryProtocol, SettingsViewModel, SettingsView, DomainAssembly, PresentationAssembly |
| 5.1 | Search filters load/save Firestore với Combine debounce | SettingsViewModel, SettingsView, PresentationAssembly |
| 2.6 | LocationService: CoreLocation + reverse geocode + profile update | LocationService (NEW), DataAssembly, AppCoordinator |

---

## 🔴 Còn lại — Cần implement trong session tiếp

### 1. Story 1.5 — Apple Sign-In UI
**Priority:** Medium  
**Complexity:** Medium  
**Files cần đụng:**
- `VietMatch/Presentation/Screens/Auth/LoginView.swift` — thêm `SignInWithAppleButton`
- Tạo `AppleSignInHelper.swift` (nonce generation, ASAuthorizationController delegate)
- `LoginViewModel.swift` — thêm `loginWithApple()` method
- `project.yml` — đã auto-include

**Hướng dẫn:**
- Dùng `AuthenticationServices` framework
- Generate cryptographically secure nonce trước khi gọi Apple
- `ASAuthorizationController` → `didCompleteWithAuthorization` → lấy `idToken` + `nonce` → gọi `authRepository.loginWithApple(idToken:nonce:)`
- Handle cancel gracefully (no error shown)
- `AuthRepository.loginWithApple` đã implement sẵn ở Data layer

---

### 2. Story 4.3 — Photo Sharing in Chat
**Priority:** Medium  
**Complexity:** High  
**Files cần đụng:**
- `VietMatch/Presentation/Screens/Chat/ChatView.swift` — thêm attach button + `PhotosPicker`
- `ChatViewModel.swift` — thêm `sendPhoto(imageData:)` method
- `ChatRepository.swift` / `ChatRepositoryProtocol.swift` — thêm `sendImageMessage(matchId:senderId:imageData:)`
- `SendMessageUseCase.swift` — thêm image upload support
- `Message.swift` entity — verify `type: .image` đã có
- `MessageBubbleView.swift` — thêm image bubble rendering (KFImage)

**Hướng dẫn:**
- Dùng `PhotosPicker` (SwiftUI native, iOS 16+)
- Upload ảnh lên Firebase Storage path: `chat/{matchId}/{UUID}.jpg`
- Sau khi upload → tạo message với `type: .image`, `content: downloadURL`
- Bubble render: nếu `type == .image` → `KFImage(url)` thay vì `Text`
- Guard `!isSending` để block duplicate sends

---

### 3. Story 5.2 — Push Notifications (FCM)
**Priority:** Low-Medium  
**Complexity:** High  
**Files cần đụng:**
- `VietMatch/App/AppDelegate.swift` — thêm `MessagingDelegate`, `UNUserNotificationCenterDelegate`
- `SettingsView.swift` / `SettingsViewModel.swift` — connect toggles tới `FCMService`
- `FCMService.swift` — đã có protocol, cần verify implementation
- Firestore: save FCM token vào `users/{userId}.fcmToken` khi toggle bật

**Hướng dẫn:**
- `AppDelegate.application(_:didRegisterForRemoteNotificationsWithDeviceToken:)` → gọi `Messaging.messaging().apnsToken = deviceToken`
- `MessagingDelegate.messaging(_:didReceiveRegistrationToken:)` → save token lên Firestore
- Toggle "Bật thông báo" → `FCMService.requestPermission()` + save token; toggle tắt → delete token from Firestore
- Push từ server side (Cloud Functions) chưa cần implement — chỉ cần client-side setup
- SettingsViewModel cần `FCMServiceProtocol` injection

---

## ⚠️ Deferred Items vẫn còn open

| ID | Mô tả | Priority |
|----|-------|----------|
| PHOTO-4 | `errorMessage == nil` dùng làm success signal — fragile | Low |
| PHOTO-5 | `removePhoto` URL mismatch trailing slash | Medium |
| CONC-4 | `loadProfiles()` reentrancy guard còn thiếu | Medium |
| DI-1 | Force-unwrap trong PresentationAssembly | Low |
| EDGE-1 | HEIC/WebP fallback chưa có | Low |
| EDGE-2 | Firebase errors hiện tiếng Anh | Medium |
| AUTH-5 | Cold start re-persist userId | Medium |
| AUTH-6 | Stale userId sau re-login | Medium |

---

## 📋 Sprint Status hiện tại

| Epic | Status | Done/Total |
|------|--------|------------|
| Epic 1 | in-progress | 6/7 (Apple Sign-In còn) |
| Epic 2 | **done** | 6/6 ✅ |
| Epic 3 | **done** | 6/6 ✅ |
| Epic 4 | in-progress | 3/4 (Photo/GIF còn) |
| Epic 5 | in-progress | 2/3 (Push Notif còn) |

---

## 🚀 Quick Start cho session mới

```
Mở project: /Users/thachnguyen/Desktop/Projects/ios-vibe-project/VietMatch
Branch: develop
Sprint status: _bmad-output/implementation-artifacts/sprint-status.yaml

Priority order:
1. Story 1.5 — Apple Sign-In (hoàn thành Epic 1)
2. Story 4.3 — Photo in Chat
3. Story 5.2 — Push Notifications
4. Deferred: EDGE-2 (Vietnamese errors), CONC-4 (loadProfiles guard)
```
