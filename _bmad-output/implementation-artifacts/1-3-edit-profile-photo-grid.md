# Story 1.3: Implement Photo Grid trong EditProfileView

Status: ready-for-dev

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

- [ ] Task 1: Tao PhotoGridView component (AC: #1, #2, #3, #4)
  - [ ] 1.1 Tao file `VietMatch/Presentation/Components/PhotoGridView.swift`
  - [ ] 1.2 LazyVGrid 3 columns, hien thi anh hien co (Kingfisher) + empty slots
  - [ ] 1.3 Empty slot: dashed border + plus icon, tap mo PhotosPicker
  - [ ] 1.4 Filled slot: anh + nut "X" overlay de xoa
  - [ ] 1.5 Import `PhotosUI` cho PhotosPicker

- [ ] Task 2: Cap nhat ProfileViewModel xu ly photo (AC: #5, #6, #7, #8, #9)
  - [ ] 2.1 Them `@Published` properties: `selectedPhotoItems`, `isUploadingPhoto`
  - [ ] 2.2 Implement `addPhoto(data:)` async - goi UploadPhotoUseCase, cap nhat photos array
  - [ ] 2.3 Implement `removePhoto(url:)` async - goi ProfileRepository.deletePhoto, cap nhat photos array
  - [ ] 2.4 Validation: khong cho xoa khi chi con 1 anh, khong cho them khi da 6 anh
  - [ ] 2.5 Viet unit tests cho cac method moi cua ProfileViewModel

- [ ] Task 3: Tich hop PhotoGridView vao EditProfileView (AC: #1)
  - [ ] 3.1 Thay `// TODO: Photo grid with add/remove` bang PhotoGridView component trong `EditProfileView.swift:15`
  - [ ] 3.2 Truyen viewModel binding cho photos va actions

- [ ] Task 4: Chay full test suite va xac nhan 100% pass

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
