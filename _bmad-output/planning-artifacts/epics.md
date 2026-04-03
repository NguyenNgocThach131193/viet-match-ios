---
stepsCompleted: ["step-01-validate-prerequisites", "step-01-complete", "step-02-design-epics", "step-03-create-stories", "step-04-final-validation"]
inputDocuments:
  - "_bmad-output/planning-artifacts/prd.md"
  - "_bmad-output/planning-artifacts/architecture.md"
  - "_bmad-output/planning-artifacts/ux-design.md"
  - "_bmad-output/planning-artifacts/epics.md (reference)"
---

# VietMatch - Epic Breakdown

## Overview

Tài liệu này cung cấp bản phân rã epics và stories đầy đủ cho VietMatch, phân tách các yêu cầu từ PRD, UX Design và Architecture thành các stories có thể thực hiện được.

## Requirements Inventory

### Functional Requirements

**Module 1: Xác Thực (Authentication)**

FR1: Hệ thống cho phép người dùng đăng ký tài khoản mới bằng email và mật khẩu. Mật khẩu phải tối thiểu 6 ký tự. Email phải hợp lệ (format chuẩn).

FR2: Hệ thống cho phép người dùng đăng nhập bằng email và mật khẩu đã đăng ký. Hiển thị thông báo lỗi tiếng Việt khi đăng nhập thất bại.

FR3: Hệ thống cho phép người dùng đăng nhập bằng tài khoản Google (Google Sign-In). Firebase lưu userId sau khi đăng nhập thành công.

FR4: Hệ thống cho phép người dùng đăng nhập bằng Apple ID (Sign in with Apple). Firebase lưu userId sau khi đăng nhập thành công.

FR5: Hệ thống cung cấp chức năng quên mật khẩu: người dùng nhập email và nhận link đặt lại mật khẩu qua email.

FR6: Người dùng có thể xóa tài khoản vĩnh viễn từ Settings. Thao tác xóa xóa cả Firebase Auth record lẫn dữ liệu Firestore (users, profiles).

FR7: Người dùng có thể đăng xuất khỏi ứng dụng. Sau khi đăng xuất, app điều hướng về màn hình đăng nhập.

FR8: Hệ thống tự động khôi phục session đăng nhập khi khởi động lại app (cold start restore). userId phải được re-persist sau khi Firebase khôi phục session.

**Module 2: Onboarding & Hồ Sơ**

FR9: Người dùng mới (chưa hoàn thành onboarding) được dẫn qua 4 bước onboarding theo thứ tự: Bước 1: Nhập tên, tuổi (18–100), bio (tối đa 500 ký tự); Bước 2: Chọn giới tính (Nam / Nữ / Khác) và giới tính muốn gặp; Bước 3: Tải lên ảnh (1–6 ảnh, bắt buộc ít nhất 1); Bước 4: Chọn sở thích (tối đa 15 lựa chọn).

FR10: Người dùng có thể tải lên tối đa 6 ảnh vào hồ sơ. Ảnh được upload lên Firebase Storage và URL lưu trong Firestore (profiles collection).

FR11: Người dùng có thể chỉnh sửa hồ sơ sau onboarding: tên, bio, job title, công ty, trường học.

FR12: Người dùng có thể thêm, xóa, và sắp xếp lại ảnh trong hồ sơ. Xóa ảnh xóa luôn file trên Firebase Storage và cập nhật Firestore.

FR13: Hệ thống cập nhật vị trí địa lý của người dùng (latitude, longitude, city) vào Firestore profile.

**Module 3: Khám Phá (Discover)**

FR14: Ứng dụng hiển thị danh sách hồ sơ người dùng khác dạng stack cards có thể swipe. Mỗi lần tải tối đa 20 hồ sơ.

FR15: Người dùng có thể swipe phải (Like), swipe trái (Dislike), hoặc nhấn nút Super Like trên một hồ sơ. Mỗi swipe được lưu vào Firestore (swipes collection).

FR16: Khi hai người dùng cùng Like nhau, hệ thống tạo match record trong Firestore và hiển thị match alert ngay lập tức.

FR17: Mỗi card hiển thị photo carousel (có thể swipe qua các ảnh), tên, tuổi, job title, khoảng cách (km), và bio.

FR18: Người dùng có thể nhấn vào card để xem hồ sơ chi tiết (ProfileDetailView) với đầy đủ thông tin và tất cả ảnh.

FR19: Từ ProfileDetailView, người dùng có thể Like, Dislike hoặc Super Like. Nếu tạo match, alert điều hướng trực tiếp tới màn hình chat.

FR20: Khi hết cards, ứng dụng tự động tải thêm hồ sơ. Không có duplicate profiles trong cùng một session.

FR21: Chức năng swipe có guard chống concurrent requests: không thể swipe khi đang xử lý swipe trước đó.

**Module 4: Kết Nối (Matches)**

FR22: Tab Matches hiển thị hai phần: "Matches mới" (horizontal scroll, compact style) và "Tất cả matches" (danh sách dọc, full style).

FR23: Badge "NEW" hiển thị trên match card cho matches chưa nhắn tin.

FR24: Người dùng có thể nhấn vào match để bắt đầu hoặc tiếp tục cuộc trò chuyện.

FR25: Người dùng có thể hủy match (unmatch) từ màn hình chat hoặc danh sách matches.

**Module 5: Trò Chuyện (Chat)**

FR26: Màn hình Conversations hiển thị danh sách tất cả cuộc trò chuyện, sắp xếp theo thời gian tin nhắn gần nhất. Hiển thị unread count badge cho mỗi cuộc trò chuyện.

FR27: Người dùng có thể gửi tin nhắn text trong chat. Tin nhắn rỗng (sau khi trim) không được gửi.

FR28: Người dùng có thể gửi ảnh (image) trong chat.

FR29: Người dùng có thể gửi GIF trong chat.

FR30: Chat cập nhật real-time: tin nhắn mới xuất hiện ngay lập tức không cần refresh.

FR31: Tin nhắn được đánh dấu đã đọc (isRead = true) khi người dùng mở màn hình chat.

FR32: Mỗi bubble tin nhắn hiển thị thời gian gửi (giờ:phút).

**Module 6: Cài Đặt (Settings)**

FR33: Người dùng có thể điều chỉnh khoảng cách tìm kiếm từ 1 đến 160 km.

FR34: Người dùng có thể điều chỉnh range tuổi tìm kiếm từ 18 đến 100.

FR35: Người dùng có thể bật/tắt push notification.

FR36: Người dùng có thể đăng xuất từ Settings (có confirmation dialog).

FR37: Người dùng có thể xóa tài khoản từ Settings (có confirmation dialog, hành động không thể hoàn tác).

**Module 7: Thông Báo (Notifications)**

FR38: Hệ thống gửi push notification khi có match mới.

FR39: Hệ thống gửi push notification khi nhận tin nhắn mới.

FR40: Hệ thống gửi push notification khi nhận super like.

### NonFunctional Requirements

**Nền Tảng & Môi Trường**

NFR1: Ứng dụng chỉ hỗ trợ iOS 16.0+, iPhone only (không hỗ trợ iPad).

NFR2: Ngôn ngữ lập trình Swift 5.9+, Xcode 15+, SwiftUI làm UI framework chính.

NFR3: Tất cả text hiển thị trong UI phải bằng tiếng Việt. Error messages phải được localize sang tiếng Việt.

**Kiến Trúc**

NFR4: Ứng dụng phải tuân thủ kiến trúc Clean Architecture 3 layers: Presentation → Domain ← Data. Presentation layer không được phụ thuộc trực tiếp vào Data layer.

NFR5: Navigation phải thực hiện qua Coordinator Pattern. View không được tự thực hiện navigation.

NFR6: Tất cả dependencies phải được inject qua Swinject container. Không hardcode dependencies trong View hay ViewModel.

NFR7: Repository implementations ở Data layer phải conform Protocol được định nghĩa ở Domain layer.

**Concurrency & Hiệu Năng**

NFR8: Tất cả UseCase methods phải sử dụng async/await. Tất cả ViewModels phải được đánh dấu @MainActor.

NFR9: Tất cả async entry points (swipe, sendMessage, loadProfiles, v.v.) phải có in-flight guard để ngăn concurrent duplicate requests.

NFR10: Danh sách Discover phải tải trong vòng 3 giây khi có kết nối mạng ổn định.

NFR11: Chat real-time phải cập nhật tin nhắn trong vòng 2 giây qua Firestore listeners.

**Bảo Mật**

NFR12: Mật khẩu phải tối thiểu 6 ký tự. Email phải validate format trước khi gửi request.

NFR13: Tất cả authenticated API calls phải dùng Firebase Auth token. Không lưu trữ password trong local storage.

NFR14: Ảnh upload lên Firebase Storage theo path `photos/{userId}/{UUID}.jpg`. Storage rules chỉ cho phép owner đọc/ghi.

NFR15: userId không được lấy từ UserDefaults với fallback `""`. Phải có AuthSessionService centralized cung cấp currentUserId.

**Độ Tin Cậy**

NFR16: Cold start: Firebase session restore phải re-persist currentUserId. Không được có trạng thái authenticated với userId = "".

NFR17: Sau khi logout và login lại bằng account khác, tất cả ViewModels phải nhận userId mới (không stale reference).

NFR18: deleteAccount() phải xử lý đúng thứ tự: xóa Firestore data trước, sau đó xóa Firebase Auth. Có error handling cho từng bước.

NFR19: Photo upload: nếu JPEG conversion fail, phải fallback sang PNG. Không được silent-fail.

**Testing**

NFR20: Domain layer (UseCases) phải có unit test coverage.

NFR21: Presentation layer (ViewModels) phải có unit test coverage cho business logic.

NFR22: Mỗi UseCase, ViewModel phải testable qua Mock repositories.

NFR23: UI Tests phải cover auth flow và tab navigation.

**Backend**

NFR24: Firebase Firestore là database chính. Không dùng local SQLite hay CoreData.

NFR25: Firebase Storage dùng cho ảnh user. Path chuẩn: `photos/{userId}/{UUID}.jpg`.

NFR26: Firebase Cloud Messaging dùng cho push notifications.

NFR27: Firestore collections: `users`, `profiles`, `matches`, `swipes`, `matches/{id}/messages`.

### Additional Requirements

- **XcodeGen:** Tất cả file Swift mới phải được thêm vào `project.yml`. Khi thêm file: (1) Tạo file .swift, (2) Thêm vào project.yml đúng group/target, (3) Chạy `xcodegen generate`, (4) Verify trong Xcode navigator.
- **AuthSessionService bắt buộc:** Implement `AuthSessionServiceProtocol` với `currentUserId: String?` và `currentUserIdPublisher`. Inject vào Coordinators và ViewModels thay vì đọc UserDefaults trực tiếp. Gate tất cả authenticated screens khi `currentUserId != nil`.
- **DI Container (3 Assemblies):** DataAssembly (Firebase services + repositories), DomainAssembly (13 Use Cases), PresentationAssembly (Coordinators + ViewModels).
- **13 Use Cases phải implement:** LoginUseCase, RegisterUseCase, LogoutUseCase, DeleteAccountUseCase, GetProfileUseCase, UpdateProfileUseCase, UploadPhotoUseCase, DeletePhotoUseCase, SwipeUseCase, GetMatchesUseCase, GetDiscoverProfilesUseCase, SendMessageUseCase, GetMessagesUseCase, GetConversationsUseCase.
- **In-Flight Guard Pattern:** Tất cả async actions trong ViewModels phải có `guard !isLoading else { return }` pattern.
- **Firebase Error Mapping:** Firebase errors phải được map sang typed errors (AuthError, ChatError, APIError) trước khi bubble up đến ViewModel. Không để `localizedDescription` tiếng Anh xuất hiện trong UI.
- **Firebase Collections Schema:** users/{userId}, profiles/{userId}, matches/{matchId}, matches/{matchId}/messages/{msgId}, swipes/{swipeId}.
- **Mock Strategy cho Testing:** Mỗi Repository Protocol cần Mock class với `callCount` và configurable Result để test UseCases và ViewModels.
- **UI Test Launch Arguments:** `--uitesting` (enable mock injection), `--authenticated` (skip auth screens).
- **DI Force-Unwrap:** Thay thế `resolver.resolve(...)!` trong PresentationAssembly bằng `precondition` với message rõ ràng.

### UX Design Requirements

UX-DR1: Match alert overlay phải có button "Nhắn tin ngay" điều hướng trực tiếp tới `ChatView(matchId)` — hiện tại button chỉ dismiss.

UX-DR2: Swipe cards phải hiển thị khoảng cách (km) tính từ vị trí hiện tại của user — cần `distance` field được compute và truyền vào CardView.

UX-DR3: CardView phải có tap gesture để navigate tới `ProfileDetailView(profileId)` — hiện không có.

UX-DR4: ConversationsView phải tự động navigate tới ChatView khi user tap vào match từ MatchesView — cần coordination giữa MatchesTab và ChatCoordinator.

UX-DR5: EditProfileView phải hiển thị confirmation dialog "Có thay đổi chưa lưu. Bạn có muốn thoát?" khi dismiss với unsaved changes.

UX-DR6: Tất cả error messages từ Firebase Auth phải hiển thị tiếng Việt. Cần `AuthError.networkError` case riêng thay vì dùng `localizedDescription`.

UX-DR7: Photo delete flow phải handle URL mismatch (trailing slash, encoding differences) — URL normalize trước khi so sánh để tránh silent no-op.

UX-DR8: LoginView Google Sign-In button phải disable khi `isLoading == true` để ngăn double-tap tạo multiple GIDSignIn sessions.

UX-DR9: DiscoverView phải xử lý empty state sau khi hết cards với EmptyStateView "Hết hồ sơ rồi!" + CTA "Làm mới danh sách".

UX-DR10: Onboarding PhotoUpload step phải hiển thị counter "X/6 ảnh" và prevent continue nếu chưa có ảnh nào.

### Edge Cases (từ PRD)

EC-1: Khi không có kết nối mạng, hiển thị thông báo lỗi tiếng Việt thay vì crash. (Must Have)

EC-2: Khi danh sách Discover hết hồ sơ, hiển thị EmptyStateView với CTA refresh. (Must Have)

EC-3: Khi ảnh tải thất bại, hiển thị placeholder avatar. (Must Have)

EC-4: Khi HEIC/WebP không convert được sang JPEG, fallback sang PNG. (Should Have)

EC-5: Firebase Auth errors (network error) phải hiển thị tiếng Việt, không phải localized Firebase default. (Should Have)

EC-6: Photo URL với trailing slash hoặc encoding khác nhau không được dẫn đến silent no-op khi xóa. (Should Have)

### FR Coverage Map

| FR | Epic | Mô tả ngắn |
|----|------|-----------|
| FR1 | Epic 1 | Đăng ký email/password |
| FR2 | Epic 1 | Đăng nhập email/password |
| FR3 | Epic 1 | Google Sign-In |
| FR4 | Epic 1 | Apple Sign-In |
| FR5 | Epic 1 | Forgot password |
| FR6 | Epic 5 | Xóa tài khoản vĩnh viễn |
| FR7 | Epic 1 | Đăng xuất |
| FR8 | Epic 1 | Cold start session restore |
| FR9 | Epic 2 | 4-bước onboarding |
| FR10 | Epic 2 | Upload ảnh (tối đa 6) |
| FR11 | Epic 2 | Edit profile |
| FR12 | Epic 2 | Thêm/xóa/sắp xếp ảnh |
| FR13 | Epic 2 | Cập nhật vị trí địa lý |
| FR14 | Epic 3 | Card stack (tải 20 profiles) |
| FR15 | Epic 3 | Swipe like/dislike/super like |
| FR16 | Epic 3 | Match detection + alert |
| FR17 | Epic 3 | Card content (ảnh, tên, tuổi, khoảng cách) |
| FR18 | Epic 3 | Tap card → ProfileDetailView |
| FR19 | Epic 3 | Like/dislike từ ProfileDetailView |
| FR20 | Epic 3 | Auto load more, no duplicates |
| FR21 | Epic 3 | Concurrency guard cho swipe |
| FR22 | Epic 3 | Matches list (2 sections) |
| FR23 | Epic 3 | NEW badge trên match cards |
| FR24 | Epic 3 | Tap match → bắt đầu chat |
| FR25 | Epic 4 | Unmatch từ chat |
| FR26 | Epic 4 | Conversations list + unread badges |
| FR27 | Epic 4 | Gửi text message |
| FR28 | Epic 4 | Gửi ảnh trong chat |
| FR29 | Epic 4 | Gửi GIF trong chat |
| FR30 | Epic 4 | Real-time updates |
| FR31 | Epic 4 | Đánh dấu đã đọc |
| FR32 | Epic 4 | Timestamp trên bubble |
| FR33 | Epic 5 | Distance filter (1–160 km) |
| FR34 | Epic 5 | Age range filter (18–100) |
| FR35 | Epic 5 | Push notification toggle |
| FR36 | Epic 5 | Đăng xuất từ Settings |
| FR37 | Epic 5 | Xóa tài khoản từ Settings |
| FR38 | Epic 5 | Push: match mới |
| FR39 | Epic 5 | Push: tin nhắn mới |
| FR40 | Epic 5 | Push: super like |

## Epic List

### Epic 1: Xác Thực & Quản Lý Phiên
Người dùng có thể tạo tài khoản, đăng nhập an toàn (email/Google/Apple ID), phiên đăng nhập được duy trì đáng tin cậy qua cold start, và đăng xuất.
**FRs covered:** FR1, FR2, FR3, FR4, FR5, FR7, FR8
**UX-DRs:** UX-DR6, UX-DR8

### Epic 2: Onboarding & Quản Lý Hồ Sơ
Người dùng mới hoàn thành 4 bước onboarding đầy đủ và có thể chỉnh sửa hồ sơ (ảnh, thông tin cá nhân, sở thích) sau khi đăng ký.
**FRs covered:** FR9, FR10, FR11, FR12, FR13
**UX-DRs:** UX-DR5, UX-DR7, UX-DR10

### Epic 3: Khám Phá & Kết Nối
Người dùng có thể khám phá hồ sơ qua swipe cards, bày tỏ sở thích (like/dislike/super like), nhận match alert, và xem danh sách matches.
**FRs covered:** FR14, FR15, FR16, FR17, FR18, FR19, FR20, FR21, FR22, FR23, FR24
**UX-DRs:** UX-DR1, UX-DR2, UX-DR3, UX-DR9

### Epic 4: Trò Chuyện Real-time
Người dùng đã match có thể nhắn tin real-time, gửi ảnh và GIF, quản lý cuộc trò chuyện, và hủy match.
**FRs covered:** FR25, FR26, FR27, FR28, FR29, FR30, FR31, FR32
**UX-DRs:** UX-DR4

### Epic 5: Cài Đặt, Thông Báo & Quản Lý Tài Khoản
Người dùng có thể tùy chỉnh bộ lọc tìm kiếm, bật/tắt thông báo đẩy, nhận push notifications cho match/message/super like, đăng xuất và xóa tài khoản vĩnh viễn.
**FRs covered:** FR6, FR33, FR34, FR35, FR36, FR37, FR38, FR39, FR40

---

## Epic 1: Xác Thực & Quản Lý Phiên

Người dùng có thể tạo tài khoản, đăng nhập an toàn (email/Google/Apple ID), phiên đăng nhập được duy trì đáng tin cậy qua cold start, và đăng xuất.

### Story 1.1: Đăng Ký Tài Khoản Bằng Email

As a người dùng mới,
I want đăng ký tài khoản với email và mật khẩu,
So that tôi có thể truy cập ứng dụng VietMatch.

**Acceptance Criteria:**

**Given** tôi mở app lần đầu và chưa có tài khoản
**When** tôi nhập email hợp lệ, mật khẩu >= 6 ký tự, tên hiển thị và nhấn "Đăng ký"
**Then** Firebase Auth tạo tài khoản mới, Firestore tạo document trong `users/{userId}` với email và display_name, app navigate về LoginView

**Given** tôi nhập email sai định dạng (ví dụ: "abc@")
**When** tôi nhấn "Đăng ký"
**Then** hiển thị inline error "Email không hợp lệ" bên dưới field email, không gọi Firebase

**Given** tôi nhập mật khẩu dưới 6 ký tự
**When** tôi nhấn "Đăng ký"
**Then** hiển thị inline error "Mật khẩu phải ít nhất 6 ký tự", không gọi Firebase

**Given** tôi nhập email đã được đăng ký
**When** tôi nhấn "Đăng ký"
**Then** hiển thị alert tiếng Việt "Email này đã được sử dụng. Vui lòng thử email khác."

**Given** quá trình đăng ký đang chạy
**When** RegisterViewModel đang xử lý
**Then** nút "Đăng ký" disabled, hiển thị spinner (isLoading = true), guard chống concurrent call hoạt động

**And** RegisterUseCase, RegisterViewModel, AuthRepository đều testable qua MockAuthRepository

### Story 1.2: Đăng Nhập Bằng Email & Xử Lý Lỗi Tiếng Việt

As a người dùng đã có tài khoản,
I want đăng nhập bằng email và mật khẩu,
So that tôi có thể truy cập hồ sơ và tính năng của mình.

**Acceptance Criteria:**

**Given** tôi nhập đúng email và mật khẩu
**When** tôi nhấn "Đăng nhập"
**Then** Firebase Auth xác thực thành công, AuthSessionService lưu currentUserId, AppCoordinator route tới màn hình phù hợp (onboarding nếu chưa hoàn thành, main tab nếu đã xong)

**Given** tôi nhập email hoặc mật khẩu sai
**When** tôi nhấn "Đăng nhập"
**Then** hiển thị alert với tiêu đề "Lỗi đăng nhập" và message tiếng Việt — KHÔNG hiển thị `localizedDescription` tiếng Anh từ Firebase

**Given** không có kết nối mạng
**When** tôi nhấn "Đăng nhập"
**Then** hiển thị alert "Không có kết nối mạng. Vui lòng thử lại." (AuthError.networkError case riêng)

**Given** quá trình đăng nhập đang xử lý
**When** LoginViewModel isLoading = true
**Then** tất cả input fields và buttons đều disabled, hiển thị spinner

**And** Tất cả Firebase AuthError codes được map sang Vietnamese messages trong AuthError enum

### Story 1.3: Đặt Lại Mật Khẩu

As a người dùng quên mật khẩu,
I want nhập email để nhận link đặt lại mật khẩu,
So that tôi có thể lấy lại quyền truy cập tài khoản.

**Acceptance Criteria:**

**Given** tôi ở ForgotPasswordView và nhập email hợp lệ
**When** tôi nhấn "Gửi link đặt lại"
**Then** Firebase Auth gửi email reset, hiển thị confirmation message "Email đặt lại mật khẩu đã được gửi tới [email]. Vui lòng kiểm tra hộp thư."

**Given** tôi nhập email không tồn tại trong hệ thống
**When** tôi nhấn "Gửi link đặt lại"
**Then** hiển thị alert tiếng Việt "Email này không tồn tại trong hệ thống."

**Given** đang gửi request
**When** ForgotPasswordViewModel isLoading = true
**Then** button disabled với spinner, không thể gửi duplicate request

**Given** gửi thành công
**When** tôi nhấn "Quay lại đăng nhập"
**Then** navigate về LoginView

### Story 1.4: Đăng Nhập Bằng Google

As a người dùng,
I want đăng nhập bằng tài khoản Google của mình,
So that tôi không cần tạo và nhớ mật khẩu mới.

**Acceptance Criteria:**

**Given** tôi nhấn nút "Đăng nhập bằng Google"
**When** Google Sign-In flow hoàn tất thành công
**Then** Firebase Auth lưu credential, AuthSessionService persist userId, Firestore tạo/update document trong `users/{userId}`, AppCoordinator route phù hợp

**Given** tôi đóng Google Sign-In popup mà không chọn tài khoản
**When** flow bị cancel
**Then** không có lỗi, app trở về LoginView bình thường

**Given** app đang xử lý Google Sign-In (isLoading = true)
**When** Google Sign-In button hiển thị
**Then** button bị disabled (opacity 0.6), không nhận touch — ngăn double-tap tạo multiple GIDSignIn sessions

**Given** có lỗi mạng trong quá trình Google Sign-In
**When** lỗi xảy ra
**Then** hiển thị alert tiếng Việt "Đăng nhập Google thất bại. Vui lòng thử lại."

### Story 1.5: Đăng Nhập Bằng Apple ID

As a người dùng iPhone,
I want đăng nhập bằng Apple ID,
So that tôi có thể sử dụng phương thức xác thực an toàn và riêng tư của Apple.

**Acceptance Criteria:**

**Given** tôi nhấn "Sign in with Apple"
**When** Apple authentication flow hoàn tất thành công
**Then** Firebase Auth xử lý Apple credential, AuthSessionService persist userId, Firestore tạo/update `users/{userId}`, AppCoordinator route phù hợp

**Given** tôi hủy Apple Sign-In
**When** flow bị cancel
**Then** không có lỗi, app trở về LoginView bình thường

**Given** Apple Sign-In thành công với "Hide My Email"
**When** Apple cung cấp relay email
**Then** relay email được lưu vào Firestore, app hoạt động bình thường

**Given** có lỗi trong quá trình
**When** lỗi xảy ra
**Then** hiển thị alert tiếng Việt

### Story 1.6: AuthSessionService & Cold Start Session Restore

As a người dùng đã đăng nhập,
I want session của tôi được tự động khôi phục khi mở lại app,
So that tôi không cần đăng nhập lại mỗi lần.

**Acceptance Criteria:**

**Given** tôi đã đăng nhập và tắt app hoàn toàn (cold start)
**When** tôi mở lại app
**Then** Firebase Auth khôi phục session, AuthSessionService re-persist currentUserId (không phải `""`), AppCoordinator tự động route tới màn hình phù hợp mà không qua LoginView

**Given** chưa có session (lần đầu cài app hoặc đã logout)
**When** app khởi động
**Then** AuthSessionService.currentUserId = nil, AppCoordinator route tới AuthCoordinator/LoginView

**Given** AuthSessionServiceProtocol được implement
**When** Coordinators và ViewModels cần userId
**Then** họ inject AuthSessionServiceProtocol, KHÔNG đọc UserDefaults trực tiếp với fallback `?? ""`

**Given** user đăng nhập bằng account A, logout, đăng nhập bằng account B
**When** account B đăng nhập thành công
**Then** AuthSessionService publish userId mới, tất cả ViewModels nhận userId của B (không còn stale reference của A)

**And** currentUserIdPublisher (AnyPublisher<String?, Never>) hoạt động đúng cho AppCoordinator state machine

### Story 1.7: Đăng Xuất

As a người dùng đã đăng nhập,
I want đăng xuất khỏi ứng dụng,
So that tôi có thể bảo vệ tài khoản khi chia sẻ thiết bị.

**Acceptance Criteria:**

**Given** tôi nhấn "Đăng xuất" (từ bất kỳ màn hình nào)
**When** LogoutUseCase.execute() chạy thành công
**Then** Firebase Auth sign out, AuthSessionService publish nil, AppCoordinator navigate về AuthCoordinator/LoginView

**Given** AuthSessionService publish nil
**When** AppCoordinator nhận event
**Then** toàn bộ main tab stack được dismiss, LoginView được hiển thị, không có memory leak từ ViewModels cũ

**And** LogoutUseCase testable qua MockAuthRepository

---

## Epic 2: Onboarding & Quản Lý Hồ Sơ

Người dùng mới hoàn thành 4 bước onboarding đầy đủ và có thể chỉnh sửa hồ sơ (ảnh, thông tin cá nhân, sở thích) sau khi đăng ký.

### Story 2.1: Onboarding Bước 1 & 2 — Thông Tin Cơ Bản & Giới Tính

As a người dùng mới đã đăng ký,
I want nhập thông tin cơ bản (tên, tuổi, bio) và chọn giới tính,
So that hồ sơ của tôi phản ánh đúng bản thân để gặp đúng người.

**Acceptance Criteria:**

**Given** tôi hoàn thành đăng ký và chưa có profile
**When** AppCoordinator phát hiện `profileCompleted == false`
**Then** OnboardingView được hiển thị với progress indicator 4 dots, bắt đầu từ Bước 1

**Given** tôi ở Bước 1 (ProfileSetupView)
**When** tôi nhập tên hợp lệ, kéo slider tuổi (18–100), nhập bio
**Then** bio counter hiển thị số ký tự còn lại (max 500), nút "Tiếp theo" enabled khi tên không rỗng

**Given** tôi để trống tên
**When** tôi nhấn "Tiếp theo"
**Then** nút "Tiếp theo" vẫn disabled, không thể qua bước tiếp

**Given** tôi hoàn thành Bước 1 và chuyển sang Bước 2 (GenderSelectionView)
**When** tôi chọn giới tính (Nam/Nữ/Khác) và giới tính muốn gặp
**Then** pill button được chọn highlight màu `primary`, nút "Tiếp theo" enabled

**Given** tôi ở Bước 2 và nhấn Back
**When** quay lại Bước 1
**Then** dữ liệu Bước 1 vẫn được giữ nguyên (không mất data)

### Story 2.2: Onboarding Bước 3 — Upload Ảnh

As a người dùng đang onboarding,
I want tải lên ít nhất 1 ảnh vào hồ sơ,
So that người khác có thể nhận ra và hấp dẫn với hồ sơ của tôi.

**Acceptance Criteria:**

**Given** tôi ở Bước 3 (PhotoUploadView)
**When** màn hình hiển thị
**Then** grid 3×2 gồm 6 slots xuất hiện, counter "0/6 ảnh" hiển thị, nút "Tiếp theo" disabled

**Given** tôi nhấn slot trống
**When** tôi chọn ảnh từ thư viện
**Then** ảnh hiển thị full bleed trong slot, nút xóa (xmark.circle.fill) xuất hiện top-right, counter cập nhật (ví dụ "1/6 ảnh"), nút "Tiếp theo" enabled

**Given** tôi đã có ít nhất 1 ảnh và nhấn "Tiếp theo"
**When** UploadPhotoUseCase.execute() chạy
**Then** ảnh được upload lên Firebase Storage tại `photos/{userId}/{UUID}.jpg`, URL được lưu vào `profiles/{userId}.photos[]`, progress indicator hiển thị trong khi upload

**Given** JPEG conversion thất bại
**When** UploadPhotoUseCase xử lý ảnh
**Then** fallback sang PNG, KHÔNG silent-fail, upload thành công với PNG

**Given** tôi đã upload 6 ảnh
**When** tôi nhấn slot thêm ảnh
**Then** không thể thêm, counter hiển thị "6/6 ảnh"

**Given** tôi nhấn nút xóa trên một ảnh
**When** xác nhận xóa
**Then** ảnh bị xóa khỏi slot, counter giảm xuống, nếu còn 0 ảnh thì nút "Tiếp theo" disabled lại

### Story 2.3: Onboarding Bước 4 — Sở Thích & Hoàn Tất

As a người dùng đang onboarding,
I want chọn sở thích của mình,
So that hệ thống có thể gợi ý những người phù hợp hơn với tôi.

**Acceptance Criteria:**

**Given** tôi ở Bước 4 (InterestsView)
**When** màn hình hiển thị
**Then** tag cloud với danh sách sở thích xuất hiện, không có tag nào được chọn, nút "Hoàn tất" enabled (sở thích là optional)

**Given** tôi nhấn vào một tag sở thích
**When** tag được chọn
**Then** tag highlight màu `primary`, counter "X đã chọn" cập nhật (max 15)

**Given** tôi đã chọn 15 sở thích
**When** tôi nhấn tag thứ 16
**Then** tag thứ 16 không được chọn, hiển thị thông báo "Tối đa 15 sở thích"

**Given** tôi nhấn "Hoàn tất"
**When** UpdateProfileUseCase.execute() chạy
**Then** Firestore cập nhật `profiles/{userId}` với tất cả dữ liệu từ 4 bước, `users/{userId}.profileCompleted = true`, AppCoordinator route tới MainTabCoordinator

**And** Toàn bộ data onboarding (name, age, bio, gender, photos, interests) được persist vào Firestore

### Story 2.4: Chỉnh Sửa Thông Tin Hồ Sơ

As a người dùng đã onboarding,
I want chỉnh sửa tên, bio, job title, công ty và trường học,
So that hồ sơ của tôi luôn cập nhật và chính xác.

**Acceptance Criteria:**

**Given** tôi nhấn "Chỉnh sửa" từ ProfileView
**When** EditProfileView mở ra
**Then** tất cả các fields (name, bio, job title, company, school) được pre-fill với dữ liệu hiện tại

**Given** tôi chỉnh sửa một hoặc nhiều fields và nhấn "Lưu thay đổi"
**When** UpdateProfileUseCase.execute() chạy
**Then** Firestore cập nhật `profiles/{userId}` với dữ liệu mới, hiển thị confirmation toast "Đã lưu thay đổi", ProfileView refresh với dữ liệu mới

**Given** tôi đã chỉnh sửa nhưng chưa lưu, và swipe down để dismiss
**When** EditProfileView phát hiện có unsaved changes
**Then** hiển thị confirmation dialog "Có thay đổi chưa lưu. Bạn có muốn thoát?" với buttons "Huỷ" và "Thoát không lưu"

**Given** tôi nhấn "Huỷ" trong dialog
**When** dialog dismiss
**Then** EditProfileView vẫn mở, dữ liệu chưa lưu được giữ nguyên

**Given** đang lưu
**When** UpdateProfileViewModel isLoading = true
**Then** nút "Lưu thay đổi" disabled, hiển thị spinner

### Story 2.5: Quản Lý Ảnh Hồ Sơ

As a người dùng đã onboarding,
I want thêm, xóa và sắp xếp lại ảnh trong hồ sơ,
So that tôi có thể kiểm soát hình ảnh mình muốn thể hiện.

**Acceptance Criteria:**

**Given** tôi vào EditProfileView
**When** màn hình hiển thị
**Then** photo grid 3×2 hiển thị ảnh hiện tại, slots trống hiển thị dashed border + icon thêm

**Given** tôi nhấn slot trống để thêm ảnh
**When** tôi chọn ảnh từ thư viện
**Then** ảnh được upload lên Firebase Storage (`photos/{userId}/{UUID}.jpg`), URL mới được append vào `profiles/{userId}.photos[]`, grid cập nhật ngay

**Given** tôi nhấn nút xóa (xmark.circle.fill) trên một ảnh
**When** xác nhận xóa
**Then** file bị xóa khỏi Firebase Storage, URL bị remove khỏi `profiles/{userId}.photos[]`, grid cập nhật

**Given** photo URL có trailing slash hoặc encoding khác nhau so với URL trong Firestore
**When** DeletePhotoUseCase.execute() chạy
**Then** URL được normalize trước khi so sánh, xóa thành công — KHÔNG silent-fail do URL mismatch

**Given** tôi kéo thả để sắp xếp lại thứ tự ảnh
**When** thứ tự mới được xác nhận
**Then** `profiles/{userId}.photos[]` cập nhật đúng thứ tự mới trong Firestore

### Story 2.6: Cập Nhật Vị Trí Địa Lý

As a người dùng,
I want app tự động cập nhật vị trí của tôi,
So that tôi có thể thấy và được thấy bởi người dùng ở gần.

**Acceptance Criteria:**

**Given** tôi mở app và đã cấp quyền location
**When** LocationService lấy được vị trí hiện tại
**Then** `profiles/{userId}` được cập nhật với latitude, longitude và city

**Given** tôi chưa cấp quyền location
**When** app yêu cầu permission
**Then** hiển thị iOS permission dialog, app không crash nếu từ chối

**Given** tôi từ chối quyền location
**When** app tiếp tục
**Then** app vẫn hoạt động bình thường, chỉ không cập nhật được vị trí

**And** location update chỉ chạy khi `currentUserId != nil` — không cập nhật khi chưa auth

---

## Epic 3: Khám Phá & Kết Nối

Người dùng có thể khám phá hồ sơ qua swipe cards, bày tỏ sở thích (like/dislike/super like), nhận match alert, và xem danh sách matches.

### Story 3.1: Tải & Hiển Thị Card Stack

As a người dùng đã hoàn thành onboarding,
I want thấy danh sách hồ sơ người khác dạng stack cards,
So that tôi có thể bắt đầu khám phá và tìm kiếm.

**Acceptance Criteria:**

**Given** tôi vào tab Khám phá (DiscoverView)
**When** GetDiscoverProfilesUseCase.execute() chạy
**Then** tối đa 20 hồ sơ được tải từ Firestore (loại trừ userId của tôi và các profile đã swipe), LoadingView hiển thị trong khi tải, cards xuất hiện sau khi tải xong

**Given** cards đã tải
**When** CardView hiển thị
**Then** mỗi card có: photo carousel (swipe qua ảnh), dots indicator ở top, tên + tuổi (`cardName`/`cardAge`), job title + khoảng cách (`cardInfo`), bio preview (2 dòng truncated), gradient overlay phía dưới đảm bảo readability

**Given** tôi swipe qua ảnh trong card
**When** carousel scroll
**Then** ảnh chuyển sang ảnh tiếp theo/trước, dots indicator cập nhật, gesture không conflict với swipe card

**Given** tôi swipe hết cards trong batch hiện tại
**When** còn < 3 cards trong stack
**Then** GetDiscoverProfilesUseCase tự động tải batch tiếp theo, không có duplicate profiles trong cùng session

**Given** danh sách Discover đang tải
**When** tải hoàn tất
**Then** thời gian tải < 3 giây với kết nối mạng ổn định

### Story 3.2: Swipe Like / Dislike / Super Like

As a người dùng đang khám phá,
I want swipe hoặc nhấn nút để bày tỏ sở thích với một hồ sơ,
So that hệ thống có thể tìm match cho tôi.

**Acceptance Criteria:**

**Given** tôi kéo card sang phải > 100pt
**When** gesture release
**Then** LIKE indicator (màu success) xuất hiện dần theo drag amount, card bay ra phải với spring animation, SwipeUseCase lưu swipe `direction: .like` vào `swipes/{swipeId}` trong Firestore

**Given** tôi kéo card sang trái > 100pt
**When** gesture release
**Then** NOPE indicator (màu error) xuất hiện dần, card bay ra trái, SwipeUseCase lưu `direction: .dislike`

**Given** tôi nhấn nút Super Like (star.fill, 44pt, màu info)
**When** nhấn
**Then** SwipeUseCase lưu `direction: .superLike`, card bay lên trên với animation

**Given** SwipeUseCase đang xử lý một swipe (isSwipeInProgress = true)
**When** tôi cố swipe card tiếp theo
**Then** swipe bị block — in-flight guard hoạt động, không có duplicate swipe requests

**Given** khoảng cách giữa tôi và người dùng trên card
**When** CardView render
**Then** field `distance` được compute từ vị trí hiện tại của tôi và profile target, hiển thị "X km" trên card

**And** SwipeUseCase testable qua MockMatchRepository với callCount tracking

### Story 3.3: Match Detection & Match Alert

As a người dùng vừa like ai đó,
I want biết ngay khi match xảy ra,
So that tôi có thể bắt đầu trò chuyện với người match.

**Acceptance Criteria:**

**Given** tôi like profile B
**When** SwipeUseCase.execute() chạy
**Then** hệ thống query Firestore: kiểm tra xem B đã like tôi chưa (swipes where swiperId == B AND swipedUserId == tôi AND direction == .like)

**Given** B đã like tôi trước đó
**When** mutual like được phát hiện
**Then** Match record được tạo trong Firestore (`matches/{matchId}`), Match alert overlay xuất hiện ngay lập tức với warmGradient background, 2 avatars side by side, "It's a Match! 🎉"

**Given** Match alert đang hiển thị
**When** tôi nhấn "Nhắn tin ngay"
**Then** Match alert dismiss, app navigate trực tiếp tới `ChatView(matchId)` qua ChatCoordinator

**Given** Match alert đang hiển thị
**When** tôi nhấn "Để sau"
**Then** Match alert dismiss, DiscoverView tiếp tục với card tiếp theo

**Given** B chưa like tôi
**When** SwipeUseCase hoàn tất
**Then** không có match, không có alert, stack tiếp tục bình thường

### Story 3.4: Xem Hồ Sơ Chi Tiết

As a người dùng muốn biết thêm về ai đó,
I want nhấn vào card để xem đầy đủ thông tin hồ sơ,
So that tôi có thể quyết định có nên like hay không dựa trên thông tin đầy đủ.

**Acceptance Criteria:**

**Given** tôi nhấn vào một card trong DiscoverView
**When** tap gesture nhận diện
**Then** ProfileDetailView mở ra với: photo carousel full width (60% screen height, paged scroll), page indicators, tên + tuổi + khoảng cách, tags sở thích, bio đầy đủ, job/school/company rows, action bar sticky bottom

**Given** ProfileDetailView đang hiển thị
**When** tôi nhấn nút Like (heart.fill, màu success)
**Then** SwipeUseCase lưu like, nếu match → Match alert hiển thị với "Nhắn tin ngay" navigate tới ChatView(matchId)

**Given** ProfileDetailView đang hiển thị
**When** tôi nhấn nút Dislike (xmark, màu error)
**Then** SwipeUseCase lưu dislike, ProfileDetailView dismiss, card tiếp theo trong stack

**Given** ProfileDetailView đang hiển thị
**When** tôi nhấn nút Super Like
**Then** SwipeUseCase lưu superLike, ProfileDetailView dismiss

**And** CardView có tap gesture riêng biệt, không conflict với DragGesture của swipe

### Story 3.5: Danh Sách Matches

As a người dùng đã có matches,
I want xem tất cả matches của mình,
So that tôi có thể chọn ai để bắt đầu trò chuyện.

**Acceptance Criteria:**

**Given** tôi vào tab Matches (MatchesView)
**When** GetMatchesUseCase.execute() chạy
**Then** màn hình hiển thị 2 sections: "Matches mới" (horizontal scroll, CompactMatchCell 70×70) và "Tất cả matches" (vertical list, FullMatchCell 60×60)

**Given** một match chưa có tin nhắn nào
**When** MatchCell render
**Then** badge "NEW" hiển thị trên avatar của match đó

**Given** tôi nhấn vào một match cell
**When** tap
**Then** app navigate tới ChatView(matchId) để bắt đầu hoặc tiếp tục cuộc trò chuyện

**Given** chưa có match nào
**When** MatchesView load
**Then** EmptyStateView hiển thị với icon `heart.slash` và message "Chưa có match nào"

**And** GetMatchesUseCase testable qua MockMatchRepository

### Story 3.6: Discover Empty State

As a người dùng đã swipe hết tất cả hồ sơ,
I want thấy thông báo rõ ràng và có cách làm mới danh sách,
So that tôi biết phải làm gì khi không còn hồ sơ để xem.

**Acceptance Criteria:**

**Given** tất cả cards đã swipe hết và không còn profiles mới
**When** GetDiscoverProfilesUseCase trả về danh sách rỗng
**Then** EmptyStateView hiển thị với title "Hết hồ sơ rồi!", message "Hãy quay lại sau để khám phá thêm", CTA button "Làm mới danh sách"

**Given** tôi nhấn "Làm mới danh sách"
**When** button tap
**Then** GetDiscoverProfilesUseCase được gọi lại, LoadingView hiển thị, stack reset với profiles mới (nếu có)

**Given** mạng bị mất khi tải profiles
**When** lỗi network xảy ra
**Then** hiển thị alert tiếng Việt "Không có kết nối mạng. Vui lòng thử lại." thay vì crash

---

## Epic 4: Trò Chuyện Real-time

Người dùng đã match có thể nhắn tin real-time, gửi ảnh và GIF, quản lý cuộc trò chuyện, và hủy match.

### Story 4.1: Danh Sách Cuộc Trò Chuyện

As a người dùng có matches,
I want xem tất cả cuộc trò chuyện của mình được sắp xếp theo thứ tự mới nhất,
So that tôi không bỏ lỡ tin nhắn nào.

**Acceptance Criteria:**

**Given** tôi vào tab Trò chuyện (ConversationsView)
**When** GetConversationsUseCase.execute() chạy
**Then** danh sách conversations hiển thị, mỗi row gồm: ProfileImageView 56×56, tên (headline), preview tin nhắn cuối (1 dòng truncated, footnote), thời gian gửi (right-aligned), unread count badge (red circle)

**Given** có cuộc trò chuyện chưa đọc
**When** ConversationCell render
**Then** unread count badge hiển thị số tin nhắn chưa đọc bằng caption2 trắng trên nền đỏ

**Given** danh sách có nhiều conversations
**When** hiển thị
**Then** được sắp xếp theo thời gian tin nhắn gần nhất (mới nhất lên đầu)

**Given** chưa có cuộc trò chuyện nào
**When** ConversationsView load
**Then** EmptyStateView hiển thị "Chưa có cuộc trò chuyện" với CTA "Khám phá ngay" điều hướng tới tab Discover

**Given** tôi nhấn vào một conversation
**When** tap
**Then** ChatView(matchId) mở ra

### Story 4.2: Gửi & Nhận Tin Nhắn Real-time

As a người dùng đang chat với match,
I want gửi tin nhắn text và nhận phản hồi ngay lập tức,
So that chúng tôi có thể trò chuyện một cách tự nhiên.

**Acceptance Criteria:**

**Given** tôi vào ChatView(matchId)
**When** GetMessagesUseCase kết nối Firestore listener
**Then** tất cả tin nhắn cũ hiển thị, listener lắng nghe `matches/{matchId}/messages` real-time

**Given** tôi nhập text và nhấn nút gửi (arrow.up.circle.fill)
**When** SendMessageUseCase.execute() chạy
**Then** tin nhắn được lưu vào `matches/{matchId}/messages/{msgId}` với sender_id, content, type: .text, created_at, tin nhắn của tôi xuất hiện ngay ở bubble phải (primaryGradient background, white text)

**Given** tôi nhập text toàn whitespace và nhấn gửi
**When** SendMessageUseCase validate
**Then** tin nhắn bị reject (trimmed content rỗng), không lưu vào Firestore, nút gửi disabled khi text field rỗng

**Given** đối phương gửi tin nhắn
**When** Firestore listener nhận update
**Then** tin nhắn mới xuất hiện trong < 2 giây ở bubble trái (white background, textPrimary), list tự động scroll xuống dưới

**Given** tôi mở ChatView
**When** màn hình load xong
**Then** tất cả tin nhắn chưa đọc được đánh dấu `isRead = true` trong Firestore

**Given** mỗi bubble tin nhắn
**When** render
**Then** timestamp (giờ:phút) hiển thị bên dưới bubble theo caption2 style

**And** SendMessageUseCase testable qua MockChatRepository, isLoading guard ngăn concurrent send

### Story 4.3: Gửi Ảnh & GIF Trong Chat

As a người dùng đang chat,
I want gửi ảnh và GIF,
So that cuộc trò chuyện sinh động và biểu cảm hơn chỉ với text.

**Acceptance Criteria:**

**Given** tôi nhấn icon attach trong input bar
**When** image picker mở ra
**Then** tôi có thể chọn ảnh từ Photos library

**Given** tôi chọn một ảnh
**When** SendMessageUseCase xử lý
**Then** ảnh được upload lên Firebase Storage, URL được lưu vào message với type: .image, ảnh hiển thị trong bubble chat (full width trong bubble, aspect ratio preserved)

**Given** tôi muốn gửi GIF
**When** tôi chọn GIF từ picker
**Then** GIF được gửi với type: .gif, hiển thị animated trong bubble chat

**Given** upload ảnh đang xử lý
**When** isLoading = true
**Then** progress indicator hiển thị trong bubble, input bar disabled để tránh double-send

**Given** upload thất bại (lỗi mạng)
**When** lỗi xảy ra
**Then** hiển thị alert tiếng Việt "Gửi ảnh thất bại. Vui lòng thử lại.", bubble lỗi không xuất hiện trong danh sách

### Story 4.4: Cross-tab Navigation & Hủy Match

As a người dùng,
I want chuyển từ MatchesView sang ChatView liền mạch, và có thể hủy match khi muốn,
So that trải nghiệm điều hướng tự nhiên và tôi có toàn quyền kiểm soát các kết nối.

**Acceptance Criteria:**

**Given** tôi đang ở tab Matches và nhấn vào một match
**When** tap gesture
**Then** app switch sang tab Trò chuyện VÀ tự động navigate tới ChatView(matchId) đó — không phải chỉ switch tab mà dừng ở ConversationsView

**Given** tôi đang trong ChatView
**When** tôi nhấn menu "Hủy match" (unmatch)
**Then** hiển thị confirmation alert "Bạn có chắc muốn hủy match? Tất cả tin nhắn sẽ bị xóa." với "Huỷ" và "Xác nhận"

**Given** tôi xác nhận unmatch
**When** xử lý hoàn tất
**Then** match record bị xóa khỏi Firestore, ChatView dismiss, ConversationsView không còn hiển thị conversation đó, MatchesView không còn hiển thị match đó

**And** ChatCoordinator và MatchesCoordinator phối hợp qua AppCoordinator để handle cross-tab navigation

---

## Epic 5: Cài Đặt, Thông Báo & Quản Lý Tài Khoản

Người dùng có thể tùy chỉnh bộ lọc tìm kiếm, bật/tắt thông báo đẩy, nhận push notifications cho match/message/super like, đăng xuất và xóa tài khoản vĩnh viễn.

### Story 5.1: Bộ Lọc Tìm Kiếm — Khoảng Cách & Độ Tuổi

As a người dùng,
I want điều chỉnh khoảng cách và độ tuổi tìm kiếm,
So that tôi chỉ thấy những người phù hợp với tiêu chí của mình.

**Acceptance Criteria:**

**Given** tôi vào SettingsView (section "Khám phá")
**When** màn hình hiển thị
**Then** Slider khoảng cách (1–160 km) và RangeSlider độ tuổi (18–100) được pre-fill với giá trị hiện tại từ Firestore

**Given** tôi kéo slider khoảng cách
**When** giá trị thay đổi
**Then** label hiển thị cập nhật real-time (ví dụ "50 km"), giá trị được debounce và lưu vào `profiles/{userId}` sau khi người dùng dừng kéo

**Given** tôi kéo RangeSlider độ tuổi
**When** giá trị min/max thay đổi
**Then** label hiển thị "18 – 35 tuổi" cập nhật real-time, giá trị được lưu vào Firestore

**Given** tôi lưu bộ lọc mới
**When** quay lại DiscoverView
**Then** GetDiscoverProfilesUseCase tải lại với filter mới áp dụng (distance <= maxDistance, age in [minAge, maxAge])

### Story 5.2: Quản Lý Push Notifications

As a người dùng,
I want bật/tắt push notifications và nhận thông báo kịp thời về matches và tin nhắn,
So that tôi không bỏ lỡ kết nối quan trọng.

**Acceptance Criteria:**

**Given** tôi vào SettingsView (section "Thông báo")
**When** màn hình hiển thị
**Then** Toggle "Bật thông báo đẩy" hiển thị trạng thái hiện tại (on/off)

**Given** tôi bật toggle
**When** FCMService đăng ký
**Then** FCM token được lưu vào `users/{userId}.fcmToken`, iOS permission được request nếu chưa cấp

**Given** tôi tắt toggle
**When** FCMService hủy đăng ký
**Then** FCM token bị xóa khỏi Firestore, user không nhận push notification nữa

**Given** có match mới
**When** SwipeUseCase tạo match record
**Then** FCM push notification được gửi tới thiết bị của đối phương với title "Match mới!" và body tiếng Việt

**Given** có tin nhắn mới trong một conversation
**When** SendMessageUseCase lưu message
**Then** FCM push notification được gửi tới đối phương với nội dung preview tin nhắn

**Given** ai đó Super Like tôi
**When** SwipeUseCase lưu superLike
**Then** FCM push notification được gửi với thông báo "Ai đó đã Super Like bạn!"

**Given** tôi nhấn vào push notification "Tin nhắn mới"
**When** app mở từ background/killed state
**Then** deep link qua AppCoordinator navigate trực tiếp tới ChatView(matchId) tương ứng

**Given** tôi nhấn vào push notification "Match mới"
**When** app mở
**Then** navigate tới MatchesView (tab 2)

### Story 5.3: Đăng Xuất & Xóa Tài Khoản Từ Settings

As a người dùng,
I want đăng xuất hoặc xóa tài khoản vĩnh viễn từ Settings,
So that tôi có toàn quyền kiểm soát tài khoản và dữ liệu của mình.

**Acceptance Criteria:**

**Given** tôi nhấn "Đăng xuất" trong SettingsView
**When** nhấn
**Then** hiển thị confirmation alert "Bạn có chắc muốn đăng xuất?" với "Huỷ" và "Đăng xuất"

**Given** tôi xác nhận đăng xuất
**When** LogoutUseCase.execute() chạy
**Then** Firebase Auth sign out, AuthSessionService publish nil, AppCoordinator navigate về LoginView

**Given** tôi nhấn "Xóa tài khoản" trong SettingsView
**When** nhấn
**Then** hiển thị confirmation alert "Hành động này không thể hoàn tác. Tất cả dữ liệu của bạn sẽ bị xóa vĩnh viễn." với "Huỷ" (cancel, default) và "Xóa tài khoản" (destructive style)

**Given** tôi xác nhận xóa tài khoản
**When** DeleteAccountUseCase.execute() chạy
**Then** thực hiện đúng thứ tự: (1) xóa `profiles/{userId}` khỏi Firestore, (2) xóa `users/{userId}` khỏi Firestore, (3) xóa ảnh trong Firebase Storage `photos/{userId}/`, (4) xóa Firebase Auth record — nếu bước nào fail thì log lỗi và hiển thị alert tiếng Việt

**Given** xóa tài khoản thành công
**When** tất cả bước hoàn tất
**Then** AuthSessionService publish nil, app navigate về LoginView, không còn bất kỳ dữ liệu nào của user trong hệ thống

**Given** lỗi xảy ra ở bước 1 (Firestore)
**When** deleteAccount xử lý lỗi
**Then** hiển thị alert "Xóa tài khoản thất bại. Vui lòng thử lại.", Firebase Auth record KHÔNG bị xóa (đảm bảo data integrity)

**And** DeleteAccountUseCase testable qua MockAuthRepository và MockProfileRepository với step-by-step verification
