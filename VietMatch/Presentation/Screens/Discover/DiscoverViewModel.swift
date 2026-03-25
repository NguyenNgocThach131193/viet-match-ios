import Foundation

@MainActor
final class DiscoverViewModel: ObservableObject {
    @Published var profiles: [Profile] = []
    @Published var currentIndex = 0
    @Published var isLoading = false
    @Published var showMatchAlert = false
    @Published var matchedProfile: Profile?
    @Published var errorMessage: String?

    private let getDiscoverProfilesUseCase: GetDiscoverProfilesUseCaseProtocol
    private let swipeUseCase: SwipeUseCaseProtocol
    private var currentUserId: String = ""

    init(
        getDiscoverProfilesUseCase: GetDiscoverProfilesUseCaseProtocol,
        swipeUseCase: SwipeUseCaseProtocol
    ) {
        self.getDiscoverProfilesUseCase = getDiscoverProfilesUseCase
        self.swipeUseCase = swipeUseCase
    }

    var currentProfile: Profile? {
        guard currentIndex < profiles.count else { return nil }
        return profiles[currentIndex]
    }

    var hasMoreProfiles: Bool {
        currentIndex < profiles.count
    }

    func loadProfiles(userId: String) async {
        currentUserId = userId
        isLoading = true
        do {
            profiles = try await getDiscoverProfilesUseCase.execute(
                userId: userId,
                limit: Constants.App.defaultDiscoverLimit
            )
            currentIndex = 0
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func swipe(direction: SwipeDirection) async {
        guard let profile = currentProfile else { return }

        do {
            let match = try await swipeUseCase.execute(
                swiperId: currentUserId,
                swipedUserId: profile.id,
                direction: direction
            )

            if let match, match.matchedUserId == profile.id {
                matchedProfile = profile
                showMatchAlert = true
            }

            currentIndex += 1

            if currentIndex >= profiles.count - 3 {
                await loadMoreProfiles()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func like() async {
        await swipe(direction: .like)
    }

    func dislike() async {
        await swipe(direction: .dislike)
    }

    func superLike() async {
        await swipe(direction: .superLike)
    }

    private func loadMoreProfiles() async {
        do {
            let newProfiles = try await getDiscoverProfilesUseCase.execute(
                userId: currentUserId,
                limit: Constants.App.defaultDiscoverLimit
            )
            profiles.append(contentsOf: newProfiles)
        } catch {
            AppLogger.general.error("Failed to load more profiles: \(error.localizedDescription)")
        }
    }
}
