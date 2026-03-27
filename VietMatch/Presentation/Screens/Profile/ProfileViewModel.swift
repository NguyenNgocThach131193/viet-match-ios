import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profile: Profile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isEditing = false

    // Editable fields
    @Published var editName = ""
    @Published var editBio = ""
    @Published var editJobTitle = ""
    @Published var editCompany = ""
    @Published var editSchool = ""

    private let getProfileUseCase: GetProfileUseCaseProtocol
    private let updateProfileUseCase: UpdateProfileUseCaseProtocol
    private let logoutUseCase: LogoutUseCaseProtocol

    init(
        getProfileUseCase: GetProfileUseCaseProtocol,
        updateProfileUseCase: UpdateProfileUseCaseProtocol,
        logoutUseCase: LogoutUseCaseProtocol
    ) {
        self.getProfileUseCase = getProfileUseCase
        self.updateProfileUseCase = updateProfileUseCase
        self.logoutUseCase = logoutUseCase
    }

    func loadProfile(userId: String) async {
        isLoading = true
        do {
            profile = try await getProfileUseCase.execute(userId: userId)
            syncEditFields()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func saveProfile() async {
        guard var updatedProfile = profile else { return }
        updatedProfile.name = editName.trimmed
        updatedProfile.bio = editBio.trimmed
        updatedProfile.jobTitle = editJobTitle.trimmed.isEmpty ? nil : editJobTitle.trimmed
        updatedProfile.company = editCompany.trimmed.isEmpty ? nil : editCompany.trimmed
        updatedProfile.school = editSchool.trimmed.isEmpty ? nil : editSchool.trimmed

        isLoading = true
        do {
            profile = try await updateProfileUseCase.execute(updatedProfile)
            isEditing = false
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func logout() async {
        do {
            try await logoutUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func syncEditFields() {
        guard let profile else { return }
        editName = profile.name
        editBio = profile.bio
        editJobTitle = profile.jobTitle ?? ""
        editCompany = profile.company ?? ""
        editSchool = profile.school ?? ""
    }
}
