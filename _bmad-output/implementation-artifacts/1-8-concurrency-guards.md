# Story 1.8: Concurrency Guards — In-Flight Protection cho Async Actions

Status: done

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

- [x] Task 1: Them isSwiping guard cho ProfileDetailViewModel (AC: #1)
  - [x] 1.1 Sua `VietMatch/Presentation/Screens/Discover/ProfileDetailViewModel.swift`
  - [x] 1.2 Them `@Published private(set) var isSwiping = false` property
  - [x] 1.3 Trong `swipe(direction:)` (line 40-55): them `guard !isSwiping else { return }` va set `isSwiping = true` / `defer { isSwiping = false }`
  - [x] 1.4 Viet unit tests: verify concurrent swipe calls bi block, verify isSwiping state

- [x] Task 2: Them in-flight guard cho DiscoverViewModel.loadMoreProfiles() (AC: #2)
  - [x] 2.1 Sua `VietMatch/Presentation/Screens/Discover/DiscoverViewModel.swift`
  - [x] 2.2 Them `private var isLoadingMore = false` property
  - [x] 2.3 Trong `loadMoreProfiles()` (line 86-96): them `guard !isLoadingMore else { return }` va set `isLoadingMore = true` / `defer { isLoadingMore = false }`
  - [x] 2.4 Viet unit test: verify concurrent loadMoreProfiles bi block

- [x] Task 3: Disable swipe buttons khi dang processing (AC: #3)
  - [x] 3.1 Kiem tra `DiscoverView.swift` (line 79-115) — xac dinh cac action buttons
  - [x] 3.2 Them `.disabled(viewModel.isSwiping)` hoac tuong duong cho swipe buttons
  - [x] 3.3 Neu DiscoverViewModel chua co `isSwiping` published property, them tuong tu ProfileDetailViewModel

- [x] Task 4: Full test suite pass (AC: #4, #5)
  - [x] 4.1 Chay toan bo test suite — dam bao 0 test failures moi
  - [x] 4.2 Build thanh cong

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

### Review Findings

- [x] [Review][Decision] CardView gesture không bị disable khi swiping — Fixed: thêm `.allowsHitTesting(!viewModel.isSwiping)` cho cardStack
- [x] [Review][Defer] `loadProfiles()` thiếu reentrancy guard [DiscoverViewModel.swift:35-47] — deferred, pre-existing

## Dev Agent Record

### Agent Model Used

Claude Opus 4.6 (1M context)

### Debug Log References

N/A

### Completion Notes List

- **Task 1:** Added `@Published private(set) var isSwiping = false` to `ProfileDetailViewModel`. Added `guard !isSwiping` + `defer` pattern to `swipe(direction:)`. 3 new tests: `test_swipe_setsIsSwipingDuringExecution`, `test_swipe_concurrentCallsBlocked`, `test_isSwiping_resetsAfterError`.
- **Task 2:** Added `private var isLoadingMore = false` with guard to `loadMoreProfiles()`. Added `@Published private(set) var isSwiping = false` with guard to `swipe(direction:)` in `DiscoverViewModel`. 4 new tests: `test_swipe_setsIsSwipingDuringExecution`, `test_swipe_concurrentCallsBlocked`, `test_loadMoreProfiles_concurrentCallsBlocked`, `test_isSwiping_resetsAfterError`.
- **Task 3:** Added `.disabled(viewModel.isSwiping)` to `actionButtons` container in `DiscoverView`.
- **Task 4:** Full unit test suite passed — 72/72 tests, 0 failures. UI tests have pre-existing failures (app launch issues, unrelated to this story).
- **Pre-existing fix:** Removed phantom `MockDeletePhotoUseCase.swift` reference from `project.pbxproj` (file exists at correct location `VietMatchTests/Mocks/`).
- Added `swipeDelay` and `getDiscoverProfilesDelay` to `MockMatchRepository` for concurrency test support.

### Change Log

- 2026-04-01: Implemented concurrency guards for Story 1-8 — all 4 tasks complete

### File List

- VietMatch/Presentation/Screens/Discover/ProfileDetailViewModel.swift (modified)
- VietMatch/Presentation/Screens/Discover/DiscoverViewModel.swift (modified)
- VietMatch/Presentation/Screens/Discover/DiscoverView.swift (modified)
- VietMatchTests/Presentation/ViewModels/ProfileDetailViewModelTests.swift (modified)
- VietMatchTests/Presentation/ViewModels/DiscoverViewModelTests.swift (modified)
- VietMatchTests/Mocks/MockMatchRepository.swift (modified)
- VietMatch.xcodeproj/project.pbxproj (modified — removed phantom MockDeletePhotoUseCase reference)
