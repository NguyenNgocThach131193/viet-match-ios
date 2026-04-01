import Foundation
import UIKit

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profile: Profile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isEditing = false
    @Published var isUploadingPhoto = false
    @Published var isDeletingPhoto = false

    // Editable fields
    @Published var editName = ""
    @Published var editBio = ""
    @Published var editJobTitle = ""
    @Published var editCompany = ""
    @Published var editSchool = ""

    private let getProfileUseCase: GetProfileUseCaseProtocol
    private let updateProfileUseCase: UpdateProfileUseCaseProtocol
    private let logoutUseCase: LogoutUseCaseProtocol
    private let uploadPhotoUseCase: UploadPhotoUseCaseProtocol
    private let deletePhotoUseCase: DeletePhotoUseCaseProtocol
    private let currentUserId: String

    init(
        currentUserId: String,
        getProfileUseCase: GetProfileUseCaseProtocol,
        updateProfileUseCase: UpdateProfileUseCaseProtocol,
        logoutUseCase: LogoutUseCaseProtocol,
        uploadPhotoUseCase: UploadPhotoUseCaseProtocol,
        deletePhotoUseCase: DeletePhotoUseCaseProtocol
    ) {
        self.currentUserId = currentUserId
        self.getProfileUseCase = getProfileUseCase
        self.updateProfileUseCase = updateProfileUseCase
        self.logoutUseCase = logoutUseCase
        self.uploadPhotoUseCase = uploadPhotoUseCase
        self.deletePhotoUseCase = deletePhotoUseCase
    }

    func loadProfile() async {
        isLoading = true
        do {
            profile = try await getProfileUseCase.execute(userId: currentUserId)
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

    func addPhoto(data: Data) async {
        guard !isUploadingPhoto, let profile, profile.photos.count < Constants.App.maxPhotos else { return }
        isUploadingPhoto = true
        defer { isUploadingPhoto = false }
        do {
            guard let image = UIImage(data: data),
                  let compressedData = image.jpegData(compressionQuality: 0.8) else {
                errorMessage = "Không thể xử lý ảnh này"
                return
            }
            let url = try await uploadPhotoUseCase.execute(userId: currentUserId, imageData: compressedData)
            self.profile?.photos.append(url)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func removePhoto(url: String) async {
        guard !isDeletingPhoto else { return }
        guard let profile, profile.photos.count > 1 else {
            errorMessage = "Phải có ít nhất 1 ảnh"
            return
        }
        isDeletingPhoto = true
        defer { isDeletingPhoto = false }
        do {
            try await deletePhotoUseCase.execute(userId: currentUserId, photoURL: url)
            self.profile?.photos.removeAll { $0 == url }
        } catch {
            errorMessage = error.localizedDescription
        }
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
