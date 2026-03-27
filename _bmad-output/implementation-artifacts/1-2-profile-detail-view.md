# Story 1.2: Implement ProfileDetailView

Status: ready-for-dev

## Story

As a **nguoi dung dang kham pha**,
I want **xem chi tiet ho so cua nguoi khac**,
so that **toi co the tim hieu ky hon truoc khi swipe**.

## Acceptance Criteria

1. Hien thi day du thong tin ho so: ten, tuoi, bio, cong viec, truong hoc, so thich
2. Hien thi photo carousel (swipe qua nhieu anh) voi page indicators
3. Hien thi khoang cach (neu co thong tin vi tri)
4. Co cac nut hanh dong: Like, Dislike, Super Like
5. Cac nut hanh dong goi SwipeUseCase tuong ung
6. Hien thi match alert khi co match moi sau khi swipe
7. Co the quay lai man hinh Discover (coordinator.pop())
8. UI tuan thu VietMatch Design System, tuong tu style CardView hien tai

## Tasks / Subtasks

- [ ] Task 1: Tao ProfileDetailViewModel (AC: #1, #4, #5, #6)
  - [ ] 1.1 Tao file `VietMatch/Presentation/Screens/Discover/ProfileDetailViewModel.swift`
  - [ ] 1.2 Khai bao `@Published` properties: `profile`, `isLoading`, `showMatchAlert`, `matchedProfile`
  - [ ] 1.3 Implement `loadProfile(profileId:)` async - goi GetProfileUseCase
  - [ ] 1.4 Implement `swipe(direction:)` async - goi SwipeUseCase, xu ly match result
  - [ ] 1.5 Viet unit tests cho ProfileDetailViewModel

- [ ] Task 2: Tao ProfileDetailView (AC: #1, #2, #3, #7, #8)
  - [ ] 2.1 Tao file `VietMatch/Presentation/Screens/Discover/ProfileDetailView.swift`
  - [ ] 2.2 ScrollView: Photo carousel (TabView + page indicators) su dung Kingfisher/ProfileImageView
  - [ ] 2.3 Info section: Name + Age, Bio, Job/Company, School, Interests (chips/tags)
  - [ ] 2.4 Location/distance section (neu co)
  - [ ] 2.5 Action buttons bar: Dislike (X), Super Like (star), Like (heart) voi icon + mau sac tuong ung

- [ ] Task 3: Ket noi vao DiscoverCoordinator (AC: #7)
  - [ ] 3.1 Thay `Text("Profile Detail")` placeholder bang `ProfileDetailView` trong `DiscoverCoordinator.swift:27`
  - [ ] 3.2 Dang ky ProfileDetailViewModel trong `PresentationAssembly`
  - [ ] 3.3 Them method `profileDetailView(profileId:)` trong DiscoverCoordinator

- [ ] Task 4: Chay full test suite va xac nhan 100% pass

## Dev Notes

- DiscoverCoordinator da co route `.profileDetail(profileId:)` va method `showProfileDetail(profileId:)` - chi can thay placeholder
- Tai su dung components co san: ProfileImageView, GradientButton, EmptyStateView, LoadingView
- Tham khao CardView de giu nhat quan style anh va thong tin
- SwipeUseCase da implement san - goi `execute(swiperId:, swipedUserId:, direction:)`
- Mau sac action buttons: success (#4CAF50) cho Like, error (#F44336) cho Dislike, info (#2196F3) cho Super Like

### Project Structure Notes

- File moi: `Presentation/Screens/Discover/ProfileDetailView.swift`, `Presentation/Screens/Discover/ProfileDetailViewModel.swift`
- Test moi: `VietMatchTests/Presentation/ViewModels/ProfileDetailViewModelTests.swift`
- File sua: `Presentation/Navigation/DiscoverCoordinator.swift`, `App/DI/PresentationAssembly.swift`
- Co the can sua: `App/DI/DomainAssembly.swift` (neu can dang ky them UseCase)

### References

- [Source: docs/architecture.md#MVVM-C Pattern]
- [Source: docs/navigation-deep-dive.md#4.4 DiscoverCoordinator]
- [Source: docs/component-inventory.md#CardView, ProfileImageView]
- [Source: docs/data-models.md#Profile entity]
- [Source: VietMatch/Presentation/Navigation/DiscoverCoordinator.swift#L27 - placeholder hien tai]
- [Source: VietMatch/Domain/UseCases/Matching/SwipeUseCase.swift]

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
