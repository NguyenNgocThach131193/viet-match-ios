import SwiftUI

protocol Coordinator: ObservableObject {
    associatedtype ContentView: View
    func start() -> ContentView
}

enum AppRoute: Hashable {
    case login
    case register
    case onboarding
    case mainTab
    case profileDetail(profileId: String)
    case chat(matchId: String)
    case editProfile
    case settings
}

enum AuthRoute: Hashable {
    case login
    case register
    case forgotPassword
}

enum DiscoverRoute: Hashable {
    case discover
    case profileDetail(profileId: String)
}

enum ChatRoute: Hashable {
    case conversations
    case chat(matchId: String)
}

enum ProfileRoute: Hashable {
    case profile
    case editProfile
    case settings
}
