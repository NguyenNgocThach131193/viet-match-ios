# Story 1.5: Đăng Nhập Bằng Apple ID

Status: done

## Story

As a **người dùng iPhone**,
I want **đăng nhập bằng Apple ID**,
so that **tôi có thể sử dụng phương thức xác thực an toàn và riêng tư của Apple**.

## Acceptance Criteria

1. Nhấn "Sign in with Apple" → Apple authentication flow khởi chạy đúng cách với nonce bảo mật
2. Khi Apple flow hoàn tất thành công → Firebase Auth xử lý Apple credential, AuthSessionService persist userId, Firestore tạo/update `users/{userId}`, AppCoordinator route phù hợp
3. Khi flow bị cancel (người dùng bấm X) → không có lỗi, app trở về LoginView bình thường
4. Apple Sign-In với "Hide My Email" → relay email được lưu vào Firestore, app hoạt động bình thường
5. Khi có lỗi → hiển thị alert tiếng Việt "Đăng nhập Apple thất bại. Vui lòng thử lại."
6. Button bị disabled (isLoading = true) khi đang xử lý, ngăn double-tap

## Tasks / Subtasks

- [x] Task 1: Tạo AppleSignInHelper utility
  - [x] 1.1 Tạo `VietMatch/Data/DataSources/Remote/AppleSignInHelper.swift` — `randomNonce(length:)` tạo cryptographically secure hex nonce, `sha256(_:)` trả SHA-256 hex digest
  - [x] 1.2 Thêm vào project.pbxproj đúng group DataSources/Remote

- [x] Task 2: Implement loginWithApple trong AuthRepository
  - [x] 2.1 Thêm `loginWithApple(idToken:nonce:)` vào `AuthRepositoryProtocol`
  - [x] 2.2 Implement trong `AuthRepository` — gọi `authService.signInWithApple(idToken:nonce:)`, tạo User object, persist userId qua UserDefaultsService (giống pattern loginWithGoogle)
  - [x] 2.3 Implement trong `MockAuthRepository` cho testing

- [x] Task 3: Implement trong LoginViewModel
  - [x] 3.1 Thêm `prepareAppleSignIn()` — generate nonce, store raw nonce, return SHA-256 hash cho Apple request
  - [x] 3.2 Thêm `loginWithApple(authorization:)` — extract idToken + nonce từ ASAuthorization, gọi authRepository, guard !isLoading
  - [x] 3.3 Thêm `handleAppleSignInError(_:)` — filter ASAuthorizationError.canceled (silent), các lỗi khác set errorMessage tiếng Việt

- [x] Task 4: Tích hợp SignInWithAppleButton vào LoginView
  - [x] 4.1 Import AuthenticationServices
  - [x] 4.2 Thêm `SignInWithAppleButton(.signIn)` trong socialLoginSection — request scopes [.fullName, .email], nonce từ `viewModel.prepareAppleSignIn()`
  - [x] 4.3 onCompletion handler gọi `viewModel.loginWithApple(authorization:)` hoặc `viewModel.handleAppleSignInError(_:)`
  - [x] 4.4 `.signInWithAppleButtonStyle(.black)`, frame height = buttonHeight, disabled khi isLoading

- [x] Task 5: Entitlements & Capabilities
  - [x] 5.1 Thêm `com.apple.developer.applesignin` vào `VietMatch.entitlements`
  - [x] 5.2 Verify Signing & Capabilities tab có Sign in with Apple

- [x] Task 6: Build & verify
  - [x] 6.1 Build thành công không có warning mới
  - [x] 6.2 Existing test suite pass

## Dev Notes

### Files đã tạo/chỉnh sửa

| File | Thay đổi |
|------|----------|
| `VietMatch/Data/DataSources/Remote/AppleSignInHelper.swift` | Mới — nonce + SHA-256 utility |
| `VietMatch/Domain/Repositories/AuthRepositoryProtocol.swift` | Thêm `loginWithApple(idToken:nonce:)` |
| `VietMatch/Data/Repositories/AuthRepository.swift` | Implement loginWithApple, persist userId |
| `VietMatch/App/DI/Mock/MockAuthRepository.swift` | Stub loginWithApple |
| `VietMatch/Presentation/Screens/Auth/LoginViewModel.swift` | prepareAppleSignIn, loginWithApple, handleAppleSignInError |
| `VietMatch/Presentation/Screens/Auth/LoginView.swift` | SignInWithAppleButton, import AuthenticationServices |
| `VietMatch/App/VietMatch.entitlements` | Apple Sign-In capability |

### Pattern Apple Sign-In (bắt buộc theo)

```swift
// LoginViewModel
private var currentNonce: String?

func prepareAppleSignIn() -> String {
    let nonce = AppleSignInHelper.randomNonce()
    currentNonce = nonce
    return AppleSignInHelper.sha256(nonce)
}

func loginWithApple(authorization: ASAuthorization) async {
    guard !isLoading else { return }
    guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
          let nonce = currentNonce,
          let idTokenData = appleIDCredential.identityToken,
          let idToken = String(data: idTokenData, encoding: .utf8) else { return }
    isLoading = true
    defer { isLoading = false }
    do {
        let user = try await authRepository.loginWithApple(idToken: idToken, nonce: nonce)
        // AppCoordinator observes auth state — navigation tự động
    } catch {
        errorMessage = "Đăng nhập Apple thất bại. Vui lòng thử lại."
        showError = true
    }
}
```

### Lưu ý quan trọng

- Nonce phải được tạo TRƯỚC khi gọi Apple request (trong `onRequest` callback) — không tạo async
- `ASAuthorizationError.canceled` phải được filter silent — không show alert khi user dismiss
- Relay email từ "Hide My Email" hoạt động bình thường qua Firebase Auth
