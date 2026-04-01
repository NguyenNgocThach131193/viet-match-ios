import Foundation

@MainActor
final class ProfileDetailViewModel: ObservableObject {
    @Published var profile: Profile?
    @Published var isLoading = false
    @Published private(set) var isSwiping = false
    @Published var showMatchAlert = false
    @Published var matchedProfile: Profile?
    @Published var errorMessage: String?

    private let profileId: String
    private let currentUserId: String
    private let getProfileUseCase: GetProfileUseCaseProtocol
    private let swipeUseCase: SwipeUseCaseProtocol

    init(
        profileId: String,
        currentUserId: String,
        getProfileUseCase: GetProfileUseCaseProtocol,
        swipeUseCase: SwipeUseCaseProtocol
    ) {
        self.profileId = profileId
        self.currentUserId = currentUserId
        self.getProfileUseCase = getProfileUseCase
        self.swipeUseCase = swipeUseCase
    }

    func loadProfile() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            profile = try await getProfileUseCase.execute(userId: profileId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func swipe(direction: SwipeDirection) async {
        guard !isSwiping else { return }
        guard let profile else { return }
        isSwiping = true
        defer { isSwiping = false }
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
}
