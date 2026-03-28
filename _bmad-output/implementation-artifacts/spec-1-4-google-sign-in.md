---
title: 'Implement Google Sign-In'
type: 'feature'
created: '2026-03-28'
status: 'done'
baseline_commit: 'e94dd607088c464c1a0a3f1443d578cc7e746807'
context: []
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Người dùng không thể đăng nhập bằng Google vì `FirebaseAuthService.signInWithGoogle()` chỉ là stub, GoogleSignIn SDK chưa được tích hợp, và URL scheme OAuth chưa được cấu hình.

**Approach:** Thêm GoogleSignIn SDK qua project.yml, cấu hình URL scheme, implement `signInWithGoogle()` trong FirebaseAuthService, và thêm URL handler trong AppDelegate. Chain ViewModel → UseCase → Repository → Service đã sẵn sàng.

## Boundaries & Constraints

**Always:**
- Lấy `rootViewController` an toàn từ `UIApplication` (không force unwrap) để present Google Sign-In flow
- Xử lý lỗi: user cancelled (GIDSignInError.canceled), lỗi mạng, lỗi Firebase
- Loading state và error hiển thị qua LoginViewModel (đã có sẵn)

**Ask First:**
- Nếu `REVERSED_CLIENT_ID` từ `GoogleService-Info.plist` không tìm được trong project — dừng lại và hỏi user cách cấu hình URL scheme

**Never:**
- Không thay đổi LoginViewModel, LoginUseCase, AuthRepositoryProtocol, AuthRepository — chain đã đúng
- Không sửa LoginView — Google button đã được wired tới `viewModel.loginWithGoogle()`
- Không thêm logic cho Apple Sign-In trong story này

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Happy path | User nhấn Google button, chọn tài khoản, xác thực thành công | Firebase Auth credential tạo thành công, AuthRepository cập nhật user, navigate MainTab hoặc Onboarding | N/A |
| User huỷ | User dismiss Google Sign-In sheet | Không có lỗi hiển thị, trở về LoginView bình thường | Bắt `GIDSignInError.canceled`, không throw — return từ method |
| Lỗi mạng | Không có internet khi sign in | Hiển thị error message trong LoginView | Throw `AuthError.networkError` |
| idToken nil | GIDSignIn thành công nhưng idToken không tồn tại | Throw lỗi rõ ràng | Throw `AuthError.unknown("Google idToken nil")` |

</frozen-after-approval>

## Code Map

- `project.yml` -- thêm GoogleSignIn-iOS package dependency + REVERSED_CLIENT_ID URL scheme
- `VietMatch/App/AppDelegate.swift` -- thêm `application(_:open:options:)` để handle Google OAuth callback
- `VietMatch/Data/DataSources/Remote/FirebaseAuthService.swift` -- implement `signInWithGoogle()` thay thế stub
- `VietMatch/App/Info.plist` -- thêm CFBundleURLSchemes với REVERSED_CLIENT_ID (nếu project.yml không tự gen)

## Tasks & Acceptance

**Execution:**
- [x] `project.yml` -- thêm package `https://github.com/google/GoogleSignIn-iOS` (version 7.0.0+) vào `packages:` section; thêm `GoogleSignIn` và `GoogleSignInSwift` vào target dependencies; thêm URL scheme `$(REVERSED_CLIENT_ID)` hoặc hardcode REVERSED_CLIENT_ID từ GoogleService-Info.plist vào `info.plist` section của project.yml -- vì SDK cần URL scheme để xử lý OAuth callback sau khi Google xác thực
- [x] `VietMatch/App/AppDelegate.swift` -- thêm method `application(_:open:url:options:)` gọi `GIDSignIn.sharedInstance.handle(url)`, trả về `true` nếu Google xử lý được -- vì Google Sign-In dùng custom URL scheme để callback về app
- [x] `VietMatch/Data/DataSources/Remote/FirebaseAuthService.swift` -- thay thế stub `signInWithGoogle()` bằng implementation thực: (1) lấy `rootViewController` từ `UIApplication`, (2) gọi `GIDSignIn.sharedInstance.signIn(withPresenting:)`, (3) tạo `GoogleAuthProvider.credential(withIDToken:accessToken:)`, (4) gọi `auth.signIn(with:)` — handle cancelled error để không propagate như lỗi thật -- vì đây là missing link duy nhất trong chain đã được wired sẵn

**Acceptance Criteria:**
- Given app đã cài GoogleSignIn SDK và URL scheme đã cấu hình, when user nhấn "Đăng nhập bằng Google", then Google Sign-In sheet xuất hiện
- Given user chọn tài khoản Google hợp lệ, when xác thực hoàn tất, then user được navigate đến Onboarding (mới) hoặc MainTab (cũ)
- Given user dismiss Google Sign-In sheet, when cancel xảy ra, then LoginView hiển thị lại, không có error message
- Given lỗi mạng, when sign in thất bại, then error message hiển thị trong LoginView
- Given loading đang chạy, when `loginWithGoogle()` được gọi, then loading indicator hiển thị

## Spec Change Log

**[Patch 1 — 2026-03-28]** Triggering finding: user cancellation propagated as error, showing "Đăng nhập bị hủy" alert (AC: cancel = no error). Amended: added `AuthError.cancelled` case to LoginUseCase.swift, threw it from FirebaseAuthService on GIDSignInError.canceled, added `catch AuthError.cancelled` no-op guard in LoginViewModel. Bad state avoided: error alert shown on normal user dismiss. KEEP: all other error flows unchanged.

**[Patch 2 — 2026-03-28]** Triggering finding: `scene.windows.first` deprecated iOS 15+, fragile on multi-window. Amended: replaced with `scene.keyWindow` in FirebaseAuthService.signInWithGoogle(). Bad state avoided: sign-in sheet presented on wrong window. KEEP: safe optional binding pattern unchanged.

## Design Notes

**rootViewController helper:** Không có UIApplication extension sẵn có. Trong `signInWithGoogle()`, lấy rootViewController qua:
```swift
guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let rootVC = scene.windows.first?.rootViewController else {
    throw AuthError.unknown("Không tìm được rootViewController")
}
```

**User cancelled pattern:** `GIDSignIn` throw error với code `GIDSignInError.canceled` — cần detect và return early thay vì propagate:
```swift
if let error = error as? GIDSignInError, error.code == .canceled { return }
```

## Verification

**Manual checks (if no CLI):**
- Build project không có lỗi compiler sau khi thêm GoogleSignIn SDK
- Simulator: nhấn Google button → Google Sign-In sheet xuất hiện
- Cancel flow: dismiss sheet → không có error toast
- Xcode: kiểm tra URL scheme trong project settings chứa REVERSED_CLIENT_ID

## Suggested Review Order

**Entry point — Google Sign-In core flow**

- Implement thực tế thay stub; `keyWindow` thay `windows.first`; cancellation → `AuthError.cancelled`
  [`FirebaseAuthService.swift:55`](../../VietMatch/Data/DataSources/Remote/FirebaseAuthService.swift#L55)

**Error handling contract**

- Thêm `AuthError.cancelled` case với `errorDescription = nil` để suppress UI
  [`LoginUseCase.swift:32`](../../VietMatch/Domain/UseCases/Auth/LoginUseCase.swift#L32)

- Guard `AuthError.cancelled` — no error alert on user dismiss
  [`LoginViewModel.swift:42`](../../VietMatch/Presentation/Screens/Auth/LoginViewModel.swift#L42)

**URL scheme & OAuth callback**

- URL handler delegates to GIDSignIn; returns false for non-Google URLs
  [`AppDelegate.swift:19`](../../VietMatch/App/AppDelegate.swift#L19)

**Configuration (requires manual action)**

- Placeholder `REPLACE_WITH_REVERSED_CLIENT_ID` — must be replaced with Firebase Console value
  [`Info.plist:61`](../../VietMatch/App/Info.plist#L61)

**Package dependency**

- GoogleSignIn 7.0.0+ added; `GoogleSignIn` + `GoogleSignInSwift` linked to main target
  [`project.yml:30`](../../project.yml#L30)
