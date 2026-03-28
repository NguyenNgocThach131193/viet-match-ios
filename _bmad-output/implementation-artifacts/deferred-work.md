
## Story 1.4 - Google Sign-In Deferred Items (2026-03-28)

- **REVERSED_CLIENT_ID chưa được cấu hình**: `Info.plist` chứa placeholder `REPLACE_WITH_REVERSED_CLIENT_ID`. Cần lấy `REVERSED_CLIENT_ID` từ `GoogleService-Info.plist` (Firebase Console) và thay vào trước khi test thực tế. File này bị gitignore nên không thể tự động hóa.
- **Concurrent Google Sign-In taps**: LoginView không disable Google button khi `isLoading = true` (chỉ disable email/password login button). Rapid taps có thể launch multiple GIDSignIn sessions. Low priority — GIDSignIn tự quản lý singleton state.
- **Network error differentiation**: Firebase network errors propagate với Firebase's own `localizedDescription`. Không có `AuthError.networkError` case riêng. Functional nhưng error message sẽ là tiếng Anh từ Firebase SDK.

## Story 1.6 - Fix Hardcoded currentUserId trong DiscoverView (2026-03-28)

- **Empty string fallback khi chưa login**: `currentUserId ?? ""` trong PresentationAssembly sẽ tạo DiscoverViewModel với userId rỗng nếu UserDefaults chưa có giá trị. Request sẽ gửi với userId="" — cần auth-gating đảm bảo DiscoverView chỉ hiển thị sau login (consistent với ChatViewModel pattern).
- **Social login không persist currentUserId** (duplicate từ 1.5): `AuthRepository.loginWithGoogle()` và `loginWithApple()` không save currentUserId. Affects DiscoverViewModel và ChatViewModel.
- **Concurrent load bugs trong DiscoverViewModel**: `loadMoreProfiles()` có thể chạy concurrent khi swipe nhanh → duplicate profiles. `.task` re-fires khi view re-appears → double-reset của profiles/currentIndex. Cần debounce hoặc in-flight guard.
- **ProfileDetailViewModel hardcode currentUserId: ""** (duplicate từ 1.2): Vẫn chưa fix, ngoài scope.

## Story 1.5 - Fix Hardcoded currentUserId Deferred Items (2026-03-28)

- **Google/Apple login không persist currentUserId**: `AuthRepository.loginWithGoogle()` và `loginWithApple()` không gọi `userDefaultsService.set(user.id, forKey: UserDefaultsKey.currentUserId)`. User đăng nhập qua mạng xã hội sẽ có `currentUserId = ""` trong ChatViewModel. Cần fix trong `AuthRepository`.
- **ConversationsView hardcode "current_user_id"**: `ConversationsView.swift` vẫn còn `loadConversations(userId: "current_user_id")`. Cần story riêng để fix tương tự story này.
- **ProfileDetailViewModel hardcode currentUserId: ""**: Đã được ghi nhận từ Story 1.2, vẫn chưa fix. Cần inject từ UserDefaultsService giống ChatViewModel.
- **Force-unwrap pattern trong DI**: Toàn bộ `resolver.resolve(...)!` trong PresentationAssembly không có graceful error handling. Nên xem xét sử dụng precondition với message rõ ràng thay vì force-unwrap.

## Story 1.2 - ProfileDetailView Deferred Items (2026-03-28)

- **currentUserId empty string in DI**: ProfileDetailViewModel receives `currentUserId: ""`. Project-wide issue — DiscoverView also hardcodes user ID. Needs proper auth session service injected into coordinators/VMs.
- **Concurrent swipe calls**: No debouncing/throttling on swipe actions. Same pattern exists in DiscoverViewModel. Should add `guard !isSwiping` state.
- **Match alert "Nhắn tin" does nothing**: Tapping "Send message" in match alert only dismisses. Needs navigation to chat screen. Same gap exists in DiscoverView match alert.
- **AC#3 Distance display**: Profile entity has `location` (lat/lon/city) but no `distance` field. Displaying actual distance requires computing from current user's location or adding a distance field to the API response. CardView also only shows city.
- **Navigation from CardView to ProfileDetail**: DiscoverView/CardView have no tap gesture to trigger `coordinator.showProfileDetail(profileId:)`. This entry point needs a separate story.
