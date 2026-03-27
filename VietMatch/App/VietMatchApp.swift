import SwiftUI
import FirebaseCore

@main
struct VietMatchApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appCoordinator: AppCoordinator

    init() {
        let coordinator = AppContainer.shared.resolve(AppCoordinator.self)
        _appCoordinator = StateObject(wrappedValue: coordinator)
    }

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(coordinator: appCoordinator)
                .environmentObject(NetworkMonitor.shared)
        }
    }
}
