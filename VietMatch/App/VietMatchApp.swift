import SwiftUI
import FirebaseCore
import Swinject

@main
struct VietMatchApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appCoordinator: AppCoordinator

    private static var isTesting: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    init() {
        if Self.isTesting {
            _appCoordinator = StateObject(wrappedValue: AppCoordinator(container: Container()))
        } else {
            let coordinator = AppContainer.shared.resolve(AppCoordinator.self)
            _appCoordinator = StateObject(wrappedValue: coordinator)
        }
    }

    var body: some Scene {
        WindowGroup {
            if !Self.isTesting {
                AppCoordinatorView(coordinator: appCoordinator)
                    .environmentObject(NetworkMonitor.shared)
            }
        }
    }
}
