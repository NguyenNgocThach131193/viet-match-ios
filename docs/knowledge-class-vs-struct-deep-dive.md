# Class vs Struct trong Swift — Deep Dive

> Ngày tạo: 2026-03-28 | Áp dụng: VietMatch iOS

---

## 1. Sự Khác Biệt Cốt Lõi: Value Type vs Reference Type

Đây là điểm khác biệt **quan trọng nhất**, mọi thứ còn lại đều bắt nguồn từ đây.

```swift
// STRUCT — Value Type (copy khi gán/truyền)
struct ProfileStruct {
    var name: String
}

var profileA = ProfileStruct(name: "Nam")
var profileB = profileA       // ← Copy hoàn toàn
profileB.name = "Linh"

print(profileA.name)  // "Nam"  ← Không bị ảnh hưởng
print(profileB.name)  // "Linh"


// CLASS — Reference Type (chia sẻ cùng vùng nhớ)
class ProfileClass {
    var name: String
    init(name: String) { self.name = name }
}

var profileC = ProfileClass(name: "Nam")
var profileD = profileC       // ← Cùng trỏ vào 1 object
profileD.name = "Linh"

print(profileC.name)  // "Linh" ← BỊ thay đổi theo!
print(profileD.name)  // "Linh"
```

**Hệ quả trong VietMatch:** Entities (`Profile`, `Match`, `Message`) là `struct` → mỗi ViewModel giữ bản copy riêng, không lo bị ViewModel khác vô tình sửa dữ liệu.

---

## 2. Bảng So Sánh Toàn Diện

| Đặc điểm | `struct` | `class` |
|-----------|----------|---------|
| **Type** | Value type | Reference type |
| **Lưu trữ** | Stack | Heap |
| **Khi gán/truyền** | Copy (deep copy) | Copy reference (shallow) |
| **Kế thừa** | ❌ Không hỗ trợ | ✅ Single inheritance |
| **Deinitializer** | ❌ Không có | ✅ `deinit` |
| **Mutability** | Cần `mutating` func | Tự do mutate |
| **ARC** | ❌ Không cần | ✅ Quản lý bởi ARC |
| **Identity (`===`)** | ❌ | ✅ |
| **Memberwise initializer** | ✅ Tự động | ❌ Phải tự viết |
| **Thread safety** | ✅ Safer by default | ⚠️ Cần đồng bộ hóa |
| **Protocol conformance** | ✅ | ✅ |

---

## 3. Memory Model Chi Tiết

```
STACK (struct)                    HEAP (class)
┌─────────────────┐               ┌─────────────────────┐
│   profileA      │               │   0x1A2B (Object)   │
│   name: "Nam"   │               │   name: "Nam"       │
│   age: 25       │               │   age: 25           │
├─────────────────┤               │   retain count: 2   │
│   profileB      │               └─────────────────────┘
│   name: "Linh"  │                        ▲        ▲
│   age: 25       │               profileC─┘        └─profileD
└─────────────────┘               (cùng địa chỉ 0x1A2B)
```

- **Stack** — allocation/deallocation cực nhanh (chỉ cần dịch chuyển stack pointer)
- **Heap** — chậm hơn, phải tìm vùng nhớ trống, cần ARC để quản lý

---

## 4. Mutating — Quy Tắc Của Struct

Struct là **immutable by default**. Muốn thay đổi property bên trong method phải dùng `mutating`:

```swift
struct OnboardingState {
    var currentStep: Int = 0
    var name: String = ""
    var photos: [UIImage] = []

    // Phải có `mutating` vì thay đổi self
    mutating func nextStep() {
        currentStep += 1
    }

    mutating func addPhoto(_ image: UIImage) {
        photos.append(image)
    }
}

// Nếu biến là `let` → KHÔNG thể gọi mutating func
let state = OnboardingState()
state.nextStep()  // ❌ Compile error: cannot mutate immutable value

var state2 = OnboardingState()
state2.nextStep() // ✅ OK
```

**Class không cần `mutating`** vì method biết địa chỉ object, thay đổi thẳng trên heap.

---

## 5. Kế Thừa — Chỉ Class Có

```swift
// Class: kế thừa được
class BaseCoordinator {
    var navigationController: UINavigationController

    func start() { /* base implementation */ }
}

class AuthCoordinator: BaseCoordinator {
    override func start() {
        // custom implementation
    }
}

// Struct: KHÔNG kế thừa, nhưng dùng Protocol thay thế
protocol Coordinator {
    func start()
}

struct AuthFlow: Coordinator {
    func start() { /* ... */ }
}
```

**Trong VietMatch:** Coordinators dùng `class` vì cần kế thừa và giữ state dài hạn (`navigationController`).

---

## 6. Identity — Chỉ Class Có `===`

```swift
class UserSession {
    var userId: String
    init(userId: String) { self.userId = userId }
}

let session1 = UserSession(userId: "abc123")
let session2 = session1
let session3 = UserSession(userId: "abc123")

session1 === session2  // ✅ true  — cùng object
session1 === session3  // ❌ false — khác object, dù data giống nhau
session1 == session3   // ❌ Error nếu không implement Equatable

// Struct dùng == (Equatable), không có ===
struct Profile: Equatable {
    var id: String
    var name: String
}
// Swift tự synthesize == cho struct nếu tất cả properties là Equatable
```

---

## 7. ARC & Retain Cycle — Chỉ Class Gặp

```swift
// ⚠️ Retain cycle — memory leak
class DiscoverViewModel {
    var onMatchFound: (() -> Void)?  // closure giữ reference

    func setup() {
        // WRONG: self bị giữ bởi closure, closure bị giữ bởi self
        onMatchFound = {
            self.showMatchAlert()  // ← strong capture → leak!
        }
    }

    // CORRECT: dùng [weak self]
    func setupCorrect() {
        onMatchFound = { [weak self] in
            self?.showMatchAlert()
        }
    }
}

// Struct KHÔNG có retain cycle vì không có reference counting
// Closures capture value type bằng copy, không bằng reference
```

---

## 8. Thread Safety

```swift
// STRUCT — Thread safe hơn
struct MessageState {
    var messages: [Message]
    var isLoading: Bool
}
// Mỗi thread có bản copy riêng → không data race

// CLASS — Cần đồng bộ hóa
@MainActor  // ← VietMatch dùng cách này cho ViewModels
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    // @MainActor đảm bảo tất cả access trên main thread
}

// Hoặc dùng Actor (Swift 5.5+)
actor MessageCache {
    private var cache: [String: [Message]] = [:]

    func store(messages: [Message], for matchId: String) {
        cache[matchId] = messages
    }
}
```

---

## 9. Copy-on-Write (CoW) — Tối Ưu Ẩn Của Struct

Swift không copy struct ngay lập tức khi gán — chỉ copy **khi có sự thay đổi**:

```swift
var photos1 = [UIImage]()  // Array là struct
var photos2 = photos1      // Chưa copy thật, chỉ share buffer

// Lúc này photos1 và photos2 cùng trỏ vào 1 buffer (tiết kiệm memory)

photos2.append(someImage)  // ← LÚC NÀY mới copy thật sự

// photos1: [] (không thay đổi)
// photos2: [someImage] (bản copy riêng)
```

Đây là lý do Array, Dictionary, String (đều là struct) hoạt động hiệu quả dù là value type.

---

## 10. Áp Dụng Trong VietMatch

### Entities → `struct` ✅

```swift
// Domain/Entities/Profile.swift
struct Profile {           // ← Struct: immutable data, thread-safe, Equatable
    let id: String
    var name: String
    var age: Int
    var photos: [String]
    // ...
}

// Mỗi lần DiscoverViewModel và ProfileViewModel cần Profile,
// chúng nhận bản copy riêng → không conflict
```

### ViewModels → `class` ✅

```swift
// Cần @ObservableObject / @Observable → phải là class
// Cần tồn tại lâu dài (không bị copy khi SwiftUI re-render)
@MainActor
class DiscoverViewModel: ObservableObject {
    @Published var profiles: [Profile] = []
    @Published var isLoading = false
}
```

### Services & Repositories → `class` ✅

```swift
// Cần singleton-like behavior, giữ connection/state
class FirestoreService {
    private let db = Firestore.firestore()  // Expensive resource, không nên copy
}
```

### Coordinators → `class` ✅

```swift
// Cần kế thừa, giữ navigationController reference lâu dài
class AppCoordinator: ObservableObject {
    var path = NavigationPath()
}
```

### DTOs → `struct` ✅

```swift
// Data/DTOs/ProfileDTO.swift
struct ProfileDTO: Codable {  // ← Chỉ cần parse JSON, không cần identity
    let name: String
    let age: Int
    // ...

    func toDomain() -> Profile { /* map to entity */ }
}
```

---

## 11. Quy Tắc Chọn

```
Dùng STRUCT khi:                    Dùng CLASS khi:
✅ Data model / Entity              ✅ Cần kế thừa
✅ DTO, Value Object                ✅ ViewModel (@ObservableObject)
✅ Immutable data                   ✅ Service, Repository (singleton)
✅ Cần Equatable/Hashable dễ dàng   ✅ Coordinator (giữ nav state)
✅ Thread safety là ưu tiên         ✅ Cần deinit / lifecycle
✅ Không cần share identity         ✅ Cần share reference giữa nhiều nơi
```

**Nguyên tắc của Apple:** *"Use structures by default"* — chỉ dùng class khi thực sự cần reference semantics.
