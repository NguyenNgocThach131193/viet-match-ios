---
stepsCompleted: ["step-01-document-discovery", "step-02-prd-analysis", "step-03-epic-coverage-validation", "step-04-ux-alignment", "step-05-epic-quality-review", "step-06-final-assessment"]
assessmentStatus: "READY_WITH_MINOR_ITEMS"
documentsInventoried:
  prd: "_bmad-output/planning-artifacts/prd.md"
  architecture: "_bmad-output/planning-artifacts/architecture.md"
  epics: "_bmad-output/planning-artifacts/epics.md"
  ux: "_bmad-output/planning-artifacts/ux-design.md"
---

# Implementation Readiness Assessment Report

**Date:** 2026-04-01
**Project:** VietMatch

---

## PRD Analysis

### Functional Requirements

| ID | Module | Mô tả |
|----|--------|-------|
| FR1 | Authentication | Đăng ký tài khoản bằng email và mật khẩu (≥6 ký tự, email format hợp lệ) |
| FR2 | Authentication | Đăng nhập bằng email/password. Hiển thị thông báo lỗi tiếng Việt khi thất bại |
| FR3 | Authentication | Đăng nhập bằng Google Sign-In. Firebase lưu userId sau khi thành công |
| FR4 | Authentication | Đăng nhập bằng Apple ID. Firebase lưu userId sau khi thành công |
| FR5 | Authentication | Quên mật khẩu: nhập email, nhận link đặt lại qua email |
| FR6 | Authentication | Xóa tài khoản vĩnh viễn: xóa cả Firebase Auth record lẫn Firestore data (users, profiles) |
| FR7 | Authentication | Đăng xuất — app điều hướng về màn hình đăng nhập |
| FR8 | Authentication | Cold start session restore: tự động khôi phục session và re-persist userId |
| FR9 | Onboarding | Onboarding 4 bước: (1) tên/tuổi/bio, (2) giới tính, (3) ảnh (1–6), (4) sở thích (≤15) |
| FR10 | Profile | Upload tối đa 6 ảnh lên Firebase Storage, URL lưu trong Firestore profiles |
| FR11 | Profile | Chỉnh sửa hồ sơ sau onboarding: tên, bio, job title, công ty, trường học |
| FR12 | Profile | Thêm, xóa, sắp xếp ảnh — xóa ảnh xóa luôn file Storage và cập nhật Firestore |
| FR13 | Profile | Cập nhật vị trí địa lý (latitude, longitude, city) vào Firestore profile |
| FR14 | Discover | Hiển thị stack cards có thể swipe. Mỗi lần tải tối đa 20 hồ sơ |
| FR15 | Discover | Swipe phải (Like), swipe trái (Dislike), hoặc Super Like — lưu vào Firestore swipes collection |
| FR16 | Discover | Tạo match record khi hai người cùng Like nhau. Hiển thị match alert ngay lập tức |
| FR17 | Discover | Mỗi card: photo carousel, tên, tuổi, job title, khoảng cách (km), bio |
| FR18 | Discover | Nhấn card xem ProfileDetailView với đầy đủ thông tin và tất cả ảnh |
| FR19 | Discover | Like/Dislike/Super Like từ ProfileDetailView. Match alert điều hướng tới chat |
| FR20 | Discover | Auto-load thêm hồ sơ khi hết cards. Không có duplicate profiles trong session |
| FR21 | Discover | Guard chống concurrent swipe requests |
| FR22 | Matches | Tab Matches: "Matches mới" (horizontal scroll) và "Tất cả matches" (danh sách dọc) |
| FR23 | Matches | Badge "NEW" cho matches chưa nhắn tin |
| FR24 | Matches | Nhấn match để bắt đầu hoặc tiếp tục cuộc trò chuyện |
| FR25 | Matches | Unmatch từ màn hình chat hoặc danh sách matches |
| FR26 | Chat | Danh sách conversations sắp xếp theo thời gian mới nhất. Unread count badge |
| FR27 | Chat | Gửi tin nhắn text. Tin nhắn rỗng (sau trim) không được gửi |
| FR28 | Chat | Gửi ảnh trong chat |
| FR29 | Chat | Gửi GIF trong chat |
| FR30 | Chat | Real-time update: tin nhắn mới xuất hiện ngay lập tức |
| FR31 | Chat | Đánh dấu đã đọc (isRead = true) khi mở màn hình chat |
| FR32 | Chat | Mỗi bubble hiển thị thời gian gửi (giờ:phút) |
| FR33 | Settings | Điều chỉnh khoảng cách tìm kiếm: 1–160 km |
| FR34 | Settings | Điều chỉnh range tuổi: 18–100 |
| FR35 | Settings | Bật/tắt push notification |
| FR36 | Settings | Đăng xuất từ Settings (có confirmation dialog) |
| FR37 | Settings | Xóa tài khoản từ Settings (có confirmation dialog, không thể hoàn tác) |
| FR38 | Notifications | Push notification khi có match mới |
| FR39 | Notifications | Push notification khi nhận tin nhắn mới |
| FR40 | Notifications | Push notification khi nhận super like |

**Tổng FRs: 40**

---

### Non-Functional Requirements

| ID | Category | Mô tả |
|----|----------|-------|
| NFR1 | Platform | iOS 16.0+, iPhone only (không hỗ trợ iPad) |
| NFR2 | Platform | Swift 5.9+, Xcode 15+, SwiftUI làm UI framework chính |
| NFR3 | Localization | Tất cả UI text và error messages phải bằng tiếng Việt |
| NFR4 | Architecture | Clean Architecture 3 layers: Presentation → Domain ← Data. Presentation không phụ thuộc Data |
| NFR5 | Architecture | Navigation qua Coordinator Pattern. View không tự navigate |
| NFR6 | Architecture | Tất cả dependencies inject qua Swinject container |
| NFR7 | Architecture | Repository implementations conform Protocol ở Domain layer |
| NFR8 | Concurrency | UseCase methods dùng async/await. ViewModels phải @MainActor |
| NFR9 | Concurrency | In-flight guard cho tất cả async entry points (swipe, sendMessage, loadProfiles, v.v.) |
| NFR10 | Performance | Discover list tải trong vòng 3 giây khi mạng ổn định |
| NFR11 | Performance | Chat real-time cập nhật trong vòng 2 giây qua Firestore listeners |
| NFR12 | Security | Password ≥6 ký tự. Email validate format trước khi gửi request |
| NFR13 | Security | Firebase Auth token cho authenticated calls. Không lưu password local |
| NFR14 | Security | Firebase Storage path: `photos/{userId}/{UUID}.jpg`. Rules chỉ owner đọc/ghi |
| NFR15 | Security | AuthSessionService centralized cung cấp currentUserId. Không dùng UserDefaults fallback "" |
| NFR16 | Reliability | Cold start: Firebase session restore phải re-persist userId. Không trạng thái userId="" |
| NFR17 | Reliability | Sau logout/login bằng account khác, ViewModels nhận userId mới (không stale) |
| NFR18 | Reliability | deleteAccount(): xóa Firestore trước, sau đó xóa Firebase Auth. Error handling từng bước |
| NFR19 | Reliability | Photo upload: JPEG fail → fallback PNG. Không silent-fail |
| NFR20 | Testing | Domain layer (UseCases) có unit test coverage |
| NFR21 | Testing | Presentation layer (ViewModels) có unit test coverage cho business logic |
| NFR22 | Testing | UseCase và ViewModel testable qua Mock repositories |
| NFR23 | Testing | UI Tests cover auth flow và tab navigation |
| NFR24 | Backend | Firestore là database chính (không dùng SQLite/CoreData) |
| NFR25 | Backend | Firebase Storage cho ảnh. Path: `photos/{userId}/{UUID}.jpg` |
| NFR26 | Backend | Firebase Cloud Messaging cho push notifications |
| NFR27 | Backend | Firestore collections: `users`, `profiles`, `matches`, `swipes`, `matches/{id}/messages` |

**Tổng NFRs: 27**

---

### Additional Requirements (Edge Cases & Constraints)

| ID | Mô tả | Ưu tiên |
|----|-------|---------|
| EC-1 | Không có mạng → hiển thị thông báo lỗi tiếng Việt, không crash | Must Have |
| EC-2 | Discover hết hồ sơ → hiển thị EmptyStateView với CTA refresh | Must Have |
| EC-3 | Ảnh tải thất bại → hiển thị placeholder avatar | Must Have |
| EC-4 | HEIC/WebP không convert sang JPEG → fallback PNG | Should Have |
| EC-5 | Firebase Auth errors phải hiển thị tiếng Việt | Should Have |
| EC-6 | Photo URL với trailing slash/encoding khác không dẫn đến silent no-op khi xóa | Should Have |

**Ngoài phạm vi v1.0:** Android, Web, Premium, Video/Voice call, Story, Boost, Undo Swipe, Passport, Report/Block (planned v1.1), Admin dashboard.

---

### PRD Completeness Assessment

PRD được viết đầy đủ, rõ ràng với **40 FRs** và **27 NFRs** có đánh số nhất quán. Mỗi requirement được mô tả cụ thể với điều kiện và hành vi mong đợi. Edge cases được liệt kê riêng biệt với mức độ ưu tiên rõ ràng. Tài liệu đủ chất lượng để tiến hành Epic Coverage Validation.

---

## Epic Coverage Validation

### Coverage Matrix

| FR | Mô tả ngắn | Epic | Status |
|----|-----------|------|--------|
| FR1 | Đăng ký email/password | Epic 1 | ✓ Covered |
| FR2 | Đăng nhập email/password | Epic 1 | ✓ Covered |
| FR3 | Google Sign-In | Epic 1 | ✓ Covered |
| FR4 | Apple Sign-In | Epic 1 | ✓ Covered |
| FR5 | Forgot password | Epic 1 | ✓ Covered |
| FR6 | Xóa tài khoản vĩnh viễn | Epic 5 | ✓ Covered |
| FR7 | Đăng xuất | Epic 1 | ✓ Covered |
| FR8 | Cold start session restore | Epic 1 | ✓ Covered |
| FR9 | 4-bước onboarding | Epic 2 | ✓ Covered |
| FR10 | Upload ảnh (tối đa 6) | Epic 2 | ✓ Covered |
| FR11 | Edit profile | Epic 2 | ✓ Covered |
| FR12 | Thêm/xóa/sắp xếp ảnh | Epic 2 | ✓ Covered |
| FR13 | Cập nhật vị trí địa lý | Epic 2 | ✓ Covered |
| FR14 | Card stack (tải 20 profiles) | Epic 3 | ✓ Covered |
| FR15 | Swipe like/dislike/super like | Epic 3 | ✓ Covered |
| FR16 | Match detection + alert | Epic 3 | ✓ Covered |
| FR17 | Card content (ảnh, tên, tuổi, khoảng cách) | Epic 3 | ✓ Covered |
| FR18 | Tap card → ProfileDetailView | Epic 3 | ✓ Covered |
| FR19 | Like/dislike từ ProfileDetailView | Epic 3 | ✓ Covered |
| FR20 | Auto load more, no duplicates | Epic 3 | ✓ Covered |
| FR21 | Concurrency guard cho swipe | Epic 3 | ✓ Covered |
| FR22 | Matches list (2 sections) | Epic 3 | ✓ Covered |
| FR23 | NEW badge trên match cards | Epic 3 | ✓ Covered |
| FR24 | Tap match → bắt đầu chat | Epic 3 | ✓ Covered |
| FR25 | Unmatch từ chat | Epic 4 | ✓ Covered |
| FR26 | Conversations list + unread badges | Epic 4 | ✓ Covered |
| FR27 | Gửi text message | Epic 4 | ✓ Covered |
| FR28 | Gửi ảnh trong chat | Epic 4 | ✓ Covered |
| FR29 | Gửi GIF trong chat | Epic 4 | ✓ Covered |
| FR30 | Real-time updates | Epic 4 | ✓ Covered |
| FR31 | Đánh dấu đã đọc | Epic 4 | ✓ Covered |
| FR32 | Timestamp trên bubble | Epic 4 | ✓ Covered |
| FR33 | Distance filter (1–160 km) | Epic 5 | ✓ Covered |
| FR34 | Age range filter (18–100) | Epic 5 | ✓ Covered |
| FR35 | Push notification toggle | Epic 5 | ✓ Covered |
| FR36 | Đăng xuất từ Settings | Epic 5 | ✓ Covered |
| FR37 | Xóa tài khoản từ Settings | Epic 5 | ✓ Covered |
| FR38 | Push: match mới | Epic 5 | ✓ Covered |
| FR39 | Push: tin nhắn mới | Epic 5 | ✓ Covered |
| FR40 | Push: super like | Epic 5 | ✓ Covered |

### Missing Requirements

Không có FR nào bị thiếu trong epics document. Tất cả 40 FRs đều có coverage.

### Coverage Statistics

- Total PRD FRs: 40
- FRs covered in epics: 40
- Coverage percentage: **100%**

**Phân bố theo Epic:**
- Epic 1 (Authentication): FR1, FR2, FR3, FR4, FR5, FR7, FR8 — 7 FRs
- Epic 2 (Onboarding & Profile): FR9, FR10, FR11, FR12, FR13 — 5 FRs
- Epic 3 (Discover & Matches): FR14–FR24 — 11 FRs
- Epic 4 (Chat): FR25–FR32 — 8 FRs
- Epic 5 (Settings & Notifications): FR6, FR33–FR40 — 9 FRs

---

## UX Alignment Assessment

### UX Document Status

**Tìm thấy:** `_bmad-output/planning-artifacts/ux-design.md` — đầy đủ với Design System, Components, Screen Specs, và 10 UX-DRs.

### UX ↔ PRD Alignment

| UX-DR | Liên kết PRD | Alignment |
|-------|-------------|-----------|
| UX-DR1: Match alert "Nhắn tin ngay" → ChatView | FR16, FR19 | ⚠️ PRD FR16 chỉ nói "hiển thị match alert" — không specify navigation. UX-DR1 làm rõ button phải navigate (không chỉ dismiss). Đã được capture trong epics. |
| UX-DR2: Khoảng cách (km) trên swipe cards | FR17 | ✓ PRD FR17 có "khoảng cách (km)" trong card content |
| UX-DR3: Tap CardView → ProfileDetailView | FR18 | ✓ PRD FR18 mô tả rõ tap card → ProfileDetailView |
| UX-DR4: ConversationsView auto-navigate từ MatchesView | FR24 | ⚠️ PRD FR24 chỉ nói "tap match → chat". UX-DR4 làm rõ coordination giữa MatchesTab và ChatCoordinator. Đã được capture trong epics. |
| UX-DR5: Unsaved changes dialog khi dismiss EditProfileView | FR11 | ⚠️ Không có trong PRD — UX-DR5 bổ sung requirement. Đã được capture trong epics (Epic 2, UX-DRs). |
| UX-DR6: Firebase Auth errors tiếng Việt | FR2, NFR3 | ✓ PRD có NFR3 và EC-5 đề cập tiếng Việt |
| UX-DR7: Photo delete URL mismatch handling | FR12, EC-6 | ✓ PRD EC-6 mô tả chính xác vấn đề này |
| UX-DR8: Google Sign-In button disable khi isLoading | FR3 | ⚠️ PRD FR3 không specify button state. UX-DR8 làm rõ behavior. Đã được capture trong epics. |
| UX-DR9: Empty state khi hết cards | FR20, EC-2 | ✓ PRD EC-2 có EmptyStateView với CTA refresh |
| UX-DR10: Photo counter "X/6" trong onboarding | FR9, FR10 | ✓ PRD FR9 có "bắt buộc ít nhất 1 ảnh". UX-DR10 làm rõ counter display. |

### UX ↔ Architecture Alignment

| UX Requirement | Architecture Support | Status |
|---------------|---------------------|--------|
| Design System (Colors, Typography, Spacing) | `VietMatchColors`, `VietMatchTypography`, `VietMatchSpacing` trong Presentation layer | ✓ Aligned |
| GradientButton component | Listed trong Components | ✓ Aligned |
| SwipeCardStack component | Listed trong Components | ✓ Aligned |
| ProfileImageView component | Listed trong Components | ✓ Aligned |
| Match alert → navigate to ChatView (UX-DR1) | Coordinator rule: "Match alert → navigate to ChatView phải đi qua ChatCoordinator" | ✓ Aligned |
| ConversationsView coordination (UX-DR4) | ChatCoordinator + MatchesCoordinator trong MainTabCoordinator | ✓ Aligned |
| Vietnamese error messages (UX-DR6) | AuthError enum với Vietnamese messages | ✓ Aligned |
| Loading states (isLoading pattern) | In-Flight Guard Pattern bắt buộc trong ViewModels | ✓ Aligned |
| GIF trong chat (FR29) | SendMessageUseCase, ChatRepository — nhưng UX ChatView spec không đề cập GIF UI element | ⚠️ Minor gap: UX spec thiếu spec cho GIF picker/button trong ChatView input bar |
| Deep link từ push notification | AppCoordinator với deep link support | ✓ Aligned |

### Warnings

1. **⚠️ Use Case Count Inconsistency:** Architecture doc Section 4 tiêu đề "12 Use Cases" nhưng bảng liệt kê **13 use cases** (thêm `GetConversationsUseCase`). Epics Additional Requirements cũng ghi "12 Use Cases" nhưng liệt kê 13. Đây là lỗi documentation nhỏ — thực tế cần implement 13.

2. **⚠️ UX-DR5 không có trong PRD:** Confirmation dialog khi dismiss EditProfileView với unsaved changes chỉ xuất hiện trong UX document, không có trong PRD. Đã được capture trong epics (Epic 2) nên không ảnh hưởng implementation — nhưng PRD nên được cập nhật.

3. **⚠️ GIF UI Spec thiếu trong UX:** UX document mô tả ChatView input bar (TextField + image icon + send button) nhưng không đề cập GIF picker button, mặc dù FR29 yêu cầu gửi GIF. Implementation cần tự quyết định GIF picker UX.

---

## Epic Quality Review

### Epic Structure Validation

| Epic | User Value | Independence | Verdict |
|------|-----------|-------------|---------|
| Epic 1: Xác Thực & Quản Lý Phiên | ✓ Users có thể đăng ký, đăng nhập | ✓ Standalone | ✓ Pass |
| Epic 2: Onboarding & Quản Lý Hồ Sơ | ✓ Users có thể tạo profile đầy đủ | ✓ Requires Epic 1 only | ✓ Pass |
| Epic 3: Khám Phá & Kết Nối | ✓ Users có thể swipe và match | ✓ Requires Epic 1+2 | ✓ Pass |
| Epic 4: Trò Chuyện Real-time | ✓ Users có thể nhắn tin với matches | ✓ Requires Epic 1+2+3 | ✓ Pass |
| Epic 5: Cài Đặt, Thông Báo & Tài Khoản | ✓ Users kiểm soát app và tài khoản | ✓ Requires Epic 1+2 | ✓ Pass |

**Nhận xét chung:** Không có "technical epics" (ví dụ: "Setup Database", "Create Models"). Tất cả 5 epics đều user-centric và phân cấp dependency hợp lý.

### Story Quality Assessment

**Epic 1 — Xác Thực:**

| Story | User Value | ACs Format | Independence | Issues |
|-------|-----------|-----------|-------------|--------|
| 1.1 Đăng ký Email | ✓ | ✓ Given/When/Then | ✓ | Story title OK |
| 1.2 Đăng nhập Email | ✓ | ✓ | ✓ | |
| 1.3 Đặt lại mật khẩu | ✓ | ✓ | ✓ | |
| 1.4 Google Sign-In | ✓ | ✓ | ✓ | |
| 1.5 Apple Sign-In | ✓ | ✓ | ✓ | |
| 1.6 Session Restore | ✓ | ✓ | ✓ | 🟠 Tiêu đề kỹ thuật: "AuthSessionService & Cold Start" |
| 1.7 Đăng xuất | ✓ | ✓ | ✓ | |

**Epic 2 — Onboarding:**

| Story | User Value | ACs Format | Independence | Issues |
|-------|-----------|-----------|-------------|--------|
| 2.1 Bước 1 & 2 | ✓ | ✓ | ✓ | |
| 2.2 Photo Upload | ✓ | ✓ | ✓ Requires 2.1 flow | |
| 2.3 Sở thích & Hoàn tất | ✓ | ✓ | ✓ | 🟡 AC nói "sở thích optional" nhưng FR9 không explicit |
| 2.4 Edit Profile | ✓ | ✓ | ✓ | |
| 2.5 Quản lý ảnh | ✓ | ✓ | ✓ | |
| 2.6 Cập nhật vị trí | ✓ | ✓ | ✓ | |

**Epic 3 — Discover:**

| Story | User Value | ACs Format | Independence | Issues |
|-------|-----------|-----------|-------------|--------|
| 3.1 Card Stack | ✓ | ✓ | ✓ | |
| 3.2 Swipe | ✓ | ✓ | ✓ | 🟡 Distance compute AC overlaps với Story 2.6 |
| 3.3 Match Detection | ✓ | ✓ | ✓ Requires 3.2 | |
| 3.4 Profile Detail | ✓ | ✓ | ✓ | |
| 3.5 Matches List | ✓ | ✓ | ✓ | |
| 3.6 Empty State | ✓ | ✓ | ✓ | |

**Epic 4 — Chat:**

| Story | User Value | ACs Format | Independence | Issues |
|-------|-----------|-----------|-------------|--------|
| 4.1 Conversations List | ✓ | ✓ | ✓ | |
| 4.2 Gửi/nhận Text | ✓ | ✓ | ✓ | |
| 4.3 Gửi Ảnh & GIF | ✓ | ✓ | ✓ | |
| 4.4 Cross-tab Nav & Unmatch | ✓ | ✓ | ✓ | 🟠 Kết hợp 2 concerns khác nhau |

**Epic 5 — Settings:**

| Story | User Value | ACs Format | Independence | Issues |
|-------|-----------|-----------|-------------|--------|
| 5.1 Bộ lọc tìm kiếm | ✓ | ✓ | ✓ | |
| 5.2 Push Notifications | ✓ | ✓ | ✓ | 🟠 Story quá lớn — 4 concerns trong 1 story |
| 5.3 Logout & Delete Account | ✓ | ✓ | ✓ | 🟠 DeleteAccountUseCase không có trong Architecture |

### Quality Findings

#### 🟠 Major Issues

**Issue QR-1: Story 1.6 — Tiêu đề kỹ thuật**
- Story title: "AuthSessionService & Cold Start Session Restore"
- Vấn đề: Tiêu đề expose technical implementation thay vì user value
- Recommendation: Đổi thành "Phiên đăng nhập được duy trì tự động khi khởi động lại app"
- ACs bên trong story hoàn toàn đúng — chỉ cần đổi tên

**Issue QR-2: Story 4.4 — Kết hợp 2 concerns khác nhau**
- Story "Cross-tab Navigation & Hủy Match" gộp: (1) UX coordination pattern (navigate từ Matches sang Chat) và (2) Unmatch feature (domain action xóa match)
- Vấn đề: Khó estimate, khó test độc lập, implementation phức tạp hơn cần thiết
- Recommendation: Tách thành Story 4.4a "Điều hướng từ Matches sang Chat" và Story 4.4b "Hủy Match"

**Issue QR-3: Story 5.2 — Oversized story**
- Story "Quản Lý Push Notifications" bao gồm: FCM registration, FCM unregistration, 3 loại push (match/message/super like), deep link handling từ notification
- Vấn đề: Ước tính 3–5 sprints nếu tính riêng; quá nhiều ACs (6 Given/When/Then scenarios phức tạp)
- Recommendation: Có thể giữ nguyên nếu team có kinh nghiệm FCM, hoặc tách thành 5.2a "Đăng ký/hủy đăng ký FCM" và 5.2b "Nhận & xử lý push notifications"

**Issue QR-4: DeleteAccountUseCase không có trong Architecture**
- Story 5.3 AC sử dụng `DeleteAccountUseCase.execute()` với step-by-step verification
- Vấn đề: Architecture Section 4 không list `DeleteAccountUseCase` trong bảng 12+1 use cases. Điều này tạo ra gap giữa epics và architecture.
- Recommendation: Cập nhật Architecture document — thêm `DeleteAccountUseCase` vào bảng Use Cases (Group Auth, throws AuthError + APIError), update count từ "12" thành "14" (đã có sai số 12→13, nay cần 14).

#### 🟡 Minor Concerns

**Issue QR-5: Story 2.3 — "Sở thích optional" không có trong PRD**
- AC: "nút 'Hoàn tất' enabled (sở thích là optional)"
- PRD FR9 Bước 4: "Chọn sở thích (tối đa 15 lựa chọn)" — không nói required hay optional
- Recommendation: PRD nên làm rõ optional/required. Story hiện tại chọn optional — đây là quyết định thiết kế hợp lý nhưng cần document.

**Issue QR-6: Use Case count inconsistency (13 ≠ 12)**
- Architecture doc nói "12 Use Cases" nhưng liệt kê 13 (bao gồm GetConversationsUseCase)
- Epics Additional Requirements cũng nói "12 Use Cases" nhưng liệt kê 13
- Với DeleteAccountUseCase (QR-4), con số thực tế là 14
- Recommendation: Cập nhật tất cả tài liệu để phản ánh đúng 14 use cases.

### Best Practices Compliance

| Epic | User Value | Independent | Story Sizing | No Forward Deps | Clear ACs | FR Traceability |
|------|-----------|------------|-------------|----------------|-----------|----------------|
| Epic 1 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Epic 2 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Epic 3 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Epic 4 | ✓ | ✓ | ⚠️ 4.4 mixed | ✓ | ✓ | ✓ |
| Epic 5 | ✓ | ✓ | ⚠️ 5.2 large | ✓ | ✓ | ✓ |

**Tổng stories: 22 stories** (1.1–1.7, 2.1–2.6, 3.1–3.6, 4.1–4.4, 5.1–5.3)

**Kết luận:** Không có critical violations. 4 major issues cần xem xét trước khi implement. Cấu trúc tổng thể tốt.

---

## Summary and Recommendations

### Overall Readiness Status

> ## ✅ READY (với điều kiện giải quyết 1 blocking item)

Dự án VietMatch có nền tảng planning tốt. Tất cả 40 FRs được cover đầy đủ, kiến trúc rõ ràng, UX spec chi tiết. Chỉ có 1 item cần giải quyết trước khi implement và 6 items có thể xử lý song song.

---

### Tổng Hợp Issues

| ID | Loại | Mức độ | Mô tả ngắn |
|----|------|--------|-----------|
| QR-4 | Epic Gap | 🔴 Blocking | `DeleteAccountUseCase` thiếu trong Architecture doc |
| QR-2 | Epic Quality | 🟠 Major | Story 4.4 gộp 2 concerns khác nhau |
| QR-3 | Epic Quality | 🟠 Major | Story 5.2 oversized (quá nhiều ACs) |
| UX-W2 | UX/PRD Gap | 🟠 Major | UX-DR5 (unsaved changes dialog) không có trong PRD |
| UX-W3 | UX Gap | 🟠 Major | GIF picker UI spec thiếu trong UX document |
| QR-1 | Epic Quality | 🟡 Minor | Story 1.6 tiêu đề kỹ thuật |
| QR-5 | PRD Ambiguity | 🟡 Minor | Sở thích optional/required không rõ trong PRD |
| QR-6 | Doc Consistency | 🟡 Minor | Use Case count sai (12 vs 13 vs 14 thực tế) |

**Tổng: 1 blocking, 4 major, 3 minor**

---

### Critical Issues Requiring Immediate Action

**QR-4 — DeleteAccountUseCase thiếu trong Architecture (BLOCKING)**

Đây là issue duy nhất thực sự blocking. Story 5.3 yêu cầu `DeleteAccountUseCase` với logic xóa theo thứ tự cụ thể (Firestore → Storage → Auth), nhưng Architecture document không định nghĩa use case này. Developer implement Story 5.3 sẽ không có contract rõ ràng.

**Giải pháp:** Thêm vào Architecture Section 4:

```
| Auth | DeleteAccountUseCase | userId không rỗng | AuthError + APIError |
```

Và cập nhật DI Assembly (DomainAssembly phải register DeleteAccountUseCase).

---

### Recommended Next Steps

**Trước khi bắt đầu implementation:**

1. **[Blocking — 15 phút]** Cập nhật `architecture.md` Section 4 — thêm `DeleteAccountUseCase`, sửa count từ "12" thành "14", liệt kê đủ 14 use cases (cả `GetConversationsUseCase`).

2. **[Recommended — 30 phút]** Tách Story 4.4 thành 2 stories:
   - Story 4.4: "Điều hướng liền mạch từ Matches sang Chat" (cross-tab coordination)
   - Story 4.5: "Hủy Match" (unmatch domain action)

3. **[Optional — 20 phút]** Tách Story 5.2 thành 5.2 + 5.3, đẩy Story 5.3 cũ thành 5.4:
   - Story 5.2: "Đăng ký/hủy push notification"
   - Story 5.3: "Nhận push notification cho match, tin nhắn, super like"

4. **[Optional — 10 phút]** Sửa Story 1.6 title: "Phiên đăng nhập được duy trì tự động khi khởi động lại app"

5. **[Optional — 10 phút]** Làm rõ trong PRD FR9: sở thích (Bước 4) là optional hay required.

6. **[Optional — 5 phút]** Thêm GIF picker spec vào UX ChatView section (input bar có 2 icons: image + GIF).

---

### Final Note

Assessment này phát hiện **8 issues** trong **4 categories** (Epic Gap, Epic Quality, UX/PRD Alignment, Doc Consistency).

Không có critical violation nào về coverage, kiến trúc tổng thể, hay dependency ordering. Epics và stories được viết với user-value focus, Given/When/Then format đúng chuẩn, và FR traceability 100%.

**Khuyến nghị:** Giải quyết QR-4 (5–15 phút) rồi bắt đầu implementation. Các items còn lại có thể xử lý song song với Epic 1–2 mà không block.

---

*Báo cáo được tạo bởi Implementation Readiness Assessment Workflow*
*Ngày: 2026-04-01 | Dự án: VietMatch | Người đánh giá: Claude Code (BMAD)*
