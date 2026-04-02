---
type: ux-design
project: VietMatch
version: 1.0
date: 2026-04-01
---

# VietMatch — UX Design Specification

## 1. Tổng Quan UX

VietMatch theo triết lý **mobile-first, gesture-driven UI**. Người dùng tương tác chủ yếu qua swipe gestures trên card stack. Thiết kế ưu tiên:

- **Tốc độ:** Tối thiểu thao tác để đến tính năng chính
- **Cảm giác trực quan:** Swipe = physical metaphor (like/dislike)
- **Tiếng Việt toàn bộ:** Không có text tiếng Anh trong UI
- **Màu sắc ấm:** Branding pink-to-rose phù hợp với chủ đề hẹn hò

---

## 2. Design System

### 2.1 Color Tokens

| Token | Giá trị Hex | Ngữ nghĩa |
|-------|------------|-----------|
| `primary` | `#FE3C72` | Hot Pink — brand color chính, buttons, accents |
| `primaryLight` | `#FF6B6B` | Gradient start, softer interactions |
| `primaryDark` | `#E91E63` | Gradient end, pressed state |
| `secondary` | `#FF8A65` | Secondary actions, warm orange |
| `accent` | `#FFD54F` | Highlights, super like yellow |
| `background` | `#FAFAFA` | App background (near-white) |
| `cardBackground` | `#FFFFFF` | Card surfaces |
| `darkBackground` | `#1A1A2E` | Dark mode / overlay contexts |
| `textPrimary` | `#21262E` | Body text, headings |
| `textSecondary` | `#6C757D` | Subtitles, captions, placeholder |
| `textLight` | `#FFFFFF` | Text trên dark/gradient backgrounds |
| `success` | `#4CAF50` | Like action, positive feedback |
| `error` | `#F44336` | Dislike action, errors |
| `info` | `#2196F3` | Super Like, informational |
| `warning` | `#FF9800` | Warnings |

**Gradients:**

| Gradient | Composition | Dùng cho |
|----------|------------|---------|
| `primaryGradient` | `primaryLight → primary → primaryDark` | Primary buttons, branding elements |
| `cardGradient` | `clear → black(opacity 0.7)` | Card photo overlay (readability) |
| `warmGradient` | `#FF6B6B → #FE3C72 → #FF8A65` | Decorative, onboarding backgrounds |

### 2.2 Typography

Font family: **SF Pro Rounded** cho tiêu đề, **SF Pro** (default) cho body text.

| Style | Size | Weight | Design | Dùng cho |
|-------|------|--------|--------|---------|
| `largeTitle` | 34 | Bold | Rounded | Screen titles lớn |
| `title1` | 28 | Bold | Rounded | Section headers |
| `title2` | 22 | Semibold | Rounded | Card titles, modal headers |
| `title3` | 20 | Semibold | Rounded | Sub-section headers |
| `headline` | 17 | Semibold | Default | Item titles, labels |
| `body` | 17 | Regular | Default | Body text |
| `callout` | 16 | Regular | Default | Secondary body |
| `subheadline` | 15 | Regular | Default | Captions, metadata |
| `footnote` | 13 | Regular | Default | Fine print |
| `caption` | 12 | Regular | Default | Timestamps, tags |
| `caption2` | 11 | Regular | Default | Micro text |
| `cardName` | 28 | Bold | Rounded | Tên trên swipe card |
| `cardAge` | 24 | Light | Rounded | Tuổi trên swipe card |
| `cardInfo` | 16 | Medium | Default | Job, distance trên card |

### 2.3 Spacing Scale

| Token | Value (pt) | Dùng cho |
|-------|-----------|---------|
| `xxs` | 2 | Micro gaps |
| `xs` | 4 | Tight element gaps |
| `sm` | 8 | Small internal padding |
| `md` | 12 | Medium gaps |
| `lg` | 16 | Standard padding (card, screen) |
| `xl` | 24 | Section spacing |
| `xxl` | 32 | Large section breaks |
| `xxxl` | 48 | Extra large (onboarding steps) |
| `cardPadding` | 16 | Card internal padding |
| `cardCornerRadius` | 16 | Card corner radius |
| `buttonHeight` | 52 | Standard button height |
| `buttonCornerRadius` | 26 | Pill-shaped buttons |
| `avatarSmall` | 40 | Small avatars (tab bar, list) |
| `avatarMedium` | 60 | Medium avatars (matches list) |
| `avatarLarge` | 100 | Large avatars (profile view) |

---

## 3. Components

### 3.1 GradientButton (Primary Action Button)

**Mô tả:** Button chính của app — gradient từ `primaryLight → primary → primaryDark`, full width, pill shape.

**Props:**
- `title: String` — Text hiển thị
- `icon: String?` — SF Symbol name (optional, hiển thị bên trái title)
- `isLoading: Bool` — Khi true: ẩn text, hiện ProgressView spinner trắng
- `action: () -> Void` — Tap callback

**Visual specs:**
- Height: 52pt, Corner radius: 26pt (pill)
- Background: LinearGradient(`primaryLight`, `primary`, `primaryDark`)
- Text: white, `headline` style
- Loading state: ProgressView spinner màu trắng thay title
- Disabled state: opacity 0.6, không nhận touch

**Khi nào dùng:** Login, Register, Send message, Save profile, Continue onboarding, Confirm actions.

### 3.2 ProfileImageView (Avatar Component)

**Mô tả:** Circle avatar với async loading qua Kingfisher.

**Props:**
- `url: String?` — Image URL (nil → hiển thị placeholder)
- `size: CGFloat` — Diameter của circle
- `showBorder: Bool` — Hiển thị 2pt white border với primary color glow

**Visual specs:**
- Shape: Circle clip
- Placeholder: `person.fill` SF Symbol, background `textSecondary.opacity(0.2)`
- Border: 2pt white + inner shadow với `primary` color
- Loading: KFImage với `placeholder` modifier

### 3.3 SwipeCardStack (Card Stack Component)

**Mô tả:** Generic card stack với 3D perspective effect, drag gesture detection.

**Props:**
- `data: [T]` — Array of items
- `onSwipeLeft: (T) -> Void` — Dislike callback
- `onSwipeRight: (T) -> Void` — Like callback
- `content: (T) -> Content` — ViewBuilder cho mỗi card

**Interaction specs:**
- Drag threshold: > 100pt horizontal → trigger swipe
- 3D tilt effect: rotationEffect based on drag offset
- Stack depth: 3 visible cards, scale 0.95/0.90 cho cards phía sau
- Swipe animation: spring(damping: 0.7)
- LIKE indicator: màu `success`, góc trên bên trái khi drag phải
- NOPE indicator: màu `error`, góc trên bên phải khi drag trái

### 3.4 LoadingView

**Mô tả:** Full-screen loading overlay.

**Props:**
- `message: String` — Default: "Đang tải..."

**Visual:** ProgressView spinner + caption text, vertically centered.

### 3.5 EmptyStateView

**Mô tả:** Empty state placeholder với optional CTA.

**Props:**
- `icon: String` — SF Symbol name
- `title: String` — Tiêu đề (headline style)
- `message: String` — Mô tả (body style, textSecondary)
- `actionTitle: String?` — Text nút (optional)
- `action: (() -> Void)?` — CTA callback

**Visual:** Icon trong gradient circle background (48pt), title, message, optional GradientButton.

---

## 4. Screen Specifications

### 4.1 Auth Flow

#### LoginView
**Layout:** Logo + tagline → form fields → actions

| Element | Spec |
|---------|------|
| Logo | App icon + "VietMatch" largeTitle, warmGradient |
| Tagline | "Kết nối trái tim Việt" subheadline, textSecondary |
| Email field | Rounded rectangle, `envelope` icon, placeholder "Email" |
| Password field | SecureField, `lock` icon, placeholder "Mật khẩu" |
| Login button | GradientButton "Đăng nhập" |
| Forgot password | Text button, textSecondary, `footnote` |
| Divider | "hoặc" với line dividers |
| Google Sign-In | White button, Google icon, border `textSecondary.opacity(0.3)` |
| Apple Sign-In | Black button, Apple icon |
| Register link | "Chưa có tài khoản? Đăng ký" |

**States:**
- Loading: tất cả inputs disabled, buttons show spinner
- Error: Alert với tiêu đề "Lỗi đăng nhập", message tiếng Việt

#### RegisterView
- Tương tự LoginView + thêm `displayName` field và `confirmPassword` field
- Password mismatch: inline error text màu `error` bên dưới confirmPassword field

#### ForgotPasswordView
- Email input + "Gửi link đặt lại" GradientButton
- Success state: confirmation message + back to login link

---

### 4.2 Onboarding Flow

**Design pattern:** Step-based wizard với progress indicator (4 dots).

| Bước | Screen | Elements |
|------|--------|---------|
| 1 | ProfileSetupView | Name TextField, Age Slider (18–100), Bio TextEditor (max 500 chars counter) |
| 2 | GenderSelectionView | Pill buttons: Nam / Nữ / Khác (cho gender và interestedIn) |
| 3 | PhotoUploadView | 3×2 grid, 6 slots, add/remove photo, dashed placeholder |
| 4 | InterestsView | Tag cloud, scrollable, highlight selected tags với `primary` color |

**Photo Upload (Bước 3):**
- 6 slots trong grid 3 cột × 2 hàng
- Slot trống: dashed border + `plus.circle.fill` icon
- Slot có ảnh: full bleed image + `xmark.circle.fill` delete button (top-right)
- Minimum 1 ảnh để tiếp tục

**Navigation:**
- Back button (step < 4): quay bước trước
- "Tiếp theo" / "Hoàn tất" (step 4): GradientButton
- Progress dots ở top

---

### 4.3 Discover (DiscoverView)

**Layout:** Card stack (80% screen height) + action buttons row

**Card (CardView):**

| Zone | Content |
|------|---------|
| Full bleed image | Carousel — swipe left/right giữa ảnh |
| Photo indicators | Dots ở top (active = white, inactive = white.opacity(0.5)) |
| Bottom gradient overlay | `cardGradient` — đảm bảo text readability |
| Name + age | `cardName` + `cardAge`, white, bottom-left |
| Job title + distance | `cardInfo`, white.opacity(0.9) |
| Bio preview | Truncated 2 lines, footnote, white.opacity(0.8) |

**Action buttons (dưới card stack):**

| Button | Icon | Size | Color |
|--------|------|------|-------|
| Dislike | `xmark` | 56pt circle | error (#F44336) |
| Super Like | `star.fill` | 44pt circle | info (#2196F3) |
| Like | `heart.fill` | 56pt circle | success (#4CAF50) |

**Swipe indicators:**
- Drag phải > 30pt: "LIKE" badge (success, opacity = drag amount)
- Drag trái > 30pt: "NOPE" badge (error, opacity = drag amount)

**Empty state:** EmptyStateView với "Hết hồ sơ rồi" + "Thử lại" CTA.

**Match Alert (Sheet/Overlay):**
- Full screen overlay: warmGradient background
- "It's a Match! 🎉" title
- Hai avatars side by side với heart animation
- "Nhắn tin ngay" button → navigate to ChatView
- "Để sau" button → dismiss

---

### 4.4 ProfileDetailView

**Layout:** ScrollView với full-bleed photo carousel trên cùng

| Section | Content |
|---------|---------|
| Photo carousel | Paged scroll, full width, 60% screen height |
| Page indicators | Dots ở dưới carousel |
| Name + age + distance | largeTitle + body |
| Interests tags | Horizontal scroll tag cloud |
| Bio | Full text, body style |
| Job / School / Company | Icon + text rows |
| Action buttons | Like / Dislike / Super Like (sticky bottom bar) |

**Navigation:** Accessible từ DiscoverView (tap card) và từ MatchesView (tap match avatar).

---

### 4.5 Matches (MatchesView)

**Layout:** Hai sections trong ScrollView

**Section 1 — Matches Mới:**
- Horizontal ScrollView
- CompactMatchCell: Avatar (70×70) + tên (1 line, caption) + "NEW" badge nếu chưa nhắn tin

**Section 2 — Tất Cả Matches:**
- Vertical list
- FullMatchCell: Avatar (60×60) + tên (headline) + "X thời gian trước" (footnote, textSecondary) + NEW badge

**Empty state:** EmptyStateView "Chưa có match nào" + icon `heart.slash`.

---

### 4.6 Chat Flow

#### ConversationsView
**Layout:** List của conversations

| Element | Spec |
|---------|------|
| Avatar | ProfileImageView 56×56 |
| Name | headline |
| Last message preview | Truncated 1 line, footnote, textSecondary |
| Time | footnote, textSecondary, right-aligned |
| Unread badge | Red circle với count, `caption2` white text |

**Empty state:** EmptyStateView "Chưa có cuộc trò chuyện" + "Khám phá ngay" CTA.

#### ChatView
**Layout:** Messages list + input bar

**Message bubble:**
- Current user: gradient background (`primaryGradient`), white text, right-aligned, no tail
- Other user: white background, `textPrimary` text, left-aligned, chat bubble tail shape
- Timestamp: `caption2`, `textSecondary`, below bubble

**Input bar (sticky bottom):**
- TextField "Nhập tin nhắn..." với icon attach (image picker)
- Send button: `arrow.up.circle.fill`, `primary` color, disabled khi text rỗng
- Tự động scroll xuống khi nhận tin nhắn mới

---

### 4.7 Profile & Edit Profile

#### ProfileView
- Large avatar (100×100) centered
- Name + age headline
- Edit button → EditProfileView
- Stats row: số matches, số photos
- Bio section
- Interests tags

#### EditProfileView
- Photo grid (3×2, same as onboarding step 3)
- Form fields: Name, Bio, Job Title, Company, School
- "Lưu thay đổi" GradientButton sticky bottom
- Confirm dialog khi dismiss với unsaved changes

---

### 4.8 Settings (SettingsView)

**Layout:** Grouped List

| Section | Items |
|---------|-------|
| Khám phá | Khoảng cách (Slider 1–160 km), Độ tuổi (RangeSlider 18–100) |
| Thông báo | Toggle: Bật/tắt push notification |
| Tài khoản | Đăng xuất (orange text), Xóa tài khoản (red text) |

**Logout:** Confirmation alert "Bạn có chắc muốn đăng xuất?"
**Delete account:** Confirmation alert với cảnh báo "Hành động này không thể hoàn tác."

---

## 5. Interaction Patterns

### 5.1 Loading States
- Mọi async action phải có visual feedback
- Buttons: disable + hiện spinner (không có text)
- Screens: LoadingView overlay hoặc skeleton placeholders
- Lists: không có flash empty state trong khi loading

### 5.2 Error Handling UX
- Network errors: Alert tiếng Việt với "Thử lại" CTA
- Form validation errors: Inline text màu `error` bên dưới field
- Firebase auth errors: Alert với message localized tiếng Việt

### 5.3 Confirmation Dialogs
Các hành động destructive (đăng xuất, xóa tài khoản, unmatch) đều cần confirmation alert:
- Title: rõ ràng về hành động
- Buttons: "Huỷ" (cancel, default) và action button (destructive style cho delete)

### 5.4 Gestures & Accessibility
- Swipe cards: DragGesture với threshold 100pt
- Photo carousel: ScrollView paged
- Dismiss keyboard: `hideKeyboard()` extension khi tap outside input
- Minimum tap target: 44×44pt cho tất cả interactive elements

---

## 6. Navigation UX Patterns

### Tab Bar (4 tabs)
| Tab | Icon | Label |
|-----|------|-------|
| Discover | `flame.fill` | Khám phá |
| Matches | `heart.fill` | Matches |
| Chat | `message.fill` | Trò chuyện |
| Profile | `person.fill` | Hồ sơ |

- Badge: unread count trên Chat tab
- Badge: new matches count trên Matches tab

### Deep Linking từ Push Notification
| Notification Type | Navigate to |
|------------------|------------|
| New Match | MatchesView (tab 2) |
| New Message | ChatView(matchId) |
| Super Like | DiscoverView (tab 1) |

---

## 7. UX Design Requirements (UX-DRs)

**UX-DR1:** Match alert overlay phải có button "Nhắn tin ngay" điều hướng trực tiếp tới `ChatView(matchId)` — hiện tại button chỉ dismiss.

**UX-DR2:** Swipe cards phải hiển thị khoảng cách (km) tính từ vị trí hiện tại của user — cần `distance` field được compute và truyền vào CardView.

**UX-DR3:** CardView phải có tap gesture để navigate tới `ProfileDetailView(profileId)` — hiện không có.

**UX-DR4:** ConversationsView phải tự động navigate tới ChatView khi user tap vào match từ MatchesView — cần coordination giữa MatchesTab và ChatCoordinator.

**UX-DR5:** EditProfileView phải hiển thị confirmation dialog "Có thay đổi chưa lưu. Bạn có muốn thoát?" khi dismiss với unsaved changes.

**UX-DR6:** Tất cả error messages từ Firebase Auth phải hiển thị tiếng Việt. Cần `AuthError.networkError` case riêng thay vì dùng `localizedDescription`.

**UX-DR7:** Photo delete flow phải handle URL mismatch (trailing slash, encoding differences) — URL normalize trước khi so sánh để tránh silent no-op.

**UX-DR8:** LoginView Google Sign-In button phải disable khi `isLoading == true` để ngăn double-tap tạo multiple GIDSignIn sessions.

**UX-DR9:** DiscoverView phải xử lý empty state sau khi hết cards với EmptyStateView "Hết hồ sơ rồi!" + CTA "Làm mới danh sách".

**UX-DR10:** Onboarding PhotoUpload step phải hiển thị counter "X/6 ảnh" và prevent continue nếu chưa có ảnh nào.
