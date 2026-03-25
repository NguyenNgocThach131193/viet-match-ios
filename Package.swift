// swift-tools-version: 5.9
// SPM Dependencies for VietMatch
//
// Add these packages in Xcode:
// File > Add Package Dependencies...
//
// Required packages:
// 1. Firebase iOS SDK
//    URL: https://github.com/firebase/firebase-ios-sdk
//    Version: 11.0.0+
//    Products: FirebaseAuth, FirebaseFirestore, FirebaseStorage, FirebaseMessaging, FirebaseAnalytics
//
// 2. Alamofire
//    URL: https://github.com/Alamofire/Alamofire
//    Version: 5.9.0+
//
// 3. Kingfisher
//    URL: https://github.com/onevcat/Kingfisher
//    Version: 7.12.0+
//
// 4. Swinject
//    URL: https://github.com/Swinject/Swinject
//    Version: 2.9.0+

import PackageDescription

let package = Package(
    name: "VietMatch",
    platforms: [.iOS(.v16)],
    products: [],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.9.0"),
        .package(url: "https://github.com/onevcat/Kingfisher", from: "7.12.0"),
        .package(url: "https://github.com/Swinject/Swinject", from: "2.9.0"),
    ],
    targets: []
)
