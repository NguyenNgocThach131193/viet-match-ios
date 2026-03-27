import Foundation

@MainActor
final class MatchesViewModel: ObservableObject {
    @Published var matches: [Match] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let getMatchesUseCase: GetMatchesUseCaseProtocol

    init(getMatchesUseCase: GetMatchesUseCaseProtocol) {
        self.getMatchesUseCase = getMatchesUseCase
    }

    var newMatches: [Match] {
        matches.filter { $0.isNew }
    }

    func loadMatches(userId: String) async {
        isLoading = true
        do {
            matches = try await getMatchesUseCase.execute(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
