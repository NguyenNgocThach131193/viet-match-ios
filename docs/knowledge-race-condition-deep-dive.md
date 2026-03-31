# Race Condition Deep Dive

> Data race, race condition, nguyên nhân, cách phát hiện, và phòng tránh trong Swift & VietMatch

---

## 1. Race Condition Là Gì?

Hãy tưởng tượng hai người cùng rút tiền từ **một tài khoản ATM** cùng lúc:

```
Tài khoản: 1,000,000đ

Người A đọc số dư: 1,000,000đ     Người B đọc số dư: 1,000,000đ
Người A rút 700,000đ               Người B rút 500,000đ
Người A ghi lại: 300,000đ          Người B ghi lại: 500,000đ

Kết quả cuối: 500,000đ (sai!) thay vì bị từ chối vì không đủ tiền
```

Trong code, **race condition** xảy ra khi:
- Hai hoặc nhiều thread/task **truy cập cùng dữ liệu**
- Ít nhất một trong số đó **ghi/thay đổi** dữ liệu
- Không có cơ chế **đồng bộ hóa** nào bảo vệ

---

## 2. Phân Biệt: Data Race vs Race Condition

Hai khái niệm này thường bị nhầm lẫn nhưng **khác nhau**:

```
┌──────────────────────────────────────────────────────────────────┐
│                        DATA RACE                                 │
│  Hai thread truy cập CÙNG vùng nhớ đồng thời,                   │
│  ít nhất 1 thread GHI, KHÔNG có đồng bộ hóa.                    │
│                                                                  │
│  → Undefined behavior, crash, corrupt memory                     │
│  → Swift compiler có thể PHÁT HIỆN (Swift 6 strict concurrency)  │
├──────────────────────────────────────────────────────────────────┤
│                      RACE CONDITION                              │
│  Kết quả chương trình PHỤ THUỘC vào thứ tự thực thi             │
│  của các thread — dù không có data race.                         │
│                                                                  │
│  → Logic sai, kết quả không nhất quán                            │
│  → Compiler KHÔNG THỂ phát hiện — cần lập trình viên xử lý      │
└──────────────────────────────────────────────────────────────────┘
```

```swift
// ═══ DATA RACE ═══
// Hai thread ghi vào cùng biến, không protection
var count = 0

DispatchQueue.concurrentPerform(iterations: 1000) { _ in
    count += 1  // ❌ DATA RACE: read-modify-write không atomic
}
print(count)  // Có thể ra 987, 993, 1000... mỗi lần chạy khác nhau


// ═══ RACE CONDITION (không có data race) ═══
// Thread-safe nhờ actor, nhưng logic vẫn sai
actor BankAccount {
    var balance: Int = 1_000_000

    func getBalance() -> Int { balance }
    func withdraw(_ amount: Int) { balance -= amount }
}

let account = BankAccount()

// Task A và Task B đều check rồi rút — nhưng check và rút KHÔNG atomic
Task {
    let balance = await account.getBalance()    // 1,000,000
    if balance >= 700_000 {
        await account.withdraw(700_000)          // OK: còn 300,000
    }
}
Task {
    let balance = await account.getBalance()    // 1,000,000 (đọc trước khi A rút)
    if balance >= 500_000 {
        await account.withdraw(500_000)          // Rút thêm! Còn -200,000 😱
    }
}

// FIX: gộp check + withdraw thành 1 operation atomic
actor BankAccountFixed {
    var balance: Int = 1_000_000

    func withdraw(_ amount: Int) -> Bool {  // ← Atomic operation
        guard balance >= amount else { return false }
        balance -= amount
        return true
    }
}
```

---

## 3. Các Dạng Race Condition Phổ Biến

### 3.1 Check-Then-Act

```swift
// ❌ RACE: check và act là 2 bước riêng biệt
class ProfileService {
    var cachedProfile: Profile?

    func getProfile() async -> Profile {
        if cachedProfile == nil {           // Thread A check: nil
            // Thread B cũng check: nil (chưa kịp set)
            cachedProfile = try? await fetchFromServer()  // Cả 2 đều fetch!
        }
        return cachedProfile!
    }
}

// ✅ FIX: dùng actor để serialize access
actor ProfileCache {
    private var cachedProfile: Profile?
    private var fetchTask: Task<Profile, Error>?

    func getProfile() async throws -> Profile {
        if let profile = cachedProfile { return profile }

        // Nếu đã có task đang fetch → chờ task đó
        if let existingTask = fetchTask {
            return try await existingTask.value
        }

        // Tạo task mới, lưu lại để các caller khác chờ cùng task
        let task = Task { try await fetchFromServer() }
        fetchTask = task
        let profile = try await task.value
        cachedProfile = profile
        fetchTask = nil
        return profile
    }
}
```

### 3.2 Read-Modify-Write

```swift
// ❌ RACE: đọc → tính toán → ghi không phải atomic
class LikeCounter {
    var likes = 0

    func increment() {
        let current = likes    // Thread A đọc: 5
        // Thread B cũng đọc: 5
        likes = current + 1    // Thread A ghi: 6
        // Thread B ghi: 6 (mất 1 like!)
    }
}

// ✅ FIX 1: Actor
actor LikeCounter {
    var likes = 0
    func increment() { likes += 1 }  // Serialized tự động
}

// ✅ FIX 2: os_unfair_lock (khi cần performance tối đa)
import os

final class AtomicCounter: @unchecked Sendable {
    private var _value = 0
    private let lock = OSAllocatedUnfairLock()

    var value: Int {
        lock.withLock { _value }
    }

    func increment() {
        lock.withLock { _value += 1 }
    }
}
```

### 3.3 Publish-Subscribe Race (UI Update)

```swift
// ❌ RACE: update @Published từ background thread
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []

    func loadMessages() {
        someBackgroundQueue.async {
            let newMessages = self.fetchMessages()
            self.messages = newMessages  // ❌ CRASH: @Published PHẢI update trên main thread
        }
    }
}

// ✅ FIX: @MainActor đảm bảo main thread
@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []

    func loadMessages() async {
        let newMessages = await fetchMessages()  // Chạy trên background
        messages = newMessages  // Tự động trên main thread nhờ @MainActor
    }
}
```

### 3.4 Double Trigger / Duplicate Request

```swift
// ❌ RACE: user tap nút 2 lần nhanh → 2 request
@MainActor
final class DiscoverViewModel: ObservableObject {
    @Published var isLoading = false

    func sendLike(to userId: String) async {
        isLoading = true
        try? await matchService.like(userId)  // Request 1
        // User tap lại trước khi request 1 xong → Request 2 gửi đi!
        isLoading = false
    }
}

// ✅ FIX: track task hiện tại, cancel nếu đã có
@MainActor
final class DiscoverViewModel: ObservableObject {
    @Published var isLoading = false
    private var likeTask: Task<Void, Never>?

    func sendLike(to userId: String) {
        // Nếu đang có request → bỏ qua
        guard likeTask == nil else { return }

        likeTask = Task {
            isLoading = true
            try? await matchService.like(userId)
            isLoading = false
            likeTask = nil
        }
    }
}
```

---

## 4. Các Cơ Chế Phòng Tránh Trong Swift

### Bảng So Sánh

```
Cơ chế                 Use Case                      Performance    Thread Safety
────────────────────────────────────────────────────────────────────────────────────
@MainActor             ViewModel, UI state            ★★★★☆         ✅ Main thread only
actor                  Shared mutable state           ★★★★☆         ✅ Serialized access
OSAllocatedUnfairLock  Hot path, low-level sync       ★★★★★         ✅ Mutual exclusion
DispatchQueue(serial)  Legacy code, ordered execution ★★★☆☆         ✅ FIFO ordering
NSLock / NSRecursive   Khi cần recursive locking      ★★★☆☆         ✅ Mutual exclusion
Semaphore              Giới hạn concurrent access     ★★★☆☆         ✅ Counting
async let / TaskGroup  Structured concurrency         ★★★★★         ✅ By design
@Sendable              Compiler-checked safety        ★★★★★         ✅ Compile time
```

### 4.1 Actor — Lựa Chọn Mặc Định

```swift
// Actor = class + tự động serialized access
// Mọi method/property đều được bảo vệ, không cần lock thủ công

actor ImageDownloadManager {
    private var activeDownloads: [URL: Task<UIImage, Error>] = [:]
    private var cache: [URL: UIImage] = [:]

    func download(url: URL) async throws -> UIImage {
        // 1. Check cache
        if let cached = cache[url] { return cached }

        // 2. Check đang download → chờ task hiện tại (tránh duplicate)
        if let existing = activeDownloads[url] {
            return try await existing.value
        }

        // 3. Tạo download task mới
        let task = Task {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else {
                throw URLError(.cannotDecodeContentData)
            }
            return image
        }

        activeDownloads[url] = task

        do {
            let image = try await task.value
            cache[url] = image
            activeDownloads[url] = nil
            return image
        } catch {
            activeDownloads[url] = nil
            throw error
        }
    }
}
```

### 4.2 @MainActor — Cho ViewModel & UI

```swift
// @MainActor = actor đặc biệt, chạy trên main thread
// Mọi property và method đều tự động trên main thread

@MainActor
final class MatchesViewModel: ObservableObject {
    @Published var matches: [Match] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Tất cả method đều main-thread-safe
    func loadMatches() async {
        guard !isLoading else { return }  // Tránh duplicate request
        isLoading = true
        defer { isLoading = false }       // Đảm bảo reset dù error

        do {
            matches = try await getMatchesUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

### 4.3 OSAllocatedUnfairLock — Cho Performance-Critical Code

```swift
import os

// Dùng khi actor quá nặng (actor có chi phí context switch)
// Ví dụ: counter, flag, simple state trong tight loop

final class RequestThrottler: @unchecked Sendable {
    private let lock = OSAllocatedUnfairLock(initialState: State())

    private struct State {
        var lastRequestTime: Date = .distantPast
        var requestCount: Int = 0
    }

    func shouldAllow() -> Bool {
        lock.withLock { state in
            let now = Date()
            if now.timeIntervalSince(state.lastRequestTime) > 60 {
                state.requestCount = 0
                state.lastRequestTime = now
            }
            state.requestCount += 1
            return state.requestCount <= 100  // Max 100 requests/phút
        }
    }
}
```

### 4.4 Structured Concurrency — An Toàn By Design

```swift
// async let và TaskGroup tự động đảm bảo:
// - Tất cả child tasks hoàn thành trước khi scope kết thúc
// - Cancel tự động khi parent bị cancel
// - Không leak task

func loadDiscoverScreen() async throws -> DiscoverData {
    // Chạy song song, tự động chờ cả hai
    async let profiles = profileRepository.fetchNearby()
    async let preferences = preferenceRepository.getFilters()

    // Cả hai hoàn thành → combine kết quả
    return DiscoverData(
        profiles: try await profiles,
        filters: try await preferences
    )
}

// TaskGroup cho số lượng dynamic
func uploadPhotos(_ images: [UIImage]) async throws -> [String] {
    try await withThrowingTaskGroup(of: String.self) { group in
        for image in images {
            group.addTask {
                try await self.storageService.upload(image)
            }
        }

        var urls: [String] = []
        for try await url in group {
            urls.append(url)
        }
        return urls
    }
}
```

---

## 5. Race Condition Trong Combine (Reactive Streams)

VietMatch dùng Combine cho real-time Firestore data. Cần chú ý:

```swift
// ❌ RACE: sink callback có thể chạy trên background thread
firestoreService.observeMessages(matchId: matchId)
    .sink { [weak self] messages in
        self?.messages = messages  // Thread nào? Không biết! 💥
    }
    .store(in: &cancellables)

// ✅ FIX: .receive(on:) đảm bảo main thread
firestoreService.observeMessages(matchId: matchId)
    .receive(on: DispatchQueue.main)     // ← Chuyển về main
    .sink { [weak self] messages in
        self?.messages = messages         // ✅ Luôn trên main thread
    }
    .store(in: &cancellables)


// ⚠️ CHÚ Ý: .receive(on:) vs @MainActor
// Nếu ViewModel đã @MainActor, vẫn NÊN dùng .receive(on:)
// vì sink closure KHÔNG tự động inherit @MainActor isolation

@MainActor
final class ChatViewModel: ObservableObject {
    func observe() {
        publisher
            .receive(on: DispatchQueue.main)  // ← Vẫn cần!
            .sink { [weak self] value in
                self?.update(value)            // Safe
            }
            .store(in: &cancellables)
    }
}
```

### Combine Operators Gây Race

```swift
// ❌ combineLatest có thể fire quá nhanh
Publishers.CombineLatest(publisherA, publisherB)
    .sink { a, b in
        // Có thể nhận (oldA, newB) rồi (newA, newB) rất nhanh
        // Nếu mỗi lần trigger expensive operation → lãng phí
    }

// ✅ debounce để gộp multiple rapid updates
Publishers.CombineLatest(publisherA, publisherB)
    .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
    .sink { a, b in
        // Chỉ trigger khi đã "ổn định" 100ms
    }
```

---

## 6. Phát Hiện Race Condition

### 6.1 Thread Sanitizer (TSan)

Công cụ mạnh nhất để phát hiện data race:

```
Xcode → Product → Scheme → Edit Scheme
    → Run → Diagnostics → ✅ Thread Sanitizer

Hoặc command line:
swift test --sanitize=thread
```

```
Khi phát hiện race, TSan báo:
┌──────────────────────────────────────────────────────┐
│ WARNING: ThreadSanitizer: data race                  │
│                                                      │
│ Write of size 8 at 0x7f8b2c by thread T2:            │
│   #0 ChatViewModel.messages.setter                   │
│   #1 ChatViewModel.loadMessages()                    │
│                                                      │
│ Previous read of size 8 at 0x7f8b2c by main thread:  │
│   #0 ChatViewModel.messages.getter                   │
│   #1 SwiftUI.View.body.getter                        │
└──────────────────────────────────────────────────────┘
```

### 6.2 Swift 6 Strict Concurrency

```swift
// Package.swift hoặc Build Settings
// Swift Compiler → Strict Concurrency Checking: Complete

// Swift 6 bắt lỗi tại COMPILE TIME:
class UnsafeService {
    var cache: [String: Data] = [:]  // ❌ Error: stored property is not Sendable

    func update() {
        Task {
            cache["key"] = data      // ❌ Error: capture of non-sendable 'self'
        }
    }
}
```

### 6.3 Dấu Hiệu Nhận Biết Trong Code Review

```
🚩 Red flags — Có thể có race condition:

1. var property trong class (không phải actor/MainActor)
2. Closure capture self mà không có synchronization
3. DispatchQueue.global().async { self.something = ... }
4. Thiếu .receive(on:) trong Combine pipeline
5. Check-then-act pattern (if x == nil { x = ... })
6. Singleton với mutable state
7. Dictionary/Array được access từ nhiều thread
8. @Published update không trên main thread
```

---

## 7. Áp Dụng Trong VietMatch

### Architecture Hiện Tại — Đã Tốt ✅

```
┌─────────────────────────────────────────────────────────┐
│                    SwiftUI View                          │
│                  (Main Thread)                           │
├─────────────────────────────────────────────────────────┤
│              @MainActor ViewModel                        │
│         @Published var ← luôn trên main thread           │
│              async func ← await trả về main              │
├─────────────────────────────────────────────────────────┤
│                   UseCase (async)                        │
│            Stateless → không có shared state             │
├─────────────────────────────────────────────────────────┤
│                Repository (async)                        │
│          final class + chỉ gọi service methods           │
├─────────────────────────────────────────────────────────┤
│           Firebase Service (async/Publisher)              │
│      Firebase SDK handle threading internally            │
└─────────────────────────────────────────────────────────┘
```

**Tại sao VietMatch ít rủi ro race condition:**

| Pattern | Cách VietMatch dùng | Race-safe? |
|---------|---------------------|------------|
| ViewModel state | `@MainActor` + `@Published` | ✅ Main thread confined |
| Firebase calls | `async/await` (suspend, không block) | ✅ Compiler-checked |
| Real-time data | Combine + `.receive(on: .main)` | ✅ Explicit thread switch |
| Entities | `struct` (value types) | ✅ Copy semantics |
| Network monitor | Background queue + `DispatchQueue.main.async` | ✅ Explicit dispatch |
| UseCases | Stateless, async | ✅ No shared state |

### Những Chỗ Cần Chú Ý ⚠️

```swift
// 1. Singleton có mutable state
// NetworkMonitor.shared → @Published properties
// Đã dùng DispatchQueue.main.async ✅ nhưng cân nhắc chuyển sang actor

// 2. Nếu thêm cache layer sau này → PHẢI dùng actor
// ❌ Đừng làm thế này:
class ProfileCache {
    static let shared = ProfileCache()
    var profiles: [String: Profile] = [:]  // ← RACE!
}

// ✅ Làm thế này:
actor ProfileCache {
    static let shared = ProfileCache()
    private var profiles: [String: Profile] = [:]

    func get(_ id: String) -> Profile? { profiles[id] }
    func set(_ id: String, profile: Profile) { profiles[id] = profile }
}


// 3. Task cancellation — chú ý khi navigate away
@MainActor
final class SomeViewModel: ObservableObject {
    private var loadTask: Task<Void, Never>?

    func onAppear() {
        loadTask = Task {
            // Nếu user navigate away giữa chừng...
            let data = try? await fetchData()
            guard !Task.isCancelled else { return }  // ← Check cancel
            self.data = data
        }
    }

    func onDisappear() {
        loadTask?.cancel()  // ← Cleanup
        loadTask = nil
    }
}
```

---

## 8. Checklist Phòng Tránh Race Condition

```
Khi viết code mới, kiểm tra:

□ ViewModel có @MainActor không?
□ @Published chỉ update trên main thread?
□ Combine sink có .receive(on: DispatchQueue.main)?
□ Shared mutable state dùng actor hoặc lock?
□ Check-then-act đã gộp thành atomic operation?
□ Task có handle cancellation đúng?
□ Singleton có mutable state → cần actor?
□ async func có guard !Task.isCancelled khi cần?
□ Đã bật Thread Sanitizer trong scheme Debug?
□ Strict Concurrency Checking = Complete?
```

---

## 9. Tổng Kết

```
                    Race Condition Prevention Pyramid

                         ┌───────────┐
                         │  DESIGN   │  ← Tốt nhất: thiết kế để
                         │ Value Type│     không có shared state
                         │ Stateless │
                         ├───────────┤
                         │  ISOLATE  │  ← @MainActor, actor
                         │ Actor     │     serialize access
                         │ MainActor │     tự động
                         ├───────────┤
                         │SYNCHRONIZE│  ← Lock, serial queue
                         │  Lock     │     thủ công hơn, dễ sai
                         │  Queue    │
                         ├───────────┤
                         │  DETECT   │  ← TSan, Swift 6
                         │  TSan     │     phát hiện sau khi
                         │  Review   │     đã viết code
                         └───────────┘

Ưu tiên từ trên xuống: Design > Isolate > Synchronize > Detect
```

**Nguyên tắc vàng:**
- **Struct by default** — value types không có shared state → không race
- **@MainActor cho ViewModel** — UI state luôn trên main thread
- **Actor cho shared mutable state** — compiler enforce isolation
- **Bật TSan trong Debug** — phát hiện sớm, sửa rẻ
