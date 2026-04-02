---
type: project-brief
project: VietMatch
version: 1.0
date: 2026-04-01
---

# VietMatch — Project Brief

## 1. Tổng Quan Dự Án

**VietMatch** là ứng dụng hẹn hò dành riêng cho cộng đồng người Việt, chạy trên nền tảng iOS. Ứng dụng cho phép người dùng tạo hồ sơ cá nhân, khám phá hồ sơ người khác qua thao tác swipe, kết nối khi có sự tương hợp (match), và trò chuyện trực tiếp với nhau.

---

## 2. Vấn Đề Cần Giải Quyết

Các ứng dụng hẹn hò phổ biến hiện nay (Tinder, Bumble) không có giao diện và nội dung tối ưu cho người dùng Việt Nam. Người dùng Việt cần:

- Giao diện hoàn toàn bằng tiếng Việt
- UX phù hợp với văn hóa địa phương
- Tính năng tìm kiếm dựa trên vị trí thực tế tại Việt Nam
- Backend đảm bảo tốc độ và độ tin cậy cho thị trường Việt

---

## 3. Mục Tiêu Sản Phẩm

| Mục tiêu | Thước đo thành công |
|----------|---------------------|
| Cho phép người dùng tạo và quản lý hồ sơ hẹn hò | Hoàn thành onboarding 4 bước, tải tối đa 6 ảnh |
| Kết nối người dùng phù hợp thông qua swipe | Swipe like/dislike/super like, match alert real-time |
| Tạo kênh giao tiếp an toàn giữa các matches | Chat text/image/GIF real-time qua Firestore |
| Cung cấp kiểm soát tìm kiếm cho người dùng | Lọc theo khoảng cách (1–160 km), độ tuổi (18–100) |
| Xác thực an toàn đa phương thức | Email/Password, Google, Apple Sign-In |

---

## 4. Đối Tượng Người Dùng

**Người dùng chính:** Người Việt Nam từ 18 tuổi trở lên, sử dụng iPhone, tìm kiếm kết nối lãng mạn hoặc bạn bè.

**Đặc điểm:**
- Quen với ứng dụng mobile-first
- Ưu tiên privacy và bảo mật tài khoản
- Sử dụng ngôn ngữ Việt trong giao tiếp hàng ngày

---

## 5. Phạm Vi Phiên Bản 1.0

### Trong Phạm Vi

- Xác thực: Email/Password, Google Sign-In, Apple Sign-In, quên mật khẩu, xóa tài khoản
- Onboarding: 4 bước (thông tin cá nhân, giới tính, ảnh, sở thích)
- Khám phá: Swipe cards (like/dislike/super like), photo carousel, tải 20 hồ sơ/lần
- Xem hồ sơ chi tiết từ card
- Matches: Danh sách matches mới + tất cả matches, hủy match
- Chat: Tin nhắn real-time (text/image/GIF), danh sách cuộc trò chuyện, unread count
- Hồ sơ: Xem/chỉnh sửa hồ sơ, quản lý ảnh (tối đa 6)
- Cài đặt: Tùy chỉnh khoảng cách, độ tuổi, thông báo, đăng xuất
- Push notification: match mới, tin nhắn mới, super like

### Ngoài Phạm Vi

- Web app hoặc Android app
- Tính năng Premium / Subscription (Gold/Plus)
- Video call / Voice call
- Story / Reels tính năng ngắn
- Boost profile visibility
- Undo swipe (Rewind)
- Passport (thay đổi vị trí giả)
- Báo cáo / Block người dùng (planned cho v2)

---

## 6. Tech Stack Quyết Định

| Hạng mục | Lựa chọn | Lý do |
|----------|---------|-------|
| Platform | iOS (iPhone only) | MVP tập trung, iOS có user base cao hơn ở Việt Nam cho ứng dụng premium |
| UI Framework | SwiftUI (iOS 16+) | Modern declarative UI, preview support |
| Architecture | Clean Architecture + MVVM-C | Testability, separation of concerns, scalability |
| Backend | Firebase | Auth + Firestore real-time + Storage + FCM trong một platform |
| DI | Swinject | Mature, flexible DI container cho Swift |
| Navigation | Coordinator Pattern | Decoupled navigation, testable |
| Image Loading | Kingfisher | Async loading + caching cho photo-heavy app |
| Networking | Alamofire | Stable HTTP layer |
| Project Config | XcodeGen | Reproducible project, no .xcodeproj conflicts |

---

## 7. Ràng Buộc Kỹ Thuật

- iOS 16.0+ minimum deployment target
- iPhone only (không hỗ trợ iPad)
- Swift 5.9+, Xcode 15+
- Firebase backend (không tự-host)
- Tất cả UI text phải bằng tiếng Việt
- Mật khẩu tối thiểu 6 ký tự
- Ảnh tải lên tối đa 6 ảnh/hồ sơ
- Danh sách khám phá tải tối đa 20 hồ sơ/lần

---

## 8. Trạng Thái Hiện Tại (Tháng 4/2026)

Sprint 1 (Epic 1 — Foundation) đã hoàn thành với 9 stories:

| Story | Mô tả | Trạng thái |
|-------|-------|-----------|
| 1.1 | ForgotPasswordView | ✅ Done |
| 1.2 | ProfileDetailView | ✅ Done |
| 1.3 | EditProfile PhotoGrid | ✅ Done |
| 1.4 | Google Sign-In | ✅ Done |
| 1.5 | Fix Chat hardcoded userId | ✅ Done |
| 1.6 | Fix Discover hardcoded userId | ✅ Done |
| 1.7 | AuthSessionService | ✅ Done |
| 1.8 | Concurrency Guards | ✅ Done |
| 1.9 | Photo Save Flow | ✅ Done |

**Deferred items còn lại:** AUTH-1, AUTH-5–8, CONC-4, PHOTO-4–5, FEAT-1–3, DI-1, EDGE-1–2, CFG-1

---

## 9. Định Hướng Sprint Tiếp Theo

Ưu tiên các vấn đề còn lại từ deferred-work.md trước khi xây dựng tính năng mới:

1. **Auth Hardening** — Cold start restore, stale userId, DI lifecycle, deleteAccount race condition
2. **Feature Completion** — Match alert navigate to chat, distance display, tap card to ProfileDetail
3. **Quality & Resilience** — HEIC/WebP fallback, localized Firebase errors, DI force-unwrap safety
4. **New Features (v1.1+)** — Report/Block user, Boost, Undo swipe
