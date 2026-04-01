import Foundation

@MainActor
final class MatchesViewModel: ObservableObject {
    @Published var matches: [Match] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    let currentUserId: String
    private let getMatchesUseCase: GetMatchesUseCaseProtocol

    init(currentUserId: String, getMatchesUseCase: GetMatchesUseCaseProtocol) {
        self.currentUserId = currentUserId
        self.getMatchesUseCase = getMatchesUseCase
    }

    var newMatches: [Match] {
        matches.filter { $0.isNew }
    }

    func loadMatches() async {
        isLoading = true
        do {
            matches = try await getMatchesUseCase.execute(userId: currentUserId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
