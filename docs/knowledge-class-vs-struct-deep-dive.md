# Class vs Struct Deep Dive

> Value type vs Reference type, memory model, CoW, performance, Sendable và áp dụng trong VietMatch

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

## 4. Khi Nào Struct Lưu Trên Heap? (Hiểu Lầm Phổ Biến)

Nhiều người nghĩ struct **luôn** nằm trên Stack. Thực tế Swift compiler quyết định dựa trên ngữ cảnh:

```
Struct nằm trên STACK khi:          Struct bị đẩy lên HEAP khi:
✅ Biến local trong function         ❌ Bị capture bởi escaping closure
✅ Parameter truyền vào function     ❌ Lưu trong protocol existential
✅ Kích thước nhỏ, lifetime rõ       ❌ Lưu trong Any / AnyObject
                                     ❌ Struct quá lớn (compiler tự chuyển)
```

```swift
// Ví dụ: Struct bị đẩy lên Heap

// 1. Escaping closure capture
func fetchProfiles(completion: @escaping (ProfileState) -> Void) {
    var state = ProfileState()  // ← struct này bị capture
    DispatchQueue.global().async {
        state.isLoading = true  // ← compiler phải đưa lên heap
        completion(state)       //   vì lifetime vượt quá function scope
    }
}

// 2. Protocol existential (existential container)
protocol Displayable {
    var title: String { get }
}

struct LargeProfile: Displayable {
    var title: String
    var photos: [String]  // 8+ bytes tổng → vượt existential buffer
}

let item: Displayable = LargeProfile(title: "Nam", photos: [])
// ↑ LargeProfile > 3 words → heap allocation cho existential container

// 3. Tối ưu: dùng `some` hoặc `any` thay vì bare protocol
func display(_ item: some Displayable) {  // ← KHÔNG heap allocation
    print(item.title)                     //   compiler biết exact type
}
```

**Bài học cho VietMatch:** Khi truyền Entity struct qua `@escaping` closure (ví dụ completion handler từ Repository), struct vẫn có thể bị heap-allocated. Nhưng điều này **không ảnh hưởng đến value semantics** — bạn vẫn được copy safety.

---

## 5. Struct Chứa Class Property — Bẫy Mixed Semantics

Khi struct chứa property kiểu class, value semantics **bị phá vỡ một phần**:

```swift
// ⚠️ BẪY: Struct chứa reference type
class ImageCache {
    var images: [String: UIImage] = [:]
}

struct UserProfile {
    var name: String
    var cache: ImageCache  // ← Reference type bên trong value type!
}

var profileA = UserProfile(name: "Nam", cache: ImageCache())
profileA.cache.images["avatar"] = someImage

var profileB = profileA           // ← Copy struct, NHƯNG...
profileB.cache.images["avatar"] = otherImage

// profileA.cache === profileB.cache → true! 😱
// Cả hai share cùng ImageCache object
// profileA.cache.images["avatar"] cũng bị thay đổi!
```

```
profileA (Stack)              profileB (Stack)
┌──────────────────┐          ┌──────────────────┐
│ name: "Nam" ✅   │          │ name: "Nam" ✅   │
│ cache: ──────────┼────┐     │ cache: ──────────┼────┐
└──────────────────┘    │     └──────────────────┘    │
                        ▼                              │
                   ┌─────────────────┐                 │
                   │ ImageCache (Heap)│ ◄───────────────┘
                   │ images: [...]   │   ← SHARED! ⚠️
                   └─────────────────┘
```

**Giải pháp:** Đảm bảo struct chỉ chứa value types, hoặc implement custom copy:

```swift
struct UserProfile {
    var name: String
    private var _cache: ImageCache

    // Custom getter tạo deep copy khi cần
    var cache: ImageCache {
        mutating get {
            if !isKnownUniquelyReferenced(&_cache) {
                _cache = _cache.copy()  // Deep copy
            }
            return _cache
        }
    }
}
```

**Trong VietMatch:** Entities như `Profile`, `Match` chỉ chứa primitive types và collections (đều là value type) → an toàn. Nhưng nếu tương lai thêm class property, cần nhớ bẫy này.

---

## 6. Mutating — Quy Tắc Của Struct

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

## 7. Kế Thừa — Chỉ Class Có

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

## 8. Identity — Chỉ Class Có `===`

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

## 9. ARC & Retain Cycle — Chỉ Class Gặp

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

## 10. Thread Safety

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

## 11. Copy-on-Write (CoW) — Tối Ưu Ẩn Của Struct

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

## 12. Performance — So Sánh Thực Tế

```
Thao tác             struct              class
─────────────────────────────────────────────────────
Allocation           ~1 ns (stack)       ~25-50 ns (heap + ARC)
Deallocation         ~0 ns (auto)        ~25 ns (ARC decrement)
Copy (nhỏ ≤3 words)  ~1 ns (memcpy)     ~5 ns (retain count++)
Copy (lớn)           Deferred (CoW)      ~5 ns (chỉ copy ref)
Method dispatch      Static (inline)     Dynamic (vtable lookup)
```

```swift
// Ví dụ: 1 triệu lần tạo + hủy
// Struct: ~15ms (stack allocation, no ARC)
// Class:  ~120ms (heap allocation + ARC overhead)

// Nhưng thực tế quan trọng hơn micro-benchmark:
// - Profile list 100 items → chênh lệch không đáng kể
// - Chọn đúng type (struct/class) vì SEMANTICS, không vì performance
// - Performance chỉ là bonus khi semantics đã đúng
```

**Khi nào performance thực sự quan trọng:**
- Struct lớn (>4 properties phức tạp) + copy thường xuyên + KHÔNG trigger CoW → cân nhắc
- Vòng lặp tight loop xử lý hàng nghìn items → struct nhanh hơn rõ rệt
- Phần lớn app code (UI, networking) → sự khác biệt **không đáng kể**

---

## 13. Sendable & Swift Concurrency

Swift 6 yêu cầu data truyền giữa các concurrency domain phải conform `Sendable`:

```swift
// STRUCT — Tự động Sendable nếu mọi property đều Sendable ✅
struct Profile: Sendable {  // Compiler tự verify
    let id: String          // String: Sendable ✅
    var name: String        // String: Sendable ✅
    var age: Int            // Int: Sendable ✅
}

// CLASS — Phải đáp ứng điều kiện nghiêm ngặt hơn ⚠️
// Cách 1: final class + immutable
final class AppConfig: Sendable {
    let apiBaseURL: String    // ✅ let only
    let appVersion: String    // ✅ let only
    // var mutableProp: Int   // ❌ Compile error nếu có var
}

// Cách 2: Actor (thay thế class khi cần mutability + thread safety)
actor MatchService {
    private var pendingMatches: [Match] = []

    func addMatch(_ match: Match) {
        pendingMatches.append(match)  // Thread-safe by design
    }
}

// Cách 3: @MainActor class (VietMatch ViewModels)
@MainActor
final class DiscoverViewModel: ObservableObject {
    @Published var profiles: [Profile] = []  // OK — chỉ access trên main thread
}
```

```
Sendable conformance:
┌──────────────────────────────────────────────────┐
│ struct (all Sendable props) → ✅ Tự động         │
│ enum (all Sendable cases)  → ✅ Tự động          │
│ final class (let only)     → ✅ Nhưng hạn chế    │
│ class (var props)          → ❌ Không thể         │
│ actor                      → ✅ By design         │
│ @MainActor class           → ✅ Isolated          │
└──────────────────────────────────────────────────┘
```

**Trong VietMatch:** Entity structs tự động `Sendable` — truyền giữa background thread (Firebase) và main thread (UI) an toàn. ViewModels dùng `@MainActor` để isolate.

---

## 14. Áp Dụng Trong VietMatch

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

## 15. Quy Tắc Chọn

```
Dùng STRUCT khi:                    Dùng CLASS khi:
✅ Data model / Entity              ✅ Cần kế thừa
✅ DTO, Value Object                ✅ ViewModel (@ObservableObject)
✅ Immutable data                   ✅ Service, Repository (singleton)
✅ Cần Equatable/Hashable dễ dàng   ✅ Coordinator (giữ nav state)
✅ Thread safety là ưu tiên         ✅ Cần deinit / lifecycle
✅ Không cần share identity         ✅ Cần share reference giữa nhiều nơi
```

### Flowchart Quyết Định

```mermaid
flowchart TD
    A[Tạo type mới] --> B{Cần kế thừa?}
    B -- Có --> C[CLASS]
    B -- Không --> D{Cần ObservableObject\nhoặc lifecycle deinit?}
    D -- Có --> C
    D -- Không --> E{Cần share identity\ngiữa nhiều nơi?}
    E -- Có --> C
    E -- Không --> F{Cần Objective-C\ninterop?}
    F -- Có --> C
    F -- Không --> G[STRUCT ✅ Default]

    C --> H{Cần thread safety\nvới mutable state?}
    H -- Có --> I{State isolated\ntrên 1 thread?}
    I -- Có --> J[@MainActor class]
    I -- Không --> K[Actor]
    H -- Không --> L[Regular class]

    style G fill:#2d6a2d,color:#fff
    style C fill:#8b4513,color:#fff
```

### Tổng Kết Nhanh Theo Layer (VietMatch)

| Layer | Type | Lý do |
|-------|------|-------|
| Entity (`Profile`, `Match`) | `struct` | Value semantics, Sendable, thread-safe |
| DTO (`ProfileDTO`) | `struct` | Codable, chỉ cần parse data |
| ViewModel | `class` (`@MainActor`) | ObservableObject, lifecycle, UI binding |
| Service/Repository | `class` | Singleton, giữ connection/state |
| Coordinator | `class` | Navigation state, kế thừa |
| State (local) | `struct` | Immutable snapshot, CoW |
| Actor (cache, queue) | `actor` | Thread-safe mutable shared state |

**Nguyên tắc của Apple:** *"Use structures by default"* — chỉ dùng class khi thực sự cần reference semantics.
