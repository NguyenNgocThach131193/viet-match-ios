# Async/Await Deep Dive

> Swift async/await, Task, TaskGroup, Actor và @MainActor

---

## 1. VẤN ĐỀ CŨ: Callback Hell

```swift
// ❌ Trước đây: Callback lồng nhau, khó đọc, dễ quên gọi completion
func fetchUser(completion: @escaping (Result<User, Error>) -> Void) {
    networkService.request("/user") { result in
        switch result {
        case .success(let data):
            self.parseUser(data) { parseResult in
                switch parseResult {
                case .success(let user):
                    self.cacheUser(user) { cacheResult in
                        completion(.success(user)) // 3 tầng lồng nhau!
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        case .failure(let error):
            completion(.failure(error)) // Dễ quên dòng này → app treo
        }
    }
}
```

## 2. GIẢI PHÁP: async/await

```swift
// ✅ Sau: Code đọc từ trên xuống như code đồng bộ
func fetchUser() async throws -> User {
    let data = try await networkService.request("/user")
    let user = try await parseUser(data)
    try await cacheUser(user)
    return user
}
```

**2 keyword cốt lõi:**
- `async` → đánh dấu hàm có thể tạm dừng (suspend)
- `await` → điểm mà hàm tạm dừng, nhường thread cho việc khác

**Quy tắc vàng:** Hàm `async` chỉ được gọi từ context `async` khác, hoặc từ `Task`.

## 3. CÁCH GỌI HÀM ASYNC

### 3a. Từ hàm async khác

```swift
func loadProfile() async throws -> Profile {
    let user = try await fetchUser()        // gọi trực tiếp
    let avatar = try await fetchAvatar(user.id)
    return Profile(user: user, avatar: avatar)
}
```

### 3b. Từ code đồng bộ (SwiftUI / UIKit) → dùng `Task`

```swift
// SwiftUI
struct ProfileView: View {
    var body: some View {
        Button("Load") {
            Task {  // ← cầu nối sync → async
                do {
                    let profile = try await loadProfile()
                    self.profile = profile
                } catch {
                    self.error = error
                }
            }
        }
        .task {  // ← SwiftUI modifier, tự cancel khi view biến mất
            await loadInitialData()
        }
    }
}
```

### 3c. Task vs Task.detached

```swift
Task {
    // Kế thừa actor context (ví dụ: MainActor)
    // → UI update an toàn
}

Task.detached {
    // KHÔNG kế thừa context
    // → chạy trên background thread
}
```

## 4. XỬ LÝ LỖI

```swift
// throws + async kết hợp tự nhiên
func fetchData() async throws -> Data { ... }

// Gọi:
do {
    let data = try await fetchData()
} catch {
    print(error) // Bắt lỗi như code đồng bộ bình thường
}

// Không cần throws? → chỉ dùng async
func fetchCachedData() async -> Data? { ... }
let data = await fetchCachedData() // không cần try
```

## 5. CHẠY SONG SONG: async let

```swift
// ❌ Tuần tự - chậm (3 + 2 = 5 giây)
let user = try await fetchUser()       // 3 giây
let photos = try await fetchPhotos()   // 2 giây

// ✅ Song song - nhanh (max(3,2) = 3 giây)
async let user = fetchUser()           // bắt đầu ngay
async let photos = fetchPhotos()       // bắt đầu ngay, không chờ user
let result = try await (user, photos)  // chờ cả 2 xong
```

**Quy tắc:** Dùng `async let` khi 2 tác vụ **không phụ thuộc nhau**.

## 6. TaskGroup - Song song số lượng động

```swift
// Tải N ảnh song song
func fetchAllPhotos(ids: [String]) async throws -> [Photo] {
    try await withThrowingTaskGroup(of: Photo.self) { group in
        for id in ids {
            group.addTask {
                try await self.fetchPhoto(id: id)
            }
        }

        var photos: [Photo] = []
        for try await photo in group {  // thu kết quả khi mỗi task xong
            photos.append(photo)
        }
        return photos
    }
}
```

## 7. ACTOR - Bảo vệ dữ liệu

### Vấn đề: Data race

```swift
// ❌ Nhiều task truy cập cùng lúc → crash
class Counter {
    var count = 0
    func increment() { count += 1 }  // Không an toàn!
}
```

### Giải pháp: Actor

```swift
// ✅ Actor = class + tự động serialize truy cập
actor Counter {
    var count = 0
    func increment() { count += 1 }  // An toàn, chỉ 1 task vào 1 lúc
}

let counter = Counter()
await counter.increment()  // Phải await vì actor bảo vệ truy cập
print(await counter.count) // Đọc cũng phải await
```

### @MainActor - Actor đặc biệt cho UI

```swift
@MainActor  // ← Mọi thứ trong class này chạy trên main thread
final class LoginViewModel: ObservableObject {
    @Published var isLoading = false  // UI-safe

    func login() async {
        isLoading = true  // ✅ main thread, an toàn update UI
        let result = try? await authService.login()
        isLoading = false
    }
}
```

**Lưu ý:** Khi dùng Swinject (DI container), closure register không có `@MainActor` context nhưng ViewModel init yêu cầu MainActor → cần wrap bằng `MainActor.assumeIsolated { }`.

## 8. CHUYỂN ĐỔI TỪ CALLBACK → ASYNC

```swift
// API cũ dùng callback
func oldFetch(completion: @escaping (Data?) -> Void) { ... }

// Wrap thành async
func newFetch() async -> Data? {
    await withCheckedContinuation { continuation in
        oldFetch { data in
            continuation.resume(returning: data)  // GỌI ĐÚNG 1 LẦN!
        }
    }
}

// Có throws:
func newFetchThrowing() async throws -> Data {
    try await withCheckedThrowingContinuation { continuation in
        oldFetch { result in
            switch result {
            case .success(let data): continuation.resume(returning: data)
            case .failure(let error): continuation.resume(throwing: error)
            }
        }
    }
}
```

## 9. CANCEL - Hủy tác vụ

```swift
let task = Task {
    for i in 0..<1000 {
        try Task.checkCancellation()  // Ném lỗi nếu bị cancel
        // hoặc:
        guard !Task.isCancelled else { return }  // Tự xử lý
        await processItem(i)
    }
}

task.cancel()  // Đánh dấu cancel, KHÔNG kill ngay
```

**`.task { }` trong SwiftUI tự cancel khi view disappear** → không cần quản lý thủ công.

## 10. TÓM TẮT BẢNG SO SÁNH

| Cần gì? | Dùng gì |
|---|---|
| Đánh dấu hàm bất đồng bộ | `async` / `async throws` |
| Gọi hàm async | `await` / `try await` |
| Gọi async từ code sync | `Task { }` |
| 2-3 tác vụ song song | `async let` |
| N tác vụ song song | `TaskGroup` |
| Bảo vệ shared state | `actor` |
| Update UI an toàn | `@MainActor` |
| Wrap callback cũ | `withCheckedContinuation` |
| Hủy tác vụ | `task.cancel()` + `Task.checkCancellation()` |

## 11. FLOW TRONG DỰ ÁN iOS THỰC TẾ

```
View (@MainActor)
  → Task { try await viewModel.login() }
    → ViewModel (@MainActor)
      → await useCase.execute()
        → await repository.login()
          → try await withCheckedContinuation { ... }  // wrap Firebase/URLSession
```
