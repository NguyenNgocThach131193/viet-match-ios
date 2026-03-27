# Story 1.1: Implement ForgotPasswordView

Status: ready-for-dev

## Story

As a **nguoi dung da dang ky**,
I want **dat lai mat khau khi quen**,
so that **toi co the truy cap lai tai khoan cua minh**.

## Acceptance Criteria

1. Hien thi form nhap email de dat lai mat khau
2. Validate email khong rong va dung dinh dang truoc khi gui
3. Goi Firebase Auth `resetPassword(email:)` khi nguoi dung nhan nut gui
4. Hien thi trang thai loading khi dang xu ly
5. Hien thi thong bao thanh cong khi email da duoc gui
6. Hien thi thong bao loi khi email khong ton tai hoac loi mang
7. Co nut quay lai man hinh Login
8. UI tuan thu VietMatch Design System (colors, typography, spacing, GradientButton)

## Tasks / Subtasks

- [ ] Task 1: Tao ForgotPasswordViewModel (AC: #2, #3, #4, #5, #6)
  - [ ] 1.1 Tao file `VietMatch/Presentation/Screens/Auth/ForgotPasswordViewModel.swift`
  - [ ] 1.2 Khai bao `@Published` properties: `email`, `isLoading`, `errorMessage`, `showError`, `showSuccess`, `successMessage`
  - [ ] 1.3 Implement method `resetPassword()` async - validate email, goi `authRepository.resetPassword(email:)`
  - [ ] 1.4 Xu ly cac truong hop loi (email rong, dinh dang sai, khong ton tai)
  - [ ] 1.5 Viet unit tests cho ForgotPasswordViewModel

- [ ] Task 2: Tao ForgotPasswordView (AC: #1, #4, #7, #8)
  - [ ] 2.1 Tao file `VietMatch/Presentation/Screens/Auth/ForgotPasswordView.swift`
  - [ ] 2.2 UI: Icon/title header, TextField email, GradientButton "Gui email", trang thai loading
  - [ ] 2.3 Alert thanh cong va alert loi
  - [ ] 2.4 Su dung VietMatchColors, VietMatchTypography, VietMatchSpacing

- [ ] Task 3: Ket noi vao AuthCoordinator (AC: #7)
  - [ ] 3.1 Thay `Text("Quen mat khau")` placeholder bang `ForgotPasswordView` trong `AuthCoordinator.swift:33`
  - [ ] 3.2 Dang ky ForgotPasswordViewModel trong `PresentationAssembly`
  - [ ] 3.3 Them method `forgotPasswordView()` trong AuthCoordinator

- [ ] Task 4: Chay full test suite va xac nhan 100% pass

## Dev Notes

- Coordinator pattern: AuthCoordinator da co route `.forgotPassword` va method `showForgotPassword()` - chi can thay placeholder
- AuthRepositoryProtocol da co method `resetPassword(email:)` - chi can goi tu ViewModel
- Tham khao LoginView/LoginViewModel de giu nhat quan UI va pattern
- ViewModel phai dung `@MainActor` va inject UseCase hoac Repository qua Swinject
- Hien tai chua co ResetPasswordUseCase - can tao hoac goi truc tiep repository (xem xet tao UseCase de giu nhat quan Clean Architecture)

### Project Structure Notes

- File moi: `Presentation/Screens/Auth/ForgotPasswordView.swift`, `Presentation/Screens/Auth/ForgotPasswordViewModel.swift`
- Test moi: `VietMatchTests/Presentation/ViewModels/ForgotPasswordViewModelTests.swift`
- File sua: `Presentation/Navigation/AuthCoordinator.swift`, `App/DI/PresentationAssembly.swift`
- Co the can tao: `Domain/UseCases/Auth/ResetPasswordUseCase.swift`, dang ky trong `DomainAssembly.swift`

### References

- [Source: docs/architecture.md#MVVM-C Pattern]
- [Source: docs/navigation-deep-dive.md#4.2 AuthCoordinator]
- [Source: docs/component-inventory.md#GradientButton]
- [Source: docs/development-guide.md#5. Kien Truc & Conventions]
- [Source: VietMatch/Presentation/Navigation/AuthCoordinator.swift#L33 - placeholder hien tai]
- [Source: VietMatch/Domain/Repositories/AuthRepositoryProtocol.swift - resetPassword method]

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
