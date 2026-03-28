# Lifecycle SwiftUI App vs UIKit App — Deep Dive

> Ngày tạo: 2026-03-28 | Áp dụng: VietMatch iOS

---

## 1. Tổng Quan: Hai Thế Hệ Lifecycle

```
UIKit (iOS 2 → nay)              SwiftUI (iOS 14+ @main)
─────────────────────            ─────────────────────────
AppDelegate                      @main App struct
UISceneDelegate (iOS 13+)        WindowGroup / Scene
UIViewController lifecycle       View lifecycle (onAppear/onDisappear)
Imperative + OOP                 Declarative + Value type
```

---

## 2. UIKit App Lifecycle

### 2.1 AppDelegate — Cổng Vào Ứng Dụng

```swift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // App vừa khởi động xong (luôn gọi đầu tiên)
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebase.configure()
        // Setup global appearance
        // Register push notifications
        return true
    }

    // App sắp bị terminate hoàn toàn
    func applicationWillTerminate(_ application: UIApplication) {
        // Lưu dữ liệu cuối cùng
    }
}
```

### 2.2 SceneDelegate — Quản Lý Window (iOS 13+)

```swift
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    // Scene được tạo và kết nối vào app
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
    }

    // App chuyển sang foreground (người dùng mở lại)
    func sceneWillEnterForeground(_ scene: UIScene) { }

    // App đang active (có thể nhận sự kiện người dùng)
    func sceneDidBecomeActive(_ scene: UIScene) { }

    // App sắp vào background (người dùng nhấn Home)
    func sceneWillResignActive(_ scene: UIScene) { }

    // App đã vào background
    func sceneDidEnterBackground(_ scene: UIScene) { }

    // Scene bị hủy (iOS kill tab/window)
    func sceneDidDisconnect(_ scene: UIScene) { }
}
```

### 2.3 App States (UIKit)

```
               ┌─────────────────────────────────────────────┐
               │                                             │
               ▼                                             │
        ┌─────────────┐   launch    ┌──────────────┐         │
        │  Not Running │ ──────────► │   Inactive   │         │
        └─────────────┘             └──────┬───────┘         │
               ▲                          │                  │
               │ terminate                ▼                  │
               │                   ┌──────────────┐          │
               │         ◄──────── │    Active    │          │
               │         interrupt  └──────┬───────┘          │
               │                          │ home/lock         │
               │                          ▼                  │
               │                   ┌──────────────┐          │
               └──────────────────►│  Background  │ ─────────┘
                  memory pressure  └──────────────┘  foreground
                  (Suspended → kill)
```

| State | Mô tả | Delegate Method |
|-------|-------|----------------|
| **Not Running** | Chưa khởi động hoặc bị kill | — |
| **Inactive** | Foreground nhưng không nhận event (gọi điện, notification) | `sceneWillResignActive` |
| **Active** | Đang chạy, nhận event người dùng | `sceneDidBecomeActive` |
| **Background** | Chạy sau màn hình, hạn chế CPU | `sceneDidEnterBackground` |
| **Suspended** | Background nhưng không chạy code | iOS tự quản lý |

### 2.4 UIViewController Lifecycle

```
init / loadView
      │
      ▼
viewDidLoad          ← 1 lần duy nhất, setup UI, bind data
      │
      ▼
viewWillAppear       ← Mỗi lần view sắp hiện (kể cả back)
      │
      ▼
viewIsAppearing      ← iOS 16+, layout đã xong, trait collection cập nhật
      │
      ▼
viewDidAppear        ← View đã hiện, start animation/timer
      │
      │ (user navigates away)
      ▼
viewWillDisappear    ← Dừng timer, lưu data
      │
      ▼
viewDidDisappear     ← Dừng network request, unsubscribe
      │
      ▼
deinit               ← Giải phóng bộ nhớ
```

```swift
class DiscoverViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()       // Chỉ chạy 1 lần
        bindViewModel() // Subscribe Combine publishers
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadProfiles() // Refresh mỗi lần vào màn hình
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cancellables.removeAll() // Unsubscribe
    }

    deinit {
        print("DiscoverViewController deallocated") // Debug memory
    }
}
```

---

## 3. SwiftUI App Lifecycle

### 3.1 @main App Struct — Thay Thế AppDelegate

```swift
@main
struct VietMatchApp: App {

    // Thay thế AppDelegate bằng @UIApplicationDelegateAdaptor nếu cần Firebase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
        }
    }
}
```

### 3.2 Scene Phases — Thay Thế SceneDelegate

```swift
@main
struct VietMatchApp: App {
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                // Tương đương sceneDidBecomeActive
                print("App Active — refresh data, resume timers")

            case .inactive:
                // Tương đương sceneWillResignActive
                print("App Inactive — pause animations")

            case .background:
                // Tương đương sceneDidEnterBackground
                print("App Background — save state, cancel tasks")

            @unknown default:
                break
            }
        }
    }
}
```

### 3.3 View Lifecycle — Thay Thế UIViewController

```swift
struct DiscoverView: View {

    @StateObject var viewModel: DiscoverViewModel

    var body: some View {
        CardStackView(profiles: viewModel.profiles)
            .onAppear {
                // Tương đương viewDidAppear
                // Gọi mỗi lần view xuất hiện (kể cả quay lại)
                viewModel.loadProfiles()
            }
            .onDisappear {
                // Tương đương viewDidDisappear
                // Gọi khi view rời khỏi hierarchy
                viewModel.cancelTasks()
            }
            .task {
                // onAppear + async/await + tự cancel khi view disappear
                await viewModel.loadProfilesAsync()
            }
    }
}
```

### 3.4 SwiftUI View Rendering Lifecycle

```
                    ┌─────────────────────────────────┐
                    │         body computed            │
                    │  (SwiftUI gọi khi state thay đổi)│
                    └────────────┬────────────────────┘
                                 │
              ┌──────────────────┼──────────────────┐
              │                  │                  │
              ▼                  ▼                  ▼
        New View           Same Type          Different Type
     (first render)      (diff & update)     (remove + insert)
              │                  │                  │
              ▼                  ▼                  ▼
          onAppear           onAppear*          onDisappear
                                                 + onAppear
```

*`onAppear` chỉ gọi khi view thực sự xuất hiện trên screen, không phải mỗi lần `body` recompute.

---

## 4. So Sánh Trực Tiếp

### 4.1 App Entry Point

| | UIKit | SwiftUI |
|--|-------|---------|
| **Annotation** | `@UIApplicationMain` | `@main` |
| **Root type** | `class AppDelegate` | `struct App` |
| **Window setup** | `SceneDelegate.window` | `WindowGroup` tự quản lý |
| **Lifecycle hook** | `didFinishLaunching` | `init()` của App struct |

### 4.2 App State Transitions

| UIKit Delegate | SwiftUI ScenePhase | Khi nào |
|----------------|-------------------|---------|
| `sceneDidBecomeActive` | `.active` | User mở app, dismiss notification |
| `sceneWillResignActive` | `.inactive` | Gọi điện đến, kéo notification center |
| `sceneDidEnterBackground` | `.background` | Nhấn Home, switch app |
| `sceneWillEnterForeground` | `.active` (transition) | Mở lại từ background |
| `sceneDidDisconnect` | — | iOS kill scene (ít dùng) |

### 4.3 View Lifecycle

| UIViewController | SwiftUI View | Ghi chú |
|-----------------|-------------|---------|
| `viewDidLoad` | `init` + `.onAppear` | `viewDidLoad` chỉ gọi 1 lần |
| `viewWillAppear` | `.onAppear` | SwiftUI không có "will" |
| `viewDidAppear` | `.onAppear` | Gần tương đương |
| `viewWillDisappear` | `.onDisappear` | SwiftUI không có "will" |
| `viewDidDisappear` | `.onDisappear` | Gần tương đương |
| `viewDidLayoutSubviews` | `.background(GeometryReader)` | Layout pass |
| `deinit` | — | SwiftUI tự quản lý |
| `traitCollectionDidChange` | `.environment(\.colorScheme)` | Declarative |

---

## 5. Sự Khác Biệt Quan Trọng

### 5.1 `body` Recompute ≠ `onAppear`

```swift
struct ProfileCard: View {
    @ObservedObject var viewModel: ProfileViewModel

    init() { print("init") }               // Gọi nhiều lần

    var body: some View {
        // body recompute mỗi khi @ObservedObject publish
        // nhưng onAppear chỉ gọi khi view đi vào hierarchy
        Text(viewModel.name)
            .onAppear { print("onAppear") } // Ít hơn init rất nhiều
    }
}
```

**UIKit:** `viewDidLoad` → 1 lần duy nhất → an toàn để setup heavy resources.
**SwiftUI:** `init` → nhiều lần → đừng đặt heavy work trong `init`. Dùng `.task` hoặc `.onAppear`.

### 5.2 `.task` vs `.onAppear` + `Task`

```swift
// ❌ Cách cũ — phải tự quản lý task lifecycle
.onAppear {
    Task {
        await viewModel.loadData()
        // Task này KHÔNG tự cancel khi view disappear!
    }
}

// ✅ Cách đúng — .task tự cancel khi view disappear
.task {
    await viewModel.loadData()
    // Tự động cancel Task khi onDisappear
}

// ✅ .task với id — cancel và restart khi id thay đổi
.task(id: matchId) {
    await viewModel.loadMessages(matchId: matchId)
}
```

### 5.3 SwiftUI View Không Có `deinit`

```swift
// UIKit: deinit đáng tin cậy
class ChatViewController: UIViewController {
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("ChatVC freed") // Luôn gọi khi VC bị giải phóng
    }
}

// SwiftUI: View là struct, không có deinit
struct ChatView: View {
    // Không có deinit!
    // Dùng .onDisappear thay thế, nhưng không đảm bảo 100%
    var body: some View {
        MessageList()
            .onDisappear {
                // Thay thế cho deinit — nhưng không hoàn toàn tương đương
                // Không gọi nếu parent view bị deallocate đột ngột
            }
    }
}

// Cleanup đúng cách trong SwiftUI: đặt trong ViewModel (class)
class ChatViewModel: ObservableObject {
    deinit {
        cancellables.removeAll() // ViewModel có deinit ✅
    }
}
```

---

## 6. VietMatch Áp Dụng Thực Tế

### AppDelegate — Vẫn Giữ Cho Firebase

```swift
// VietMatch/App/AppDelegate.swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()          // Firebase yêu cầu AppDelegate
        FCMService.shared.setup()        // Push notification
        return true
    }
}

// VietMatch/App/VietMatchApp.swift
@main
struct VietMatchApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // ↑ Bridge giữa SwiftUI lifecycle và UIKit AppDelegate

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
        }
    }
}
```

### DiscoverView — `.task` Pattern

```swift
struct DiscoverView: View {
    @StateObject var viewModel: DiscoverViewModel

    var body: some View {
        SwipeCardStack(profiles: viewModel.profiles) { direction in
            viewModel.swipe(direction)
        }
        .task {
            // Tự cancel khi leave screen → không leak
            await viewModel.loadProfiles()
        }
        .onChange(of: viewModel.showMatchAlert) { shown in
            // React to state change
        }
    }
}
```

### ChatView — Real-time Listener

```swift
struct ChatView: View {
    @StateObject var viewModel: ChatViewModel
    let matchId: String

    var body: some View {
        MessageList(messages: viewModel.messages)
            .task(id: matchId) {
                // Restart listener khi matchId thay đổi
                await viewModel.observeMessages(matchId: matchId)
            }
            .onDisappear {
                viewModel.stopObserving() // Dừng Firestore listener
            }
    }
}
```

---

## 7. Tóm Tắt

```
UIKit                               SwiftUI
────────────────────────────────    ────────────────────────────────
AppDelegate.didFinishLaunching  →   App.init() + @UIApplicationDelegateAdaptor
SceneDelegate states            →   @Environment(\.scenePhase)
viewDidLoad (1 lần)             →   .task { } (1 lần, async)
viewDidAppear (mỗi lần)         →   .onAppear (mỗi lần)
viewDidDisappear                →   .onDisappear
deinit (VC)                     →   deinit (ViewModel — class)
Manual task cancellation        →   .task tự cancel
Imperative setup                →   Declarative + reactive state
```

**Nguyên tắc SwiftUI:** View là hàm của state — SwiftUI quyết định khi nào render lại. Đừng đặt side effects trong `body` hay `init`. Dùng `.task`, `.onAppear`, `.onChange` đúng chỗ.
