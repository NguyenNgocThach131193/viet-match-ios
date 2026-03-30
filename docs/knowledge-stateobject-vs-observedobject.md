# @StateObject vs @ObservedObject

> Tài liệu tham khảo cho SwiftUI state management trong VietMatch

---

## 1. Tổng Quan

Cả hai đều dùng để theo dõi `ObservableObject` trong SwiftUI. Khi object thay đổi (`@Published` properties), View tự động re-render. Sự khác biệt nằm ở **ai sở hữu object** và **điều gì xảy ra khi View bị tạo lại**.

---

## 2. Bảng So Sánh

| Tiêu chí | `@StateObject` | `@ObservedObject` |
|----------|---------------|-------------------|
| **Vai trò** | Tạo ra và **sở hữu** object | **Mượn** và theo dõi object từ bên ngoài |
| **Lifecycle** | Object tồn tại suốt lifecycle của View | Object phụ thuộc vào nơi tạo ra nó |
| **Khởi tạo** | SwiftUI chỉ tạo object **1 lần duy nhất** | Tạo lại mỗi khi View bị re-init (nếu tạo inline) |
| **Khi View re-render** | Giữ nguyên object cũ | Giữ nguyên object cũ |
| **Khi View re-create** | **Giữ nguyên** object cũ | **Mất state** nếu không có owner giữ reference |
| **Ai nên dùng** | View **tạo ra** object | View **nhận** object từ parent |
| **Memory management** | SwiftUI quản lý lifetime | Caller phải đảm bảo object còn sống |
| **iOS minimum** | iOS 14+ | iOS 13+ |

---

## 3. Quy Tắc Chọn

```
Bạn có tạo object trong View này không?
│
├── CÓ  → @StateObject
│         Bạn là owner, bạn chịu trách nhiệm lifecycle.
│         SwiftUI sẽ giữ object tồn tại dù View bị re-init.
│
└── KHÔNG → @ObservedObject
            Ai đó truyền object cho bạn, bạn chỉ lắng nghe thay đổi.
            Đảm bảo nơi tạo object đã dùng @StateObject.
```

---

## 4. Ví Dụ Cơ Bản

### Đúng cách

```swift
class CounterViewModel: ObservableObject {
    @Published var count = 0
}

// ✅ ParentView TẠO RA viewModel → @StateObject
struct ParentView: View {
    @StateObject var viewModel = CounterViewModel()

    var body: some View {
        VStack {
            Text("Count: \(viewModel.count)")
            ChildView(viewModel: viewModel)
        }
    }
}

// ✅ ChildView NHẬN viewModel từ parent → @ObservedObject
struct ChildView: View {
    @ObservedObject var viewModel: CounterViewModel

    var body: some View {
        Button("Tăng") { viewModel.count += 1 }
    }
}
```

### Sai cách (bug tiềm ẩn)

```swift
// ❌ SAI: Tạo object mới trong View nhưng dùng @ObservedObject
struct BuggyView: View {
    @ObservedObject var viewModel = CounterViewModel()  // ← BUG!

    var body: some View {
        Text("Count: \(viewModel.count)")
        // Khi parent re-render → BuggyView.init() gọi lại
        // → CounterViewModel() mới được tạo → count reset về 0
    }
}

// ✅ ĐÚNG: Dùng @StateObject khi tạo object trong View
struct CorrectView: View {
    @StateObject var viewModel = CounterViewModel()

    var body: some View {
        Text("Count: \(viewModel.count)")
        // Khi parent re-render → CorrectView.init() gọi lại
        // → SwiftUI biết đã có object → dùng lại → count giữ nguyên
    }
}
```

---

## 5. Điều Gì Xảy Ra Khi SwiftUI Re-create View?

SwiftUI có thể re-create View trong nhiều tình huống: parent re-render, memory pressure, app vào background rồi quay lại, v.v.

### Với `@StateObject`

```
Lần 1: View.init() → SwiftUI tạo object, lưu vào internal storage
Lần 2: View.init() → SwiftUI thấy "đã có object" → dùng lại object cũ ✅

Kết quả: State được bảo toàn
```

### Với `@ObservedObject` (tạo inline)

```
Lần 1: View.init() → object A được tạo, View dùng object A
Lần 2: View.init() → object B được tạo, View dùng object B ❌

Kết quả: State bị mất (reset về giá trị ban đầu)
```

### Với `@ObservedObject` (truyền từ parent có @StateObject)

```
Lần 1: View.init(object: parentObject) → View dùng parentObject
Lần 2: View.init(object: parentObject) → View vẫn dùng parentObject ✅

Kết quả: State được bảo toàn (vì parent giữ @StateObject)
```

---

## 6. Analogy — Ví Von Dễ Hiểu

### Mua nhà vs Thuê nhà

- **`@StateObject`** = **Mua nhà**: Bạn sở hữu, nhà luôn ở đó dù hàng xóm chuyển đi chuyển lại. Nội thất (state) luôn được giữ nguyên.

- **`@ObservedObject`** = **Thuê nhà**: Bạn ở nhờ nhà người khác. Nếu chủ nhà (parent) vẫn giữ nhà (@StateObject) → bạn ổn. Nếu không ai sở hữu → nhà có thể bị dỡ bỏ bất cứ lúc nào.

### Cầm ô vs Để ô ở quán

- **`@StateObject`** = **Cầm ô theo**: Dù trời mưa hay nắng, ô luôn ở bên bạn.

- **`@ObservedObject`** = **Để ô ở quán cà phê**: Khi bạn quay lại, ô có thể vẫn ở đó (nếu chủ quán giữ hộ) hoặc đã bị ai lấy mất.

---

## 7. Áp Dụng Trong VietMatch

### Hiện tại

```swift
// VietMatchApp.swift — TẠO coordinator
@StateObject private var appCoordinator: AppCoordinator    // ✅ Đúng

// AuthCoordinatorView — NHẬN coordinator
@ObservedObject var coordinator: AuthCoordinator           // ⚠️ Syntax đúng

// NHƯNG: AuthCoordinator được tạo trong method, không ai giữ @StateObject
func authView() -> some View {
    let coordinator = AuthCoordinator(container: container) // ← Tạo mới mỗi lần gọi
    return AuthCoordinatorView(coordinator: coordinator)    // ← Không ai sở hữu
}
```

### Vấn đề

```
AppCoordinator.start() re-evaluate
  → authView() gọi lại
    → AuthCoordinator MỚI được tạo
      → AuthCoordinatorView nhận object MỚI
        → NavigationPath reset → mất navigation state
```

### Cách sửa — Option 1: `@StateObject` trong CoordinatorView

```swift
struct AuthCoordinatorView: View {
    @StateObject var coordinator: AuthCoordinator  // ← Thay @ObservedObject

    var body: some View {
        NavigationStack(path: $coordinator.path) { ... }
    }
}

// Caller:
func authView() -> some View {
    AuthCoordinatorView(coordinator: AuthCoordinator(container: container))
    // SwiftUI sẽ chỉ dùng init value lần đầu, sau đó giữ lại
}
```

### Cách sửa — Option 2: Parent giữ reference

```swift
final class AppCoordinator: ObservableObject {
    private lazy var authCoordinator = AuthCoordinator(container: container)

    func authView() -> some View {
        AuthCoordinatorView(coordinator: authCoordinator)  // ← Reference ổn định
    }
}

// AuthCoordinatorView vẫn dùng @ObservedObject — đúng vì parent giữ reference
```

### Cách sửa — Option 3: Swinject giữ singleton

```swift
// Trong PresentationAssembly:
container.register(AuthCoordinator.self) { r in
    AuthCoordinator(container: r as! Container)
}.inObjectScope(.container)  // ← Singleton trong container

// Caller:
func authView() -> some View {
    let coordinator = container.resolve(AuthCoordinator.self)!  // ← Luôn cùng instance
    return AuthCoordinatorView(coordinator: coordinator)
}
```

---

## 8. Các Views Bị Ảnh Hưởng Trong VietMatch

| View | Hiện tại | Rủi ro | Đề xuất |
|------|---------|--------|---------|
| `AppCoordinatorView` | `@StateObject` ở VietMatchApp | Không | Giữ nguyên ✅ |
| `AuthCoordinatorView` | `@ObservedObject`, không có owner | Mất nav state | Đổi sang `@StateObject` hoặc giữ reference |
| `DiscoverCoordinatorView` | `@ObservedObject`, không có owner | Mất nav state | Đổi sang `@StateObject` hoặc giữ reference |
| `ChatCoordinatorView` | `@ObservedObject`, không có owner | Mất nav state | Đổi sang `@StateObject` hoặc giữ reference |
| `ProfileCoordinatorView` | `@ObservedObject`, không có owner | Mất nav state | Đổi sang `@StateObject` hoặc giữ reference |

---

## 9. Tóm Tắt Nhanh

```
Tạo object trong View        → @StateObject
Nhận object từ bên ngoài     → @ObservedObject
Không chắc                   → @StateObject (an toàn hơn)
```

| Tình huống | Dùng gì |
|-----------|---------|
| ViewModel tạo trong Screen | `@StateObject` |
| ViewModel truyền từ Coordinator | `@ObservedObject` |
| Coordinator tạo trong CoordinatorView | `@StateObject` |
| Coordinator truyền từ parent Coordinator | `@ObservedObject` |
| Singleton/Shared object | `@ObservedObject` (có global owner) |
