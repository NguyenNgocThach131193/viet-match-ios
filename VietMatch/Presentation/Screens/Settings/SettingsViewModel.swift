import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var showLogoutConfirmation = false
    @Published var showDeleteConfirmation = false
    @Published var distancePreference: Double = 50
    @Published var ageRangeMin: Double = 18
    @Published var ageRangeMax: Double = 50
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let logoutUseCase: LogoutUseCaseProtocol

    init(logoutUseCase: LogoutUseCaseProtocol) {
        self.logoutUseCase = logoutUseCase
    }

    func logout() async {
        isLoading = true
        do {
            try await logoutUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
