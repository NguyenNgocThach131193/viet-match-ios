# Story FEAT-1: Match Alert — Custom Overlay & Navigation

Status: ready-for-dev

Epic: 3.3 (Match Detection & Match Alert) — deferred work

## Context

Match detection đã hoạt động (SwipeUseCase tạo Match record, `showMatchAlert = true`). Navigation từ alert tới ChatView cũng đã có (DiscoverCoordinator → MainTabCoordinator.navigateToChat → ChatCoordinator.showChat). Tuy nhiên UI hiện tại dùng native iOS `.alert` dialog — không đúng với UX spec (UX-DR1).

**Vấn đề cần fix:** Thay thế `.alert("It's a Match! 🎉", ...)` bằng custom overlay với warmGradient background, 2 avatars side by side, theo UX-DR1.

## Story

As a **người dùng vừa có match**,
I want **thấy một màn hình ăn mừng đẹp với ảnh của cả hai người**,
so that **khoảnh khắc match trở nên đặc biệt và tôi dễ dàng chuyển sang chat ngay**.

## Acceptance Criteria

1. Khi match xảy ra (từ DiscoverView hoặc ProfileDetailView) → native `.alert` được THAY THẾ bằng custom full-screen overlay
2. Overlay có warmGradient background (`VietMatchColors.warmGradient` hoặc tương đương — pink/orange gradient)
3. Hai avatar tròn hiển thị side by side: avatar trái = current user, avatar phải = matched user, cả hai có border trắng, kích thước 120×120
4. Text "It's a Match! 🎉" font largeTitle, màu white, center
5. Sub-text "Bạn và [tên người match] đã thích nhau!" font subheadline, màu white.opacity(0.9)
6. Button "Nhắn tin ngay" (primary style, full width) → dismiss overlay và navigate tới `ChatView(matchId)` qua coordinator
7. Button "Để sau" (text style, màu white) → dismiss overlay, DiscoverView tiếp tục với card tiếp theo
8. Overlay animate in: scale from 0.8 + fade in (duration 0.3s)
9. Behavior giống nhau từ cả DiscoverView lẫn ProfileDetailView (dùng chung MatchAlertOverlay component)

## Tasks / Subtasks

- [ ] Task 1: Tạo MatchAlertOverlay component
  - [ ] 1.1 Tạo `VietMatch/Presentation/Screens/Discover/MatchAlertOverlay.swift` — nhận `matchedProfile: Profile`, `currentUserPhotoURL: String?`, `matchId: String`, callbacks `onMessage: (String) -> Void`, `onLater: () -> Void`
  - [ ] 1.2 Layout: ZStack full screen với warmGradient background, VStack center với 2 avatars HStack, title text, subtitle text, 2 buttons
  - [ ] 1.3 Avatar: `AsyncImage` hoặc `ProfileImageView` với circle clip, white stroke border 3pt, kích thước 120×120
  - [ ] 1.4 Animate in: `.scaleEffect` + `.opacity` transition với `.easeOut(duration: 0.3)`
  - [ ] 1.5 Thêm vào project.pbxproj

- [ ] Task 2: Thêm currentUserPhotoURL vào DiscoverViewModel và ProfileDetailViewModel
  - [ ] 2.1 Trong `DiscoverViewModel` — thêm `@Published var currentUserPhotoURL: String?`, load từ `getProfileUseCase.execute(userId: currentUserId)` khi loadProfiles
  - [ ] 2.2 Trong `ProfileDetailViewModel` — tương tự, load current user photo khi cần hiển thị match alert
  - [ ] 2.3 Nếu currentUserPhotoURL nil — fallback sang placeholder icon `person.circle.fill`

- [ ] Task 3: Tích hợp vào DiscoverView
  - [ ] 3.1 Xóa `.alert("It's a Match! 🎉", isPresented: $viewModel.showMatchAlert)` block
  - [ ] 3.2 Thêm `.overlay` hoặc `.fullScreenCover(isPresented:)` với `MatchAlertOverlay(matchedProfile:currentUserPhotoURL:matchId:onMessage:onLater:)`
  - [ ] 3.3 `onMessage` callback: `coordinator.showChat(matchId:)`
  - [ ] 3.4 `onLater` callback: `viewModel.showMatchAlert = false`

- [ ] Task 4: Tích hợp vào ProfileDetailView
  - [ ] 4.1 Xóa `.alert("It's a Match! 🎉", isPresented: $viewModel.showMatchAlert)` block
  - [ ] 4.2 Thêm `MatchAlertOverlay` với cùng pattern
  - [ ] 4.3 `onMessage` callback: `coordinator.pop()` rồi `coordinator.showChat(matchId:)` (cần DiscoverCoordinator expose showChat)

- [ ] Task 5: Build & test
  - [ ] 5.1 Build thành công
  - [ ] 5.2 Test thủ công: tạo mutual like → overlay xuất hiện → nhấn "Nhắn tin ngay" → navigate tới ChatView đúng matchId
  - [ ] 5.3 Test: nhấn "Để sau" → overlay dismiss → card tiếp theo hiển thị
  - [ ] 5.4 Test: overlay xuất hiện từ ProfileDetailView đúng cách

## Dev Notes

### State hiện tại (đã hoạt động — KHÔNG thay đổi)

```swift
// DiscoverCoordinator.swift
var navigateToChat: ((String) -> Void)?
func showChat(matchId: String) { navigateToChat?(matchId) }

// MainTabCoordinator.swift — đã wire navigateToChat
coordinator.navigateToChat = { [weak self] matchId in
    self?.navigateToChat(matchId: matchId)
}
func navigateToChat(matchId: String) {
    selectedTab = .chat
    chatCoordinator.showChat(matchId: matchId)
}
```

### Chỉ thay đổi phần UI — KHÔNG đụng coordinator logic

DiscoverViewModel và ProfileDetailViewModel đã có:
- `@Published var showMatchAlert = false`
- `@Published var matchedProfile: Profile?`
- `@Published var currentMatchId: String?`

Chỉ cần thêm `currentUserPhotoURL` và thay `.alert` → custom overlay.

### warmGradient reference

```swift
// Dùng gradient hiện có từ design system nếu có, hoặc:
LinearGradient(
    colors: [Color(hex: "#FF6B6B"), Color(hex: "#FF8E53")],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```

### Files cần chỉnh sửa

| File | Thay đổi |
|------|----------|
| `VietMatch/Presentation/Screens/Discover/MatchAlertOverlay.swift` | Mới — custom overlay component |
| `VietMatch/Presentation/Screens/Discover/DiscoverView.swift` | Thay `.alert` → MatchAlertOverlay |
| `VietMatch/Presentation/Screens/Discover/DiscoverViewModel.swift` | Thêm `currentUserPhotoURL` |
| `VietMatch/Presentation/Screens/Discover/ProfileDetailView.swift` | Thay `.alert` → MatchAlertOverlay |
| `VietMatch/Presentation/Screens/Discover/ProfileDetailViewModel.swift` | Thêm `currentUserPhotoURL` |
| `VietMatchTests/Presentation/ViewModels/DiscoverViewModelTests.swift` | Test currentUserPhotoURL loading |

### Deferred từ

deferred-work.md FEAT-1: "Match alert 'Nhắn tin' chỉ dismiss, không navigate tới chat screen" — navigation đã được fix trong một PR trước, story này hoàn thiện phần UI/UX theo UX-DR1.
