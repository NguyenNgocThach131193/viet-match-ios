# Story 1.9: Photo Save Flow — Consistent Photo Lifecycle va Conditional Dismiss

Status: done

## Story

As a **nguoi dung chinh sua profile**,
I want **photo upload/delete duoc xu ly nhat quan va thay doi chi luu khi thanh cong**,
so that **khong co orphaned files, va toi thay duoc loi neu save that bai thay vi bi dismiss**.

## Acceptance Criteria

1. `removePhoto()` su dung `DeletePhotoUseCaseProtocol` thay vi goi `profileRepository.deletePhoto` truc tiep
2. `DeletePhotoUseCase` va `DeletePhotoUseCaseProtocol` duoc tao theo dung pattern cua `UploadPhotoUseCase`
3. `EditProfileView` chi dismiss khi `saveProfile()` thanh cong — hien thi error neu that bai
4. `EditProfileView` hien thi `errorMessage` tu ProfileViewModel khi co loi
5. Tat ca unit tests hien tai van pass
6. Unit tests moi cover DeletePhotoUseCase va conditional dismiss behavior

## Tasks / Subtasks

- [x] Task 1: Tao DeletePhotoUseCaseProtocol va DeletePhotoUseCase (AC: #1, #2)
  - [x] 1.1 Tao `VietMatch/Domain/UseCases/Profile/DeletePhotoUseCase.swift`
  - [x] 1.2 Dinh nghia `DeletePhotoUseCaseProtocol` voi method `execute(userId: String, photoURL: String) async throws`
  - [x] 1.3 Implement `DeletePhotoUseCase` goi `profileRepository.deletePhoto(userId:photoURL:)` — giong pattern UploadPhotoUseCase
  - [x] 1.4 Viet unit test cho DeletePhotoUseCase

- [x] Task 2: Register DeletePhotoUseCase trong DI (AC: #2)
  - [x] 2.1 Kiem tra `*Assembly.swift` files — tim DomainAssembly hoac tuong duong noi UploadPhotoUseCase duoc register
  - [x] 2.2 Register `DeletePhotoUseCaseProtocol` -> `DeletePhotoUseCase` theo cung pattern
  - [x] 2.3 Inject `DeletePhotoUseCaseProtocol` vao ProfileViewModel thay vi `profileRepository`

- [x] Task 3: Cap nhat ProfileViewModel.removePhoto() (AC: #1)
  - [x] 3.1 Sua `VietMatch/Presentation/Screens/Profile/ProfileViewModel.swift`
  - [x] 3.2 Them `deletePhotoUseCase: DeletePhotoUseCaseProtocol` vao init
  - [x] 3.3 Trong `removePhoto()` (line 89-103): thay `profileRepository.deletePhoto(...)` bang `deletePhotoUseCase.execute(...)`
  - [x] 3.4 Cap nhat unit tests — mock DeletePhotoUseCaseProtocol thay vi mock repository

- [x] Task 4: Fix EditProfileView conditional dismiss (AC: #3, #4)
  - [x] 4.1 Sua `VietMatch/Presentation/Screens/Profile/EditProfileView.swift`
  - [x] 4.2 Thay doi save button action (line 32-46):
    - Goi `await viewModel.saveProfile()`
    - Kiem tra `viewModel.errorMessage == nil` truoc khi goi `dismiss()`
    - Neu co error, KHONG dismiss — error se hien thi tu errorMessage
  - [x] 4.3 Them hien thi error trong EditProfileView (neu chua co) — dung `.alert` hoac Text voi `viewModel.errorMessage`
  - [x] 4.4 Dam bao `saveProfile()` return `Bool` hoac set `errorMessage = nil` khi thanh cong de phan biet

- [x] Task 5: Full test suite pass (AC: #5, #6)
  - [x] 5.1 Chay toan bo test suite — dam bao 0 test failures moi
  - [x] 5.2 Build thanh cong

### Review Findings

- [x] [Review][Patch] Tests khong verify captured arguments (userId, photoURL) truyen vao MockDeletePhotoUseCase [ProfileViewModelTests.swift] — FIXED: them XCTAssertEqual cho lastUserId va lastPhotoURL
- [x] [Review][Defer] Force-unwrap trong DI container registration — pre-existing pattern across tat ca Assembly files, khong phai do story nay
- [x] [Review][Defer] Race giua photo operations (add/remove) va saveProfile() — PHOTO-1/EC-7, da duoc ghi nhan la deferred work rieng
- [x] [Review][Defer] errorMessage == nil la success signal fragile — can thay doi saveProfile() return type, vuot scope story nay
- [x] [Review][Defer] removePhoto URL mismatch dan den silent no-op — pre-existing edge case

## Dev Notes

### Pattern can theo — UploadPhotoUseCase reference

```swift
// Domain/UseCases/Profile/UploadPhotoUseCase.swift — REFERENCE PATTERN
protocol UploadPhotoUseCaseProtocol {
    func execute(userId: String, imageData: Data) async throws -> String
}

class UploadPhotoUseCase: UploadPhotoUseCaseProtocol {
    private let profileRepository: ProfileRepositoryProtocol
    
    init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }
    
    func execute(userId: String, imageData: Data) async throws -> String {
        return try await profileRepository.uploadPhoto(userId: userId, imageData: imageData)
    }
}
```

**DeletePhotoUseCase PHAI theo chinh xac pattern nay:**

```swift
protocol DeletePhotoUseCaseProtocol {
    func execute(userId: String, photoURL: String) async throws
}

class DeletePhotoUseCase: DeletePhotoUseCaseProtocol {
    private let profileRepository: ProfileRepositoryProtocol
    
    init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }
    
    func execute(userId: String, photoURL: String) async throws {
        try await profileRepository.deletePhoto(userId: userId, photoURL: photoURL)
    }
}
```

### Hien trang code

**ProfileViewModel** (`ProfileViewModel.swift`):
- `addPhoto()` line 72-87 — dung `uploadPhotoUseCase.execute()` ✅
- `removePhoto()` line 89-103 — goi `profileRepository.deletePhoto()` truc tiep ❌
- Da co `profileRepository` property — sau khi chuyen sang UseCase, co the xoa neu khong con dung cho viec khac

**EditProfileView** (`EditProfileView.swift`):
- Line 32-46: `dismiss()` goi unconditionally sau `saveProfile()` ❌
- Khong co hien thi `errorMessage` ❌
- `saveProfile()` set `viewModel.errorMessage` khi loi nhung View khong doc

**ProfileViewModel.saveProfile():**
- Can kiem tra: co return Bool khong? Hay chi set errorMessage?
- Neu chi set errorMessage, kiem tra `viewModel.errorMessage == nil` sau khi goi

### Luu y quan trong

- **KHONG fix orphaned photo issue (PHOTO-1/EC-7)** — do la design decision lon hon (auto-save vs discard warning), de danh cho story rieng
- Chi fix 3 items: DeletePhotoUseCase (PHOTO-2), conditional dismiss (PHOTO-3), va error display
- DI registration: tim file Assembly noi `UploadPhotoUseCaseProtocol` duoc register — them `DeletePhotoUseCaseProtocol` ngay canh no
- Xcode project file (`project.pbxproj`) can duoc cap nhat khi them file moi

### Project Structure Notes

- UseCases: `VietMatch/Domain/UseCases/Profile/` — them DeletePhotoUseCase.swift o day
- DI: Tim `DomainAssembly.swift` hoac `UseCaseAssembly.swift` — register UseCase
- Tests: `VietMatchTests/Domain/UseCases/` — tao DeletePhotoUseCaseTests.swift
- Mocks: `VietMatchTests/Mocks/` — tao MockDeletePhotoUseCase

### References

- [Source: ProfileViewModel.swift#L89-103 — removePhoto() goi repository truc tiep]
- [Source: ProfileViewModel.swift#L72-87 — addPhoto() dung UseCase — reference pattern]
- [Source: EditProfileView.swift#L32-46 — dismiss() unconditional]
- [Source: UploadPhotoUseCase.swift — pattern can theo]
- [Source: deferred-work.md — PHOTO-1, PHOTO-2, PHOTO-3]

## Dev Agent Record

### Agent Model Used
Claude Opus 4.6 (1M context)

### Debug Log References
- Build: BUILD SUCCEEDED
- Tests: 72 tests, 0 failures — TEST SUCCEEDED

### Completion Notes List
- ✅ Task 1: Tao DeletePhotoUseCase va DeletePhotoUseCaseProtocol theo dung pattern UploadPhotoUseCase. Unit test cover success va failure cases.
- ✅ Task 2: Register DeletePhotoUseCaseProtocol trong DomainAssembly. Inject vao ProfileViewModel thay profileRepository trong PresentationAssembly.
- ✅ Task 3: Cap nhat ProfileViewModel — thay profileRepository bang deletePhotoUseCase trong removePhoto(). Xoa profileRepository dependency vi khong con dung. Cap nhat tat ca tests dung MockDeletePhotoUseCase.
- ✅ Task 4: Fix EditProfileView — clear errorMessage truoc khi save, chi dismiss khi errorMessage == nil. Them .alert hien thi loi khi saveProfile that bai.
- ✅ Task 5: Full test suite 72/72 pass, build thanh cong.

### File List
- VietMatch/Domain/UseCases/Profile/DeletePhotoUseCase.swift (NEW)
- VietMatch/Presentation/Screens/Profile/ProfileViewModel.swift (MODIFIED)
- VietMatch/Presentation/Screens/Profile/EditProfileView.swift (MODIFIED)
- VietMatch/App/DI/DomainAssembly.swift (MODIFIED)
- VietMatch/App/DI/PresentationAssembly.swift (MODIFIED)
- VietMatchTests/Domain/UseCases/DeletePhotoUseCaseTests.swift (NEW)
- VietMatchTests/Mocks/MockDeletePhotoUseCase.swift (NEW)
- VietMatchTests/Presentation/ViewModels/ProfileViewModelTests.swift (MODIFIED)
- VietMatch.xcodeproj/project.pbxproj (MODIFIED)
