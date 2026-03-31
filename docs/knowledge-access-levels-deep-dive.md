# Access Levels trong Swift — Deep Dive

> Ngày tạo: 2026-03-31 | Áp dụng: VietMatch iOS

---

## 1. Tổng Quan: Access Level Là Gì?

Access level kiểm soát **ai được phép nhìn thấy và sử dụng** một entity (class, struct, property, method, ...). Nó là hàng rào bảo vệ giúp bạn ẩn đi những thứ "nội bộ" và chỉ lộ ra đúng những gì cần thiết.

Swift có **5 mức access** từ rộng nhất đến hẹp nhất:

```
open  ──▶  public  ──▶  internal  ──▶  fileprivate  ──▶  private
(rộng nhất)                                              (hẹp nhất)
```

---

## 2. Mô Hình "Vòng Bảo Vệ"

```
┌─────────────────────────────────────────────────────────┐
│  Module A (VietMatch app)                               │
│                                                         │
│   ┌───────────────────────────────────────────────┐    │
│   │  File: ChatViewModel.swift                    │    │
│   │                                               │    │
│   │   ┌───────────────────────────────────┐      │    │
│   │   │  class ChatViewModel              │      │    │
│   │   │                                   │      │    │
│   │   │   ┌───────────────────────────┐  │      │    │
│   │   │   │  private var _cache       │  │      │    │ ← chỉ trong { }
│   │   │   └───────────────────────────┘  │      │    │
│   │   │                                   │      │    │
│   │   └───────────────────────────────────┘      │    │
│   │                                               │    │
│   │  fileprivate func helper() { ... }           │    │ ← cả file
│   └───────────────────────────────────────────────┘    │
│                                                         │
│  internal class DiscoverViewModel { ... }              │ ← cả module
└─────────────────────────────────────────────────────────┘

public / open: Module bên ngoài cũng thấy được
```

---

## 3. Chi Tiết Từng Mức

### 3.1 `private` — Chỉ Trong Khối `{ }`

Hẹp nhất. Chỉ truy cập được **trong cùng declaration** và các **extension của type đó trong cùng file**.

```swift
class DiscoverViewModel: ObservableObject {
    // ✅ private: chỉ DiscoverViewModel mới dùng được
    private var likedProfileIds: Set<String> = []
    private var currentIndex: Int = 0

    private func updateIndex() {
        currentIndex += 1
    }

    func swipeRight(on profile: Profile) {
        likedProfileIds.insert(profile.id)  // ✅ OK — cùng class
        updateIndex()                        // ✅ OK — cùng class
    }
}

// Extension trong CÙNG FILE được truy cập private
extension DiscoverViewModel {
    func resetState() {
        likedProfileIds.removeAll()  // ✅ OK — cùng file
        currentIndex = 0             // ✅ OK — cùng file
    }
}
```

```swift
// File khác — KHÔNG truy cập được
class AnotherViewModel {
    func test(vm: DiscoverViewModel) {
        vm.likedProfileIds  // ❌ Error: 'likedProfileIds' is inaccessible due to 'private' protection level
    }
}
```

> **Khi nào dùng:** Implementation detail thuần túy — biến cache, counter nội bộ, helper function chỉ có nghĩa trong context đó.

---

### 3.2 `fileprivate` — Toàn Bộ File

Truy cập được bởi **mọi code trong cùng file `.swift`**, bất kể class/struct nào.

```swift
// File: AuthCoordinator.swift

class AuthCoordinator {
    fileprivate var hasShownWelcome = false  // Dùng được trong cả file

    func start() {
        showLoginIfNeeded()
    }
}

// Extension trong CÙNG FILE — truy cập fileprivate OK
extension AuthCoordinator: LoginViewModelDelegate {
    func loginDidSucceed() {
        hasShownWelcome = true  // ✅ OK
        routeToMain()
    }
}

// Helper struct trong CÙNG FILE — cũng OK
struct AuthAnalytics {
    func trackCoordinator(_ coordinator: AuthCoordinator) {
        if coordinator.hasShownWelcome {  // ✅ OK — cùng file
            // track...
        }
    }
}
```

> **Khi nào dùng:** Khi một file chứa nhiều type liên quan chặt chẽ (ví dụ: Coordinator + Delegate extension) và chúng cần chia sẻ state với nhau mà không muốn lộ ra module.

---

### 3.3 `internal` — Toàn Module (Mặc Định)

**Đây là default** — không cần viết từ khóa. Truy cập được bởi **mọi file trong cùng app/framework**.

```swift
// Không cần viết `internal` — đây là mặc định
class ProfileViewModel: ObservableObject {
    @Published var profile: Profile?

    func loadProfile(userId: String) async {
        // ...
    }
}

// Các file khác trong VietMatch app đều dùng được
class AppCoordinator {
    func showProfile() {
        let vm = ProfileViewModel()  // ✅ OK — cùng module
        // ...
    }
}
```

> **Khi nào dùng:** Gần như mọi thứ trong một app đơn target. Đây là sweet spot — đủ rộng để code thoải mái, đủ hẹp để không lộ ra ngoài.

---

### 3.4 `public` — Truy Cập Từ Module Khác, Không Subclass Được

Dùng khi **viết framework/library**. Code bên ngoài module có thể **dùng** nhưng **không thể subclass hoặc override**.

```swift
// Giả sử VietMatch tách ra VietMatchCore.framework

public struct MatchScore {
    public let value: Double
    public let reason: String

    public init(value: Double, reason: String) {
        self.value = value
        self.reason = reason
    }

    // internal method — app không gọi được từ ngoài framework
    func debugDescription() -> String {
        return "Score: \(value) — \(reason)"
    }
}

public class RecommendationEngine {
    public func calculate(for profile: Profile) -> MatchScore {
        // ...
        return MatchScore(value: 0.85, reason: "High compatibility")
    }

    // KHÔNG thể override từ bên ngoài module
    public func reset() { }
}
```

```swift
// Trong app VietMatch (module khác)
import VietMatchCore

let engine = RecommendationEngine()         // ✅ Dùng được
let score = engine.calculate(for: profile)  // ✅ Dùng được

class MyEngine: RecommendationEngine { }   // ❌ Error: cannot inherit from non-open class
```

> **Khi nào dùng:** Public API của SDK/framework mà bạn không muốn ai subclass.

---

### 3.5 `open` — Rộng Nhất, Cho Phép Subclass & Override

Giống `public` nhưng thêm quyền **subclass và override từ bên ngoài module**.

```swift
// Trong VietMatchCore.framework
open class BaseCardView: UIView {
    open func configure(with profile: Profile) {
        // Default implementation
    }

    public func commonSetup() {
        // Dùng được nhưng KHÔNG override được từ ngoài module
    }
}
```

```swift
// Trong app VietMatch (module khác) — được phép vì `open`
class SwipeCardView: BaseCardView {
    override func configure(with profile: Profile) {  // ✅ OK — open cho phép
        super.configure(with: profile)
        // Thêm custom UI
    }
}
```

> **Khi nào dùng:** Base class trong framework mà bạn thiết kế **để được kế thừa** (UIViewController, UIView là ví dụ điển hình của Apple).

---

## 4. Bảng So Sánh Toàn Diện

| Mức | Từ khóa | Scope | Subclass/Override bên ngoài module |
|-----|---------|-------|--------------------------------------|
| Rộng nhất | `open` | Mọi nơi | ✅ Có |
| | `public` | Mọi nơi | ❌ Không |
| Mặc định | `internal` | Trong module | N/A |
| | `fileprivate` | Trong file | N/A |
| Hẹp nhất | `private` | Trong `{ }` (+ extension cùng file) | N/A |

---

## 5. Quy Tắc "Minimum Exposure"

> **Nguyên tắc vàng:** Luôn chọn mức access **hẹp nhất** có thể. Chỉ mở rộng khi thực sự cần.

```swift
// ❌ BAD: Mọi thứ đều public/internal không cần thiết
class ChatViewModel: ObservableObject {
    var messages: [Message] = []        // Quá rộng — ai cũng sửa được
    var isLoadingMore = false           // Không cần lộ ra ngoài
    var firestoreListener: ListenerRegistration?  // Implementation detail!

    func fetchMessages() { }
    func appendMessage(_ msg: Message) { }  // Không nên lộ
}

// ✅ GOOD: Chỉ lộ đúng những gì cần
class ChatViewModel: ObservableObject {
    @Published private(set) var messages: [Message] = []  // Đọc được, không ghi được
    private var isLoadingMore = false
    private var firestoreListener: ListenerRegistration?

    func fetchMessages() { }            // View cần gọi → internal OK

    private func appendMessage(_ msg: Message) { }  // Chỉ ViewModel dùng
}
```

---

## 6. `private(set)` — Đọc Công Khai, Ghi Riêng Tư

Một pattern cực kỳ phổ biến trong VietMatch: expose giá trị để đọc nhưng không cho phép ghi từ bên ngoài.

```swift
class MatchViewModel: ObservableObject {
    // Bên ngoài đọc được, chỉ MatchViewModel mới set được
    @Published private(set) var matches: [Match] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?

    func loadMatches() async {
        isLoading = true          // ✅ OK — trong cùng class
        defer { isLoading = false }

        do {
            matches = try await matchService.fetchMatches()
        } catch {
            self.error = error
        }
    }
}

// Trong View
struct MatchListView: View {
    @StateObject var vm = MatchViewModel()

    var body: some View {
        List(vm.matches, id: \.id) { match in  // ✅ Đọc OK
            MatchRow(match: match)
        }
        // vm.matches = []  // ❌ Error: cannot assign to property: 'matches' setter is inaccessible
    }
}
```

---

## 7. Access Level và Protocol

```swift
// Protocol định nghĩa "contract" — access level của requirement phải >= protocol
public protocol DataService {
    func fetch() async throws -> [Profile]  // Implicitly public
}

// Conform: implementation phải có access level >= requirement của protocol
public class FirestoreProfileService: DataService {
    public func fetch() async throws -> [Profile] {  // Phải public để match
        // ...
        return []
    }
}

// ⚠️ Lỗi phổ biến: implement protocol method với access thấp hơn
class BrokenService: DataService {
    private func fetch() async throws -> [Profile] { }  // ❌ Error: method must be as accessible as its enclosing type
    internal func fetch() async throws -> [Profile] { } // ❌ Error: method must be declared public
}
```

---

## 8. Access Level và Extension

Extension **kế thừa** access level của type mà nó extend, nhưng có thể **hạ xuống**:

```swift
class ProfileViewModel: ObservableObject {
    var profile: Profile?
}

// Extension thêm access riêng — tất cả member trong đây là private
private extension ProfileViewModel {
    func validateProfile() -> Bool {
        guard let profile = profile else { return false }
        return !profile.name.isEmpty && profile.age >= 18
    }
}

// Extension với fileprivate — dùng để tổ chức code trong file
extension ProfileViewModel {
    fileprivate func logEvent(_ event: String) {
        // analytics logging nội bộ
    }
}
```

---

## 9. Áp Dụng Trong VietMatch

### Pattern Thực Tế: ViewModel

```swift
// Features/Discover/DiscoverViewModel.swift
@MainActor
class DiscoverViewModel: ObservableObject {

    // MARK: — Public Interface (View sử dụng)
    @Published private(set) var profiles: [Profile] = []
    @Published private(set) var isLoading = false
    @Published private(set) var currentProfile: Profile?

    func fetchProfiles() async { ... }
    func swipeRight() { ... }
    func swipeLeft() { ... }

    // MARK: — Internal (chỉ trong module, testing cần)
    var onMatchFound: ((Match) -> Void)?

    // MARK: — Private (implementation details)
    private let profileService: ProfileServiceProtocol
    private let matchService: MatchServiceProtocol
    private var swipeHistory: [String: SwipeDirection] = [:]
    private var loadTask: Task<Void, Never>?

    private func handleMatch(_ match: Match) { ... }
    private func updateCurrentProfile() { ... }
}
```

### Pattern Thực Tế: Repository / Service

```swift
// Data/Repositories/ProfileRepository.swift
class ProfileRepository: ProfileRepositoryProtocol {

    // Không ai cần biết đây là Firestore
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    // Cache nội bộ
    private var profileCache: [String: Profile] = [:]

    // Public interface — đây là những gì Use Cases gọi
    func fetchProfile(userId: String) async throws -> Profile {
        if let cached = profileCache[userId] { return cached }
        return try await fetchFromFirestore(userId: userId)
    }

    func updateProfile(_ profile: Profile) async throws {
        try await saveToFirestore(profile)
        profileCache[profile.id] = profile
    }

    // Hoàn toàn ẩn — caller không cần biết backend là gì
    private func fetchFromFirestore(_ userId: String) async throws -> Profile { ... }
    private func saveToFirestore(_ profile: Profile) async throws { ... }
}
```

---

## 10. Lỗi Phổ Biến và Cách Sửa

```swift
// ❌ MISTAKE 1: Quên rằng struct/class cũng cần access label
struct MatchScore {
    var value: Double  // internal — OK trong app, nhưng nếu là framework thì không lộ ra được
}

// ✅ FIX: Nếu là framework, phải public cả type lẫn properties
public struct MatchScore {
    public let value: Double
    public init(value: Double) { self.value = value }
}


// ❌ MISTAKE 2: Initializer không khớp với type
public class ProfileService {
    // init là internal by default → bên ngoài module không tạo được!
    init(db: Firestore) { }
}

// ✅ FIX
public class ProfileService {
    public init(db: Firestore) { }
}


// ❌ MISTAKE 3: Dùng fileprivate khi private là đủ
class ChatViewModel {
    fileprivate var messageCache: [Message] = []  // Không có type nào khác trong file cần đến
}

// ✅ FIX: Dùng private vì chỉ ChatViewModel cần
class ChatViewModel {
    private var messageCache: [Message] = []
}
```

---

## 11. Quy Tắc Chọn

```
Hỏi: "Ai cần truy cập?"

Chỉ đoạn code này (method/property cùng type)?
└─▶ private

Nhiều type trong cùng file cần chia sẻ?
└─▶ fileprivate

Mọi file trong app đều có thể dùng? (80% trường hợp)
└─▶ internal (mặc định, không cần viết)

Framework/library, muốn dùng nhưng không cho subclass?
└─▶ public

Framework/library, muốn dùng VÀ cho subclass/override?
└─▶ open
```

**Nguyên tắc của Apple:** *"Hãy bắt đầu với `private`, chỉ nới lỏng khi compiler báo lỗi hoặc khi bạn thực sự cần."*

---

## 12. Tóm Tắt Nhanh

| Câu hỏi | Trả lời |
|---------|---------|
| Default là gì? | `internal` |
| Hẹp nhất? | `private` |
| Rộng nhất? | `open` |
| `public` vs `open`? | `open` cho phép subclass/override từ module khác |
| `private` vs `fileprivate`? | `private` = chỉ trong `{ }`, `fileprivate` = cả file |
| Đọc được, không ghi được? | `private(set)` |
| Dùng khi viết app đơn target? | `internal` + `private` là đủ — không cần `public`/`open` |
