# Story 1.4: Implement Google Sign-In

Status: ready-for-dev

## Story

As a **nguoi dung moi**,
I want **dang nhap bang tai khoan Google**,
so that **toi co the truy cap ung dung nhanh chong ma khong can tao tai khoan moi**.

## Acceptance Criteria

1. Tich hop GoogleSignIn SDK qua Swift Package Manager
2. Nut "Dang nhap bang Google" hien thi tren LoginView
3. Khi nhan nut, hien thi Google Sign-In flow (GIDSignIn)
4. Sau khi xac thuc Google thanh cong, tao/cap nhat Firebase Auth credential
5. Tao document trong Firestore collection "users" neu la nguoi dung moi
6. Chuyen huong dung: nguoi dung moi → Onboarding, nguoi dung cu → MainTab
7. Hien thi loading indicator khi dang xu ly
8. Xu ly loi: nguoi dung huy, loi mang, loi Firebase

## Tasks / Subtasks

- [ ] Task 1: Tich hop GoogleSignIn SDK (AC: #1)
  - [ ] 1.1 Them GoogleSignIn-iOS package qua SPM (URL: https://github.com/google/GoogleSignIn-iOS)
  - [ ] 1.2 Cau hinh `GIDClientID` tu `GoogleService-Info.plist` trong AppDelegate hoac Info.plist
  - [ ] 1.3 Them URL scheme cho Google Sign-In trong project.yml / Info.plist

- [ ] Task 2: Implement FirebaseAuthService.signInWithGoogle() (AC: #3, #4)
  - [ ] 2.1 Sua file `VietMatch/Data/DataSources/Remote/FirebaseAuthService.swift`
  - [ ] 2.2 Thay `throw AuthError.unknown(...)` bang logic thuc te:
    - Lay rootViewController
    - Goi `GIDSignIn.sharedInstance.signIn(withPresenting:)`
    - Tao GoogleAuthProvider.credential tu idToken + accessToken
    - Goi `Auth.auth().signIn(with: credential)`
  - [ ] 2.3 Xu ly loi: user cancelled, network error

- [ ] Task 3: Cap nhat AuthRepository xu ly Google Sign-In (AC: #5, #6)
  - [ ] 3.1 Sua `AuthRepository.loginWithGoogle()` - goi FirebaseAuthService, tao/cap nhat user document
  - [ ] 3.2 Kiem tra user da ton tai trong Firestore chua de set `profileCompleted` dung
  - [ ] 3.3 Viet unit tests cho Google sign-in flow (mock GIDSignIn)

- [ ] Task 4: Cap nhat LoginView UI (AC: #2, #7, #8)
  - [ ] 4.1 Them nut "Dang nhap bang Google" voi Google icon trong LoginView
  - [ ] 4.2 Style: nut trang voi vien, Google logo ben trai, text ben phai
  - [ ] 4.3 Goi `viewModel.loginWithGoogle()` khi nhan nut

- [ ] Task 5: Cap nhat LoginViewModel (AC: #7, #8)
  - [ ] 5.1 Them method `loginWithGoogle()` async
  - [ ] 5.2 Xu ly loading state va error handling
  - [ ] 5.3 Viet unit tests

- [ ] Task 6: Chay full test suite va xac nhan 100% pass

## Dev Notes

- FirebaseAuthService da co method stub `signInWithGoogle()` - can thay bang implementation thuc
- AuthRepositoryProtocol da co method `loginWithGoogle() async throws -> User`
- Can them dependency: `GoogleSignIn` (https://github.com/google/GoogleSignIn-iOS)
- Phai cau hinh OAuth client ID trong Firebase Console va GoogleService-Info.plist
- Can lay `rootViewController` de present Google Sign-In - su dung UIApplication extension
- LoginView da co nut Apple Sign-In - them Google button tuong tu

### Project Structure Notes

- File sua: `Data/DataSources/Remote/FirebaseAuthService.swift`, `Data/Repositories/AuthRepository.swift`
- File sua: `Presentation/Screens/Auth/LoginView.swift`, `Presentation/Screens/Auth/LoginViewModel.swift`
- File sua: `App/AppDelegate.swift` (cau hinh GIDSignIn), `project.yml` (URL schemes)
- Test moi/sua: `VietMatchTests/Presentation/ViewModels/LoginViewModelTests.swift`

### References

- [Source: docs/firebase-setup.md#3.1 Firebase Authentication]
- [Source: docs/project-overview.md#1. Xac Thuc - Google dang phat trien]
- [Source: docs/architecture.md#5. Domain Layer - AuthRepositoryProtocol]
- [Source: VietMatch/Data/DataSources/Remote/FirebaseAuthService.swift#L54 - TODO hien tai]
- [Source: VietMatch/Domain/Repositories/AuthRepositoryProtocol.swift - loginWithGoogle]

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
