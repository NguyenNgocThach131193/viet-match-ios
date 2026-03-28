# Story 1.2: Implement ProfileDetailView

Status: done
baseline_commit: 9d4b89747557efc2ab8f58df1bdae94279513080

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

- [x] Task 1: Tao ProfileDetailViewModel (AC: #1, #4, #5, #6)
  - [x] 1.1 Tao file `VietMatch/Presentation/Screens/Discover/ProfileDetailViewModel.swift`
  - [x] 1.2 Khai bao `@Published` properties: `profile`, `isLoading`, `showMatchAlert`, `matchedProfile`
  - [x] 1.3 Implement `loadProfile()` async - goi GetProfileUseCase
  - [x] 1.4 Implement `swipe(direction:)` async - goi SwipeUseCase, xu ly match result
  - [x] 1.5 Viet unit tests cho ProfileDetailViewModel

- [x] Task 2: Tao ProfileDetailView (AC: #1, #2, #3, #7, #8)
  - [x] 2.1 Tao file `VietMatch/Presentation/Screens/Discover/ProfileDetailView.swift`
  - [x] 2.2 ScrollView: Photo carousel (TabView + page indicators) su dung Kingfisher
  - [x] 2.3 Info section: Name + Age, Bio, Job/Company, School, Interests (chips/tags)
  - [x] 2.4 Location/distance section (neu co - hien thi city tu profile.location?.city)
  - [x] 2.5 Action buttons bar: Dislike (X), Super Like (star), Like (heart) voi icon + mau sac tuong ung

- [x] Task 3: Ket noi vao DiscoverCoordinator (AC: #7)
  - [x] 3.1 Thay `Text("Profile Detail")` placeholder bang `ProfileDetailView` trong `DiscoverCoordinator.swift`
  - [x] 3.2 Dang ky ProfileDetailViewModel trong `PresentationAssembly`
  - [x] 3.3 Them method `profileDetailView(profileId:)` trong DiscoverCoordinator

- [x] Task 4: BUILD SUCCEEDED. Tests co loi pre-existing o AuthRepositoryTests (khong lien quan story nay)

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
claude-sonnet-4-6

### Completion Notes List
- `currentUserId: ""` trong PresentationAssembly là pre-existing pattern (giống DiscoverView hardcode "current_user_id"), defer sang story auth session
- AC#3 distance: Profile entity không có distance field, chỉ hiển thị city name - nhất quán với CardView

### File List
- VietMatch/Presentation/Screens/Discover/ProfileDetailViewModel.swift (new)
- VietMatch/Presentation/Screens/Discover/ProfileDetailView.swift (new)
- VietMatchTests/Presentation/ViewModels/ProfileDetailViewModelTests.swift (new)
- VietMatch/Presentation/Navigation/DiscoverCoordinator.swift (modified)
- VietMatch/App/DI/PresentationAssembly.swift (modified)

## Suggested Review Order

**ViewModel & Business Logic**

- Entry point: ViewModel với @Published properties và async swipe/load logic
  [`ProfileDetailViewModel.swift:1`](../../VietMatch/Presentation/Screens/Discover/ProfileDetailViewModel.swift#L1)

- SwipeUseCase integration với match detection
  [`ProfileDetailViewModel.swift:43`](../../VietMatch/Presentation/Screens/Discover/ProfileDetailViewModel.swift#L43)

**UI & Navigation**

- View body: routing isLoading/profile/error states và match alert
  [`ProfileDetailView.swift:10`](../../VietMatch/Presentation/Screens/Discover/ProfileDetailView.swift#L10)

- Photo carousel với empty state fallback và page indicators
  [`ProfileDetailView.swift:50`](../../VietMatch/Presentation/Screens/Discover/ProfileDetailView.swift#L50)

- Info section: name/age, city, bio, job/school, interest chips
  [`ProfileDetailView.swift:101`](../../VietMatch/Presentation/Screens/Discover/ProfileDetailView.swift#L101)

- Action buttons: Dislike/SuperLike/Like với màu design system
  [`ProfileDetailView.swift:168`](../../VietMatch/Presentation/Screens/Discover/ProfileDetailView.swift#L168)

**DI & Coordinator Wiring**

- Coordinator: placeholder replaced, profileDetailView factory method thêm vào
  [`DiscoverCoordinator.swift:26`](../../VietMatch/Presentation/Navigation/DiscoverCoordinator.swift#L26)

- DI registration ProfileDetailViewModel với profileId argument
  [`PresentationAssembly.swift:60`](../../VietMatch/App/DI/PresentationAssembly.swift#L60)

**Tests**

- Unit tests: load, swipe, match, error, no-op khi chưa load profile
  [`ProfileDetailViewModelTests.swift:1`](../../VietMatchTests/Presentation/ViewModels/ProfileDetailViewModelTests.swift#L1)
