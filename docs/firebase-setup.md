# Firebase Setup

> Hướng dẫn cài đặt và cấu hình Firebase — Console, SDK, Security Rules

---

Dự án VietMatch sử dụng hệ sinh thái Firebase làm backend (baas) để xử lý xác thực, cơ sở dữ liệu thời gian thực, lưu trữ file và thông báo đẩy. Dưới đây là các bước quy chuẩn để cấu hình Firebase từ Console và tích hợp SDK vào mã nguồn iOS.

## 1. Tạo và thiết lập Project trên Firebase Console

1. Truy cập [Firebase Console](https://console.firebase.google.com/).
2. Chọn **"Add project"** và nhập tên dự án (Ví dụ: `VietMatch`). 
3. *Khuyến nghị:* Mở **Google Analytics** để theo dõi insight người dùng về sau.
4. Chọn/tạo tài khoản Google Analytics nếu được yêu cầu và nhấn **"Create project"**.

## 2. Thêm ứng dụng iOS vào Firebase

1. Trên Dashboard, nhấp vào biểu tượng **iOS**.
2. **Apple bundle ID**: Nhập chính xác Bundle Identifier của dự án XCode (Ví dụ: `com.thachnguyen.VietMatch`). Mọi cấu hình chứng chỉ P8 & OAuth gắn liền với Bundle ID này.
3. Chọn **Register app**.
4. **Tải file cấu hình (Download config file)**: Tải tệp `GoogleService-Info.plist`.
5. Kéo tệp `GoogleService-Info.plist` trực tiếp vào thanh điều hướng bên trái của **Xcode Project** (Ngang cấp với thư mục `VietMatchApp`). Hãy bỏ chọn tùy chọn *Copy items if needed* nếu bạn lưu file sẵn trong project folder, nhưng nhớ kiểm tra tuỳ chọn target là `VietMatch`.

⚠️ **LƯU Ý QUAN TRỌNG:**
Tuyệt đối KHÔNG commit `GoogleService-Info.plist` lên GitHub (Nhất là khi repo là public). Hãy thêm tệp này vào file `.gitignore`:
```bash
# Firebase
GoogleService-Info.plist
```

## 3. Khởi tạo các dịch vụ Firebase (Services)

### 3.1. Firebase Authentication
1. Chuyển đến mục **Build > Authentication**.
2. Chọn "Get started". Chọn tab **Sign-in method**.
3. Bật **Email/Password**.
4. Bật **Apple** và **Google Sign-In** (Để cấu hình Apple Sign-In, bạn cần thiết lập cấu hình Service ID trong thiết bị Apple Developer -> Tham khảo [tài liệu Firebase](https://firebase.google.com/docs/auth/ios/apple)).

### 3.2. Cloud Firestore (Database)
1. Mục **Build > Firestore Database** -> "Create database".
2. Bắt đầu ở chế độ **Test mode** hoặc **Production mode** tuỳ giai đoạn. Vị trí server (Location) nên chọn tối ưu với người dùng (như `asia-southeast1` cho Đông Nam Á).
3. Thiết lập Security Rule cơ sở để tránh lộ dữ liệu (chỉ những ai đã đăng nhập mới thao tác được):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 3.3. Firebase Storage (Lưu trữ ảnh hồ sơ)
1. Mục **Build > Storage** -> "Get started".
2. Khởi tạo Storage Bucket tương tự như Firestore ở trên.
3. Thiết lập Storage Rules: 
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /photos/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 3.4. Firebase Cloud Messaging (FCM)
1. Trong màn hình **Project Settings > Cloud Messaging**.
2. Liên kết Apple App (trong mục **Apple app configuration**). Bạn sẽ cần upload khoá xác thực `APNs Auth Key (.p8)` được cấp từ tài khoản Apple Developer. Mọi thông báo match, gửi tin nhắn sẽ đi qua kết nối này.

---

## 4. Tích hợp SDK vào mã nguồn iOS

Vì VietMatch hiện đại, chúng ta sử dụng **Swift Package Manager (SPM)** thay vì CocoaPods.

1. Trong Xcode, đi tới **File > Add Package Dependencies...**
2. Nhập URL của kho lưu trữ Firebase iOS SDK:
   `https://github.com/firebase/firebase-ios-sdk`
3. Đặt quy tắc phân nhánh bản cập nhật (Thường là *Up to Next Major Version*, vd: `10.0.0`)
4. Khi quá trình phân giải chạy xong, hãy **đánh dấu (tick) chọn những package sau đây** để cài cho target `VietMatch`:
   - `FirebaseAuth`
   - `FirebaseFirestore`
   - `FirebaseFirestoreSwift` (Dành cho việc map models bằng swift-codable / DTOs qua `@DocumentID`)
   - `FirebaseStorage`
   - `FirebaseMessaging`

---

## 5. Khởi tạo Firebase Code Backend

Mở tệp trung tâm của App (thường là `App.swift` hoặc cấu hình `AppDelegate` vì FCM đòi hỏi một số API liên quan tới Delegate để nhận thông báo). 

Áp dụng mẫu tích hợp sau thông qua **UIApplicationDelegate**:

```swift
import SwiftUI
import FirebaseCore
import FirebaseMessaging

// Nếu sử dụng FCM và Push Notifications, UIKit Delegate là bắt buộc
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Khởi tạo Firebase
        FirebaseApp.configure()
        
        // Cấu hình Cloud Messaging delegate (Tuỳ chọn)
        Messaging.messaging().delegate = self
        
        return true
    }
    
    // Đăng ký APNs Token cho Push Notification
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // Nhận lại FCM Token để cập nhật lên Server/Firestore
        let tokenDict = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: tokenDict
        )
    }
}

@main
struct VietMatchApp: App {
    // Kết nối SwiftUI App với AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            // Coordinator Pattern Root hoặc Khởi chạy Di Container
            ContentView()
        }
    }
}
```

## 6. Checklist Cần Hoàn Thành trước khi Lập trình Backend:
- [ ] File `GoogleService-Info.plist` đã được import và chọn copy.
- [ ] `.gitignore` đã khai báo `GoogleService-Info.plist`.
- [ ] Đã Enable sign in bằng Email, Google và Apple trên Console.
- [ ] Đã Update security rules Firestore và Storage theo môi trường phát triển hiện tại. 
- [ ] Xây dựng (Build) thành công dự án Xcode (Cmd + B) sau khi cấu hình `FirebaseApp.configure()`.
