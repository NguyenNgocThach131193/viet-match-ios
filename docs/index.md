# VietMatch - Tài Liệu Dự Án

> Tạo tự động: 2026-03-26 | Scan: Deep | Loại: Mobile (iOS Native)

---

## Tổng Quan Dự Án

- **Loại:** Monolith - iOS Native App
- **Ngôn ngữ:** Swift 5.9+
- **UI Framework:** SwiftUI (iOS 16+)
- **Kiến trúc:** MVVM + Clean Architecture + Coordinator Pattern
- **Backend:** Firebase (Auth, Firestore, Storage, FCM)
- **DI:** Swinject
- **Package Manager:** SPM

---

## Tham Khảo Nhanh

- **Tech Stack:** Swift 5.9, SwiftUI, Firebase, Alamofire, Kingfisher, Swinject
- **Entry Point:** `VietMatch/App/VietMatchApp.swift`
- **Architecture Pattern:** Clean Architecture (3 layers) + MVVM-C
- **Bundle ID:** com.vietmatch.app
- **Device:** iPhone only

---

## Tài Liệu Được Tạo

- [Tổng Quan Dự Án](./project-overview.md)
- [Kiến Trúc](./architecture.md)
- [Phân Tích Cấu Trúc Thư Mục](./source-tree-analysis.md)
- [Component Inventory](./component-inventory.md)
- [Data Models](./data-models.md)
- [Hướng Dẫn Phát Triển](./development-guide.md)

### Hướng Dẫn & Quy Trình

- [Firebase Setup](./firebase-setup.md) - Hướng dẫn cài đặt và cấu hình Firebase (Console, SDK, Security Rules)
- [GitFlow & Branching](./gitflow.md) - GitFlow, branching strategy, Conventional Commits, PR rules

### Deep Dive

- [Navigation Deep Dive](./navigation-deep-dive.md) - Phân tích chi tiết Coordinator Pattern & luồng điều hướng

### Kiến Thức

- [MVVM-C Deep Dive](./knowledge-mvvm-c-deep-dive.md) - Giải thích từng layer, luồng dữ liệu, DI, testing
- [SOLID Deep Dive](./knowledge-solid-deep-dive.md) - 5 nguyên tắc SOLID với code thực tế VietMatch
- [DI & DIP Deep Dive](./knowledge-di-and-dip-deep-dive.md) - Dependency Injection vs Dependency Inversion, Swinject, anti-patterns
- [ARC (Memory Management) Deep Dive](./knowledge-arc-deep-dive.md) - Reference counting, retain cycles, weak/unowned, phân tích VietMatch
- [@StateObject vs @ObservedObject](./knowledge-stateobject-vs-observedobject.md) - So sánh, quy tắc chọn, áp dụng trong VietMatch
- [Async/Await Deep Dive](./knowledge-async-await-deep-dive.md) - Swift async/await, Task, TaskGroup, Actor, @MainActor
- [SwiftUI vs UIKit Lifecycle Deep Dive](./knowledge-swiftui-vs-uikit-lifecycle-deep-dive.md) - App lifecycle, View lifecycle, ScenePhase, .task, so sánh chi tiết
- [Class vs Struct Deep Dive](./knowledge-class-vs-struct-deep-dive.md) - Value type vs Reference type, memory model, CoW, áp dụng trong VietMatch

---

## Tham Chiếu Khác

- [project.yml](../project.yml) - XcodeGen project configuration

---

## Bắt Đầu Nhanh

1. Clone repository và mở `VietMatch.xcodeproj`
2. Xcode tự động resolve SPM dependencies
3. Thêm `GoogleService-Info.plist` vào `VietMatch/App/Resources/`
4. Chọn scheme **VietMatch** → Run (Cmd+R)

Chi tiết: xem [Hướng Dẫn Phát Triển](./development-guide.md)
