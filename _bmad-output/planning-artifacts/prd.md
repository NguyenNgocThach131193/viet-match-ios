---
type: prd
project: VietMatch
version: 1.0
date: 2026-04-01
status: approved
---

# VietMatch — Product Requirements Document (PRD)

## 1. Giới Thiệu

**VietMatch** là ứng dụng hẹn hò iOS dành cho người Việt, cung cấp trải nghiệm swipe-to-match, chat real-time và quản lý hồ sơ cá nhân đầy đủ. Tài liệu này mô tả toàn bộ yêu cầu chức năng (FR) và phi chức năng (NFR) cho phiên bản 1.0 và các cải tiến tiếp theo (v1.1+).

---

## 2. Bối Cảnh & Mục Tiêu

### Vấn Đề
Người dùng Việt Nam thiếu ứng dụng hẹn hò được bản địa hoá đúng nghĩa — giao diện tiếng Anh, không tối ưu văn hoá địa phương, và trải nghiệm không phù hợp thị trường Việt.

### Mục Tiêu Sản Phẩm
- Cung cấp nền tảng hẹn hò iOS hoàn chỉnh bằng tiếng Việt
- Kết nối người dùng phù hợp thông qua matching algorithm (swipe-based)
- Tạo môi trường giao tiếp an toàn qua in-app chat
- Trao quyền kiểm soát tìm kiếm cho người dùng (khoảng cách, độ tuổi, giới tính)

---

## 3. Yêu Cầu Chức Năng (Functional Requirements)

### Module 1: Xác Thực (Authentication)

**FR1:** Hệ thống cho phép người dùng đăng ký tài khoản mới bằng email và mật khẩu. Mật khẩu phải tối thiểu 6 ký tự. Email phải hợp lệ (format chuẩn).

**FR2:** Hệ thống cho phép người dùng đăng nhập bằng email và mật khẩu đã đăng ký. Hiển thị thông báo lỗi tiếng Việt khi đăng nhập thất bại.

**FR3:** Hệ thống cho phép người dùng đăng nhập bằng tài khoản Google (Google Sign-In). Firebase lưu userId sau khi đăng nhập thành công.

**FR4:** Hệ thống cho phép người dùng đăng nhập bằng Apple ID (Sign in with Apple). Firebase lưu userId sau khi đăng nhập thành công.

**FR5:** Hệ thống cung cấp chức năng quên mật khẩu: người dùng nhập email và nhận link đặt lại mật khẩu qua email.

**FR6:** Người dùng có thể xóa tài khoản vĩnh viễn từ Settings. Thao tác xóa xóa cả Firebase Auth record lẫn dữ liệu Firestore (users, profiles).

**FR7:** Người dùng có thể đăng xuất khỏi ứng dụng. Sau khi đăng xuất, app điều hướng về màn hình đăng nhập.

**FR8:** Hệ thống tự động khôi phục session đăng nhập khi khởi động lại app (cold start restore). userId phải được re-persist sau khi Firebase khôi phục session.

---

### Module 2: Onboarding & Hồ Sơ

**FR9:** Người dùng mới (chưa hoàn thành onboarding) được dẫn qua 4 bước onboarding theo thứ tự:
- Bước 1: Nhập tên, tuổi (18–100), bio (tối đa 500 ký tự)
- Bước 2: Chọn giới tính (Nam / Nữ / Khác) và giới tính muốn gặp
- Bước 3: Tải lên ảnh (1–6 ảnh, bắt buộc ít nhất 1)
- Bước 4: Chọn sở thích (tối đa 15 lựa chọn)

**FR10:** Người dùng có thể tải lên tối đa 6 ảnh vào hồ sơ. Ảnh được upload lên Firebase Storage và URL lưu trong Firestore (profiles collection).

**FR11:** Người dùng có thể chỉnh sửa hồ sơ sau onboarding: tên, bio, job title, công ty, trường học.

**FR12:** Người dùng có thể thêm, xóa, và sắp xếp lại ảnh trong hồ sơ. Xóa ảnh xóa luôn file trên Firebase Storage và cập nhật Firestore.

**FR13:** Hệ thống cập nhật vị trí địa lý của người dùng (latitude, longitude, city) vào Firestore profile.

---

### Module 3: Khám Phá (Discover)

**FR14:** Ứng dụng hiển thị danh sách hồ sơ người dùng khác dạng stack cards có thể swipe. Mỗi lần tải tối đa 20 hồ sơ.

**FR15:** Người dùng có thể swipe phải (Like), swipe trái (Dislike), hoặc nhấn nút Super Like trên một hồ sơ. Mỗi swipe được lưu vào Firestore (swipes collection).

**FR16:** Khi hai người dùng cùng Like nhau, hệ thống tạo match record trong Firestore và hiển thị match alert ngay lập tức.

**FR17:** Mỗi card hiển thị photo carousel (có thể swipe qua các ảnh), tên, tuổi, job title, khoảng cách (km), và bio.

**FR18:** Người dùng có thể nhấn vào card để xem hồ sơ chi tiết (ProfileDetailView) với đầy đủ thông tin và tất cả ảnh.

**FR19:** Từ ProfileDetailView, người dùng có thể Like, Dislike hoặc Super Like. Nếu tạo match, alert điều hướng trực tiếp tới màn hình chat.

**FR20:** Khi hết cards, ứng dụng tự động tải thêm hồ sơ. Không có duplicate profiles trong cùng một session.

**FR21:** Chức năng swipe có guard chống concurrent requests: không thể swipe khi đang xử lý swipe trước đó.

---

### Module 4: Kết Nối (Matches)

**FR22:** Tab Matches hiển thị hai phần: "Matches mới" (horizontal scroll, compact style) và "Tất cả matches" (danh sách dọc, full style).

**FR23:** Badge "NEW" hiển thị trên match card cho matches chưa nhắn tin.

**FR24:** Người dùng có thể nhấn vào match để bắt đầu hoặc tiếp tục cuộc trò chuyện.

**FR25:** Người dùng có thể hủy match (unmatch) từ màn hình chat hoặc danh sách matches.

---

### Module 5: Trò Chuyện (Chat)

**FR26:** Màn hình Conversations hiển thị danh sách tất cả cuộc trò chuyện, sắp xếp theo thời gian tin nhắn gần nhất. Hiển thị unread count badge cho mỗi cuộc trò chuyện.

**FR27:** Người dùng có thể gửi tin nhắn text trong chat. Tin nhắn rỗng (sau khi trim) không được gửi.

**FR28:** Người dùng có thể gửi ảnh (image) trong chat.

**FR29:** Người dùng có thể gửi GIF trong chat.

**FR30:** Chat cập nhật real-time: tin nhắn mới xuất hiện ngay lập tức không cần refresh.

**FR31:** Tin nhắn được đánh dấu đã đọc (isRead = true) khi người dùng mở màn hình chat.

**FR32:** Mỗi bubble tin nhắn hiển thị thời gian gửi (giờ:phút).

---

### Module 6: Cài Đặt (Settings)

**FR33:** Người dùng có thể điều chỉnh khoảng cách tìm kiếm từ 1 đến 160 km.

**FR34:** Người dùng có thể điều chỉnh range tuổi tìm kiếm từ 18 đến 100.

**FR35:** Người dùng có thể bật/tắt push notification.

**FR36:** Người dùng có thể đăng xuất từ Settings (có confirmation dialog).

**FR37:** Người dùng có thể xóa tài khoản từ Settings (có confirmation dialog, hành động không thể hoàn tác).

---

### Module 7: Thông Báo (Notifications)

**FR38:** Hệ thống gửi push notification khi có match mới.

**FR39:** Hệ thống gửi push notification khi nhận tin nhắn mới.

**FR40:** Hệ thống gửi push notification khi nhận super like.

---

## 4. Yêu Cầu Phi Chức Năng (Non-Functional Requirements)

### Nền Tảng & Môi Trường

**NFR1:** Ứng dụng chỉ hỗ trợ iOS 16.0+, iPhone only (không hỗ trợ iPad).

**NFR2:** Ngôn ngữ lập trình Swift 5.9+, Xcode 15+, SwiftUI làm UI framework chính.

**NFR3:** Tất cả text hiển thị trong UI phải bằng tiếng Việt. Error messages phải được localize sang tiếng Việt.

### Kiến Trúc

**NFR4:** Ứng dụng phải tuân thủ kiến trúc Clean Architecture 3 layers: Presentation → Domain ← Data. Presentation layer không được phụ thuộc trực tiếp vào Data layer.

**NFR5:** Navigation phải thực hiện qua Coordinator Pattern. View không được tự thực hiện navigation.

**NFR6:** Tất cả dependencies phải được inject qua Swinject container. Không hardcode dependencies trong View hay ViewModel.

**NFR7:** Repository implementations ở Data layer phải conform Protocol được định nghĩa ở Domain layer.

### Concurrency & Hiệu Năng

**NFR8:** Tất cả UseCase methods phải sử dụng async/await. Tất cả ViewModels phải được đánh dấu @MainActor.

**NFR9:** Tất cả async entry points (swipe, sendMessage, loadProfiles, v.v.) phải có in-flight guard để ngăn concurrent duplicate requests.

**NFR10:** Danh sách Discover phải tải trong vòng 3 giây khi có kết nối mạng ổn định.

**NFR11:** Chat real-time phải cập nhật tin nhắn trong vòng 2 giây qua Firestore listeners.

### Bảo Mật

**NFR12:** Mật khẩu phải tối thiểu 6 ký tự. Email phải validate format trước khi gửi request.

**NFR13:** Tất cả authenticated API calls phải dùng Firebase Auth token. Không lưu trữ password trong local storage.

**NFR14:** Ảnh upload lên Firebase Storage theo path `photos/{userId}/{UUID}.jpg`. Storage rules chỉ cho phép owner đọc/ghi.

**NFR15:** userId không được lấy từ UserDefaults với fallback `""`. Phải có AuthSessionService centralized cung cấp currentUserId.

### Độ Tin Cậy

**NFR16:** Cold start: Firebase session restore phải re-persist currentUserId. Không được có trạng thái authenticated với userId = "".

**NFR17:** Sau khi logout và login lại bằng account khác, tất cả ViewModels phải nhận userId mới (không stale reference).

**NFR18:** deleteAccount() phải xử lý đúng thứ tự: xóa Firestore data trước, sau đó xóa Firebase Auth. Có error handling cho từng bước.

**NFR19:** Photo upload: nếu JPEG conversion fail, phải fallback sang PNG. Không được silent-fail.

### Testing

**NFR20:** Domain layer (UseCases) phải có unit test coverage.

**NFR21:** Presentation layer (ViewModels) phải có unit test coverage cho business logic.

**NFR22:** Mỗi UseCase, ViewModel phải testable qua Mock repositories.

**NFR23:** UI Tests phải cover auth flow và tab navigation.

### Backend

**NFR24:** Firebase Firestore là database chính. Không dùng local SQLite hay CoreData.

**NFR25:** Firebase Storage dùng cho ảnh user. Path chuẩn: `photos/{userId}/{UUID}.jpg`.

**NFR26:** Firebase Cloud Messaging dùng cho push notifications.

**NFR27:** Firestore collections: `users`, `profiles`, `matches`, `swipes`, `matches/{id}/messages`.

---

## 5. Trường Hợp Đặc Biệt & Ràng Buộc

| ID | Mô tả | Ưu tiên |
|----|-------|---------|
| EC-1 | Khi không có kết nối mạng, hiển thị thông báo lỗi tiếng Việt thay vì crash | Must Have |
| EC-2 | Khi danh sách Discover hết hồ sơ, hiển thị EmptyStateView với CTA refresh | Must Have |
| EC-3 | Khi ảnh tải thất bại, hiển thị placeholder avatar | Must Have |
| EC-4 | Khi HEIC/WebP không convert được sang JPEG, fallback sang PNG | Should Have |
| EC-5 | Firebase Auth errors (network error) phải hiển thị tiếng Việt, không phải localized Firebase default | Should Have |
| EC-6 | Photo URL với trailing slash hoặc encoding khác nhau không được dẫn đến silent no-op khi xóa | Should Have |

---

## 6. Tính Năng Ngoài Phạm Vi v1.0

- Android app
- Web app
- Premium subscription (Gold/Plus)
- Video/Voice call
- Story / Short video
- Profile Boost
- Undo Swipe (Rewind)
- Passport (fake location)
- Report / Block user *(planned v1.1)*
- Admin dashboard / moderation tools
