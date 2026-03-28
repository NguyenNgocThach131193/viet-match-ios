# Story 1.3: Implement Photo Grid trong EditProfileView

Status: done
baseline_commit: e94dd607088c464c1a0a3f1443d578cc7e746807

## Story

As a **nguoi dung da dang ky**,
I want **quan ly anh ho so (them, xoa, sap xep) trong man hinh chinh sua**,
so that **toi co the cap nhat anh dai dien de thu hut nguoi khac**.

## Acceptance Criteria

1. Hien thi grid 3x2 (6 slots) hien thi anh hien tai cua nguoi dung
2. Cac slot trong hien thi icon "+" va duong vien dash de them anh moi
3. Nhan vao slot trong mo PhotosPicker de chon anh tu thu vien
4. Nhan vao nut "X" tren anh da co de xoa anh
5. Anh duoc upload len Firebase Storage qua UploadPhotoUseCase
6. Anh bi xoa duoc xoa khoi Firebase Storage qua ProfileRepository
7. Hien thi loading indicator khi dang upload
8. Gioi han toi da 6 anh (Constants.App.maxPhotos)
9. Phai co it nhat 1 anh de luu ho so

## Tasks / Subtasks

- [x] Task 1: Tao PhotoGridView component (AC: #1, #2, #3, #4)
  - [x] 1.1 Tao file `VietMatch/Presentation/Components/PhotoGridView.swift`
  - [x] 1.2 LazyVGrid 3 columns, hien thi anh hien co (Kingfisher) + empty slots
  - [x] 1.3 Empty slot: dashed border + plus icon, tap mo PhotosPicker
  - [x] 1.4 Filled slot: anh + nut "X" overlay de xoa
  - [x] 1.5 Import `PhotosUI` cho PhotosPicker

- [x] Task 2: Cap nhat ProfileViewModel xu ly photo (AC: #5, #6, #7, #8, #9)
  - [x] 2.1 Them `@Published` properties: `isUploadingPhoto`
  - [x] 2.2 Implement `addPhoto(data:)` async - goi UploadPhotoUseCase, cap nhat photos array
  - [x] 2.3 Implement `removePhoto(url:)` async - goi ProfileRepository.deletePhoto, cap nhat photos array
  - [x] 2.4 Validation: khong cho xoa khi chi con 1 anh, khong cho them khi da 6 anh
  - [x] 2.5 Viet unit tests cho cac method moi cua ProfileViewModel

- [x] Task 3: Tich hop PhotoGridView vao EditProfileView (AC: #1)
  - [x] 3.1 Thay `// TODO: Photo grid with add/remove` bang PhotoGridView component trong `EditProfileView.swift:15`
  - [x] 3.2 Truyen viewModel binding cho photos va actions

- [x] Task 4: Chay full test suite va xac nhan 100% pass

## Dev Notes

- UploadPhotoUseCase da implement san - goi `execute(userId:, imageData:)`
- ProfileRepositoryProtocol da co method `deletePhoto(userId:, photoUrl:)`
- Tham khao OnboardingView/PhotoUploadView cho pattern chon anh tuong tu
- Firebase Storage path: `photos/{userId}/{UUID}.jpg`
- Su dung `PhotosUI.PhotosPicker` (iOS 16+) de chon anh
- Gioi han kich thuoc anh: compress JPEG truoc khi upload

### Project Structure Notes

- File moi: `Presentation/Components/PhotoGridView.swift`
- Test sua: `VietMatchTests/Presentation/ViewModels/` (them test cho ProfileViewModel photo methods)
- File sua: `Presentation/Screens/Profile/EditProfileView.swift`, `Presentation/Screens/Profile/ProfileViewModel.swift` (co the)

### References

- [Source: docs/component-inventory.md#PhotoUploadView (Onboarding)]
- [Source: docs/architecture.md#6. Data Layer - Firebase Storage]
- [Source: docs/data-models.md#Profile - photos array]
- [Source: VietMatch/Presentation/Screens/Profile/EditProfileView.swift#L15 - TODO hien tai]
- [Source: VietMatch/Domain/UseCases/Profile/UploadPhotoUseCase.swift]
- [Source: VietMatch/Core/Utils/Constants.swift - maxPhotos = 6]

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List

## Suggested Review Order

### Component mới — entry point chính

- PhotoGridView: 3x2 grid, logic slot filled/empty, isolated EmptySlotView với @State riêng
  [`PhotoGridView.swift:1`](../../VietMatch/Presentation/Components/PhotoGridView.swift#L1)

### ViewModel — business logic photo

- addPhoto: guard, defer, JPEG compression, error nếu image invalid; removePhoto: isDeletingPhoto guard
  [`ProfileViewModel.swift:71`](../../VietMatch/Presentation/Screens/Profile/ProfileViewModel.swift#L71)

### Tích hợp UI

- EditProfileView: thay TODO bằng PhotoGridView, truyền isUploadingPhoto + isDeletingPhoto
  [`EditProfileView.swift:15`](../../VietMatch/Presentation/Screens/Profile/EditProfileView.swift#L15)

### Storage bug fix (critical patch)

- FirebaseStorageService: deleteImage dùng reference(forURL:) thay .child() khi path là HTTPS URL
  [`FirebaseStorageService.swift:23`](../../VietMatch/Data/DataSources/Remote/FirebaseStorageService.swift#L23)

### DI

- PresentationAssembly: inject currentUserId, uploadPhotoUseCase, profileRepository vào ProfileViewModel
  [`PresentationAssembly.swift:109`](../../VietMatch/App/DI/PresentationAssembly.swift#L109)

### Tests & Mocks

- ProfileViewModelTests: 8 test cases bao gồm invalid image data, upload failure, remove guard
  [`ProfileViewModelTests.swift:1`](../../VietMatchTests/Presentation/ViewModels/ProfileViewModelTests.swift#L1)

- MockProfileRepository: thêm deletePhotoCallCount + deletePhotoResult controllable
  [`MockProfileRepository.swift:13`](../../VietMatchTests/Mocks/MockProfileRepository.swift#L13)
