# Story 1.1: Implement ForgotPasswordView

Status: done

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

- [x] Task 1: Tao ForgotPasswordViewModel (AC: #2, #3, #4, #5, #6)
  - [x] 1.1 Tao file `VietMatch/Presentation/Screens/Auth/ForgotPasswordViewModel.swift`
  - [x] 1.2 Khai bao `@Published` properties: `email`, `isLoading`, `errorMessage`, `showError`, `showSuccess`, `successMessage`
  - [x] 1.3 Implement method `resetPassword()` async - validate email, goi `authRepository.resetPassword(email:)`
  - [x] 1.4 Xu ly cac truong hop loi (email rong, dinh dang sai, khong ton tai)
  - [x] 1.5 Viet unit tests cho ForgotPasswordViewModel

- [x] Task 2: Tao ForgotPasswordView (AC: #1, #4, #7, #8)
  - [x] 2.1 Tao file `VietMatch/Presentation/Screens/Auth/ForgotPasswordView.swift`
  - [x] 2.2 UI: Icon/title header, TextField email, GradientButton "Gui email", trang thai loading
  - [x] 2.3 Alert thanh cong va alert loi
  - [x] 2.4 Su dung VietMatchColors, VietMatchTypography, VietMatchSpacing

- [x] Task 3: Ket noi vao AuthCoordinator (AC: #7)
  - [x] 3.1 Thay `Text("Quen mat khau")` placeholder bang `ForgotPasswordView` trong `AuthCoordinator.swift:33`
  - [x] 3.2 Dang ky ForgotPasswordViewModel trong `PresentationAssembly`
  - [x] 3.3 Them method `forgotPasswordView()` trong AuthCoordinator

- [x] Task 4: Chay full test suite va xac nhan 100% pass

### Review Findings

- [x] [Review][Patch] Double-tap gui concurrent reset requests — them `guard !isLoading` o dau `resetPassword()` [ForgotPasswordViewModel.swift:23]
- [x] [Review][Defer] `observeAuthState` silent fail khi container rong — deferred, pre-existing pattern
- [x] [Review][Defer] Force-unwrap trong DI registrations & coordinator views — deferred, pre-existing pattern toan project
- [x] [Review][Defer] `MainActor.assumeIsolated` trong Swinject DI closure — deferred, pre-existing pattern
- [x] [Review][Defer] Test detection via `XCTestConfigurationFilePath` brittle — deferred, workaround cho pre-existing Firebase crash
- [x] [Review][Defer] `onChange` API fix ve iOS 16 compatible — deferred, pre-existing build error fix

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
Claude Opus 4.6

### Debug Log References
- Fix pre-existing build error: `onChange(of:initial:_:)` iOS 17+ trong PhotoUploadView.swift va ChatView.swift (downgrade to iOS 16 compatible API)
- Fix pre-existing test crash: Firebase crash khi chay unit tests (guard Firebase init khi XCTest, guard AppCoordinator resolve)
- Fix pre-existing: AuthError thieu Equatable conformance cho LoginUseCaseTests

### Completion Notes List
- ✅ Task 1: Tao ResetPasswordUseCase (Domain layer) de giu nhat quan Clean Architecture, tao ForgotPasswordViewModel voi validation email, loading state, success/error handling. 10 unit tests all pass.
- ✅ Task 2: Tao ForgotPasswordView theo VietMatch Design System - header voi icon, email field, GradientButton, alerts thanh cong/loi, nut quay lai.
- ✅ Task 3: Ket noi vao AuthCoordinator (thay placeholder), dang ky DI trong DomainAssembly va PresentationAssembly, them goBack() method.
- ✅ Task 4: Full test suite 27/27 tests pass (10 new + 17 existing).

### Change Log
- 2026-03-27: Implement Story 1.1 - ForgotPasswordView complete
- 2026-04-01: Patch review finding - them guard !isLoading chong double-tap, them unit test

### File List
- VietMatch/Domain/UseCases/Auth/ResetPasswordUseCase.swift (NEW)
- VietMatch/Presentation/Screens/Auth/ForgotPasswordViewModel.swift (NEW)
- VietMatch/Presentation/Screens/Auth/ForgotPasswordView.swift (NEW)
- VietMatchTests/Presentation/ViewModels/ForgotPasswordViewModelTests.swift (NEW)
- VietMatch/Presentation/Navigation/AuthCoordinator.swift (MODIFIED)
- VietMatch/App/DI/DomainAssembly.swift (MODIFIED)
- VietMatch/App/DI/PresentationAssembly.swift (MODIFIED)
- VietMatchTests/Mocks/MockAuthRepository.swift (MODIFIED)
- VietMatch/App/AppDelegate.swift (MODIFIED - guard Firebase init in test)
- VietMatch/App/VietMatchApp.swift (MODIFIED - guard DI init in test)
- VietMatch/Presentation/Navigation/AppCoordinator.swift (MODIFIED - guard resolve in test)
- VietMatch/Domain/UseCases/Auth/LoginUseCase.swift (MODIFIED - AuthError Equatable)
- VietMatch/Presentation/Screens/Onboarding/PhotoUploadView.swift (MODIFIED - iOS 16 onChange)
- VietMatch/Presentation/Screens/Chat/ChatView.swift (MODIFIED - iOS 16 onChange)
