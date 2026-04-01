# Story 1.8: Concurrency Guards — In-Flight Protection cho Async Actions

Status: ready-for-dev

## Story

As a **nguoi dung tuong tac nhanh (swipe, tap)**,
I want **app chi xu ly 1 action tai 1 thoi diem**,
so that **khong co duplicate API calls, duplicate profiles, hoac race conditions**.

## Acceptance Criteria

1. `ProfileDetailViewModel.swipe()` co `isSwiping` guard — chi 1 swipe duoc xu ly tai 1 thoi diem
2. `DiscoverViewModel.loadMoreProfiles()` co in-flight guard — khong goi concurrent khi swipe nhanh
3. `DiscoverViewModel` swipe buttons disabled khi dang xu ly swipe
4. Tat ca unit tests hien tai van pass
5. Unit tests moi verify concurrent calls bi block

## Tasks / Subtasks

- [ ] Task 1: Them isSwiping guard cho ProfileDetailViewModel (AC: #1)
  - [ ] 1.1 Sua `VietMatch/Presentation/Screens/Discover/ProfileDetailViewModel.swift`
  - [ ] 1.2 Them `@Published private(set) var isSwiping = false` property
  - [ ] 1.3 Trong `swipe(direction:)` (line 40-55): them `guard !isSwiping else { return }` va set `isSwiping = true` / `defer { isSwiping = false }`
  - [ ] 1.4 Viet unit tests: verify concurrent swipe calls bi block, verify isSwiping state

- [ ] Task 2: Them in-flight guard cho DiscoverViewModel.loadMoreProfiles() (AC: #2)
  - [ ] 2.1 Sua `VietMatch/Presentation/Screens/Discover/DiscoverViewModel.swift`
  - [ ] 2.2 Them `private var isLoadingMore = false` property
  - [ ] 2.3 Trong `loadMoreProfiles()` (line 86-96): them `guard !isLoadingMore else { return }` va set `isLoadingMore = true` / `defer { isLoadingMore = false }`
  - [ ] 2.4 Viet unit test: verify concurrent loadMoreProfiles bi block

- [ ] Task 3: Disable swipe buttons khi dang processing (AC: #3)
  - [ ] 3.1 Kiem tra `DiscoverView.swift` (line 79-115) — xac dinh cac action buttons
  - [ ] 3.2 Them `.disabled(viewModel.isSwiping)` hoac tuong duong cho swipe buttons
  - [ ] 3.3 Neu DiscoverViewModel chua co `isSwiping` published property, them tuong tu ProfileDetailViewModel

- [ ] Task 4: Full test suite pass (AC: #4, #5)
  - [ ] 4.1 Chay toan bo test suite — dam bao 0 test failures moi
  - [ ] 4.2 Build thanh cong

## Dev Notes

### Pattern guard — BAT BUOC theo

```swift
// Trong ViewModel — guard pattern cho async actions
@Published private(set) var isSwiping = false

func swipe(direction: SwipeDirection) async {
    guard !isSwiping else { return }  // Block concurrent calls
    guard let profile else { return }
    isSwiping = true
    defer { isSwiping = false }
    
    // ... existing logic
}
```

### Hien trang tung ViewModel

**ProfileDetailViewModel** (`ProfileDetailViewModel.swift`):
- `swipe(direction:)` line 40-55 — **KHONG co guard**
- `like()` line 57, `dislike()` line 61, `superLike()` line 65 — goi `swipe()`, khong can guard rieng
- Da co `isLoading` cho `loadProfile()` — chi can them `isSwiping` cho swipe actions

**DiscoverViewModel** (`DiscoverViewModel.swift`):
- `loadMoreProfiles()` line 86-96 — **KHONG co in-flight guard**
- Duoc goi tu `swipe()` line 67 khi `currentIndex >= profiles.count - 3`
- `profiles.append(contentsOf:)` line 92 co the append duplicates neu concurrent
- `loadProfiles()` line 35-47 — da co `isLoading` guard implicit (set isLoading = true)

**LoginViewModel** (`LoginViewModel.swift`):
- `loginWithGoogle()` line 43-54 — **DA CO guard** (`guard !isLoading else { return }`)
- LoginView da disable button khi isLoading — **KHONG CAN SUA**

### Luu y

- **KHONG sua LoginViewModel** — da co guard dung
- `isSwiping` nen la `private(set)` de View co the observe nhung khong set truc tiep
- `isLoadingMore` co the la `private` neu View khong can observe — nhung nen la `private(set)` de co the disable UI
- Pre-existing test failures (`@testable import VietMatch`) KHONG lien quan — bo qua

### Project Structure Notes

- Tests: `VietMatchTests/Presentation/ViewModels/` — tao test files tuong ung
- Mocks: `VietMatchTests/Mocks/` — su dung existing mocks
- Existing tests: `DiscoverViewModelTests.swift`, `ProfileDetailViewModelTests.swift` (kiem tra truoc khi tao moi)

### References

- [Source: ProfileDetailViewModel.swift#L40-55 — swipe() khong co guard]
- [Source: DiscoverViewModel.swift#L86-96 — loadMoreProfiles() khong co guard]
- [Source: LoginViewModel.swift#L43-54 — loginWithGoogle() DA CO guard — reference pattern]
- [Source: deferred-work.md — CONC-1, CONC-2, CONC-3]

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
