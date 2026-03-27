# Story 1.6: Fix Hardcoded currentUserId trong DiscoverView

Status: ready-for-dev

## Story

As a **nguoi dung dang kham pha**,
I want **danh sach ho so duoc tai dua tren userId that cua toi**,
so that **toi khong thay ho so cua chinh minh va ket qua loc dung theo preferences cua toi**.

## Acceptance Criteria

1. DiscoverView truyen `currentUserId` that tu auth state thay vi hardcoded string
2. userId duoc lay tu UserDefaultsService hoac inject qua DiscoverViewModel
3. `loadProfiles(userId:)` duoc goi voi userId that
4. Ho so cua nguoi dung hien tai bi loai tru khoi ket qua kham pha
5. Khong co hardcoded `"current_user_id"` con lai trong DiscoverView
6. Tat ca unit tests hien tai van pass

## Tasks / Subtasks

- [ ] Task 1: Cap nhat DiscoverViewModel inject currentUserId (AC: #1, #2, #3)
  - [ ] 1.1 Sua `VietMatch/Presentation/Screens/Discover/DiscoverViewModel.swift`
  - [ ] 1.2 Them property `currentUserId: String` duoc inject qua init
  - [ ] 1.3 Option A: Inject `UserDefaultsService` va lay tu `UserDefaultsKey.currentUserId`
  - [ ] 1.4 Option B: Them `currentUserId` parameter vao init, truyen tu Coordinator
  - [ ] 1.5 Cap nhat `loadProfiles()` de su dung `self.currentUserId` thay vi nhan parameter

- [ ] Task 2: Cap nhat DiscoverView (AC: #5)
  - [ ] 2.1 Sua `VietMatch/Presentation/Screens/Discover/DiscoverView.swift`
  - [ ] 2.2 Thay `await viewModel.loadProfiles(userId: "current_user_id")` bang `await viewModel.loadProfiles()`
  - [ ] 2.3 userId da duoc inject vao ViewModel, View khong can biet

- [ ] Task 3: Cap nhat DI registration (AC: #2)
  - [ ] 3.1 Sua `PresentationAssembly` - truyen currentUserId khi resolve DiscoverViewModel
  - [ ] 3.2 Sua `DiscoverCoordinator.discoverView()` neu can truyen userId

- [ ] Task 4: Viet/cap nhat unit tests (AC: #4, #6)
  - [ ] 4.1 Cap nhat `DiscoverViewModelTests` - test voi userId inject
  - [ ] 4.2 Test: loadProfiles su dung dung userId
  - [ ] 4.3 Test: ho so cua chinh minh bi loai tru

- [ ] Task 5: Chay full test suite va xac nhan 100% pass

## Dev Notes

- Hien tai `DiscoverView.swift:35` co `await viewModel.loadProfiles(userId: "current_user_id")` - hardcoded string
- `UserDefaultsService` da luu `currentUserId` khi login thanh cong
- DiscoverViewModel da inject `GetDiscoverProfilesUseCase` va `SwipeUseCase`
- GetDiscoverProfilesUseCase goi `matchRepository.getDiscoverProfiles(userId:, limit:)` - userId can de loc
- Nen inject userId vao ViewModel thay vi View de giu separation of concerns
- Co the ket hop story nay voi Story 1.5 (Chat) de dung chung approach inject userId

### Project Structure Notes

- File sua: `Presentation/Screens/Discover/DiscoverView.swift`, `Presentation/Screens/Discover/DiscoverViewModel.swift`
- File sua: `App/DI/PresentationAssembly.swift`
- File sua: `Presentation/Navigation/DiscoverCoordinator.swift` (co the)
- Test sua: `VietMatchTests/Presentation/ViewModels/DiscoverViewModelTests.swift`

### References

- [Source: VietMatch/Presentation/Screens/Discover/DiscoverView.swift#L35 - hardcoded hien tai]
- [Source: VietMatch/Data/DataSources/Local/UserDefaultsService.swift - currentUserId key]
- [Source: docs/architecture.md#7. Presentation Layer - DiscoverViewModel]
- [Source: docs/navigation-deep-dive.md#4.4 DiscoverCoordinator]
- [Source: VietMatch/Domain/UseCases/Matching/GetDiscoverProfilesUseCase.swift]

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
