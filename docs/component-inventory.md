# Component Inventory

> Danh sách components, design tokens và screens trong VietMatch

---

## 1. Reusable Components

### SwipeCardStack

| Thuộc tính | Type | Mô tả |
|-----------|------|-------|
| data | [T] | Generic array data source |
| onSwipeLeft | (T) -> Void | Callback khi swipe trái (dislike) |
| onSwipeRight | (T) -> Void | Callback khi swipe phải (like) |
| content | (T) -> Content | View builder cho mỗi card |

**Đặc điểm:** 3D scale effect, drag gesture detection, stack animation.

### GradientButton

| Thuộc tính | Type | Mô tả |
|-----------|------|-------|
| title | String | Text hiển thị |
| icon | String? | SF Symbol name (optional) |
| isLoading | Bool | Hiển thị spinner thay text |
| action | () -> Void | Tap callback |

**Đặc điểm:** Primary gradient (#FF6B6B → #FE3C72 → #E91E63), full width, height 52pt, corner radius 26pt.

### ProfileImageView

| Thuộc tính | Type | Mô tả |
|-----------|------|-------|
| url | String? | Image URL |
| size | CGFloat | Kích thước avatar |
| showBorder | Bool | Hiển thị border (default: true) |

**Đặc điểm:** Circle clip, Kingfisher async loading, placeholder icon.

### LoadingView

| Thuộc tính | Type | Mô tả |
|-----------|------|-------|
| message | String | Text hiển thị (default: "Đang tải...") |

**Đặc điểm:** ProgressView spinner + message text, centered layout.

### EmptyStateView

| Thuộc tính | Type | Mô tả |
|-----------|------|-------|
| icon | String | SF Symbol name |
| title | String | Tiêu đề |
| message | String | Mô tả chi tiết |
| actionTitle | String? | Text của nút action (optional) |
| action | (() -> Void)? | Tap callback (optional) |

**Đặc điểm:** Icon với gradient circle background, optional CTA button.

---

## 2. Screen-Specific Components

### CardView (Discover)

| Thuộc tính | Mô tả |
|-----------|-------|
| Photo carousel | Swipe left/right giữa ảnh |
| Photo indicators | Dots ở đầu card |
| Gradient overlay | Bottom gradient cho readability |
| Info overlay | Name, age, job, location, bio |
| Swipe indicators | "LIKE"/"NOPE" text khi drag |
| Drag gesture | Detect swipe direction |

### MessageBubbleView (Chat)

| Thuộc tính | Mô tả |
|-----------|-------|
| Custom ChatBubbleShape | Bubble shape với tail |
| Gradient background | Cho tin nhắn của current user |
| White background | Cho tin nhắn người khác |
| Formatted time | Hiển thị giờ gửi |

### MatchCellView (Matches)

| Style | Layout |
|-------|--------|
| **Compact** | Avatar 70x70 + name (1 line) - horizontal scroll |
| **Full** | Avatar 60x60 + name + "time ago" + new indicator badge |

### PhotoUploadView (Onboarding)

| Thuộc tính | Mô tả |
|-----------|-------|
| 3x3 grid | 6 photo slots |
| PhotoPicker | Drag to add photos |
| Remove button | Xóa ảnh đã chọn |
| Placeholder | Dashed border + plus icon |

### ProfileSetupView (Onboarding)

| Thuộc tính | Mô tả |
|-----------|-------|
| Name input | TextField |
| Age slider | 18-100 range |
| Bio textarea | TextEditor |

---

## 3. View Extensions (Button Styles)

| Extension | Mô tả |
|-----------|-------|
| `.cardShadow()` | Shadow effect cho cards |
| `.primaryButtonStyle()` | Gradient, full width, 52pt height |
| `.secondaryButtonStyle()` | White background, border |
| `.hideKeyboard()` | Dismiss keyboard on tap |

---

## 4. Design System Tokens

### VietMatchColors

| Category | Token | Giá trị |
|----------|-------|--------|
| **Primary** | primary | #FE3C72 (Hot Pink) |
| | primaryLight | #FF6B6B |
| | primaryDark | #E91E63 |
| **Secondary** | secondary | #FF8A65 |
| | accent | #FFD54F |
| **Background** | background | #FAFAFA |
| | cardBackground | .white |
| | darkBackground | #1A1A2E |
| **Text** | textPrimary | #21262E |
| | textSecondary | #6C757D |
| | textLight | .white |
| **Status** | success | #4CAF50 (Like) |
| | warning | #FF9800 |
| | error | #F44336 (Dislike) |
| | info | #2196F3 (SuperLike) |
| **Gradients** | primaryGradient | Light → Primary → Dark |
| | cardGradient | Clear → Black (0.7) |
| | warmGradient | #FF6B6B → #FE3C72 → #FF8A65 |

### VietMatchTypography

| Style | Size | Weight | Design |
|-------|------|--------|--------|
| largeTitle | 34 | Bold | Rounded |
| title1 | 28 | Bold | Rounded |
| title2 | 22 | Semibold | Rounded |
| title3 | 20 | Semibold | Rounded |
| headline | 17 | Semibold | Default |
| body | 17 | Regular | Default |
| callout | 16 | Regular | Default |
| subheadline | 15 | Regular | Default |
| footnote | 13 | Regular | Default |
| caption | 12 | Regular | Default |
| caption2 | 11 | Regular | Default |
| cardName | 28 | Bold | Rounded |
| cardAge | 24 | Light | Rounded |
| cardInfo | 16 | Medium | Default |

### VietMatchSpacing

| Token | Giá trị | Sử dụng |
|-------|--------|---------|
| xxs | 2 | Micro spacing |
| xs | 4 | Tight spacing |
| sm | 8 | Small gaps |
| md | 12 | Medium gaps |
| lg | 16 | Standard padding |
| xl | 24 | Section spacing |
| xxl | 32 | Large spacing |
| xxxl | 48 | Extra large spacing |
| cardPadding | 16 | Card internal padding |
| cardCornerRadius | 16 | Card corners |
| buttonHeight | 52 | Standard button height |
| buttonCornerRadius | 26 | Button corners (pill) |
| avatarSmall | 40 | Small avatar |
| avatarMedium | 60 | Medium avatar |
| avatarLarge | 100 | Large avatar |

---

## 5. Screen Inventory

| Module | Screens | ViewModels |
|--------|---------|-----------|
| **Auth** | LoginView, RegisterView | LoginViewModel, RegisterViewModel |
| **Onboarding** | OnboardingView, ProfileSetupView, PhotoUploadView | OnboardingViewModel |
| **Discover** | DiscoverView, CardView | DiscoverViewModel |
| **Matches** | MatchesView, MatchCellView | MatchesViewModel |
| **Chat** | ConversationsView, ChatView, MessageBubbleView | ConversationsViewModel, ChatViewModel |
| **Profile** | ProfileView, EditProfileView | ProfileViewModel |
| **Settings** | SettingsView | SettingsViewModel |

**Tổng cộng:** 15 screens, 9 view models, 5 reusable components
