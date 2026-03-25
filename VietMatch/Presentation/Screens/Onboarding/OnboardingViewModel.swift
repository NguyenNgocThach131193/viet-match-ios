import Foundation
import SwiftUI

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentStep = 0
    @Published var name = ""
    @Published var age = 25
    @Published var bio = ""
    @Published var gender: Gender = .other
    @Published var interestedIn: Gender = .other
    @Published var selectedPhotos: [Data] = []
    @Published var interests: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let updateProfileUseCase: UpdateProfileUseCaseProtocol
    private let uploadPhotoUseCase: UploadPhotoUseCaseProtocol

    let totalSteps = 4
    let availableInterests = [
        "Du lịch", "Âm nhạc", "Phim ảnh", "Thể thao", "Nấu ăn",
        "Đọc sách", "Gaming", "Nhiếp ảnh", "Yoga", "Cafe",
        "Thú cưng", "Nghệ thuật", "Công nghệ", "Thời trang", "Fitness"
    ]

    init(
        updateProfileUseCase: UpdateProfileUseCaseProtocol,
        uploadPhotoUseCase: UploadPhotoUseCaseProtocol
    ) {
        self.updateProfileUseCase = updateProfileUseCase
        self.uploadPhotoUseCase = uploadPhotoUseCase
    }

    var canProceed: Bool {
        switch currentStep {
        case 0: return !name.trimmed.isEmpty && age >= 18
        case 1: return gender != .other
        case 2: return !selectedPhotos.isEmpty
        case 3: return true
        default: return false
        }
    }

    func nextStep() {
        if currentStep < totalSteps - 1 {
            currentStep += 1
        }
    }

    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }

    func toggleInterest(_ interest: String) {
        if interests.contains(interest) {
            interests.removeAll { $0 == interest }
        } else {
            interests.append(interest)
        }
    }

    func completeOnboarding(userId: String) async throws {
        isLoading = true
        defer { isLoading = false }

        var photoURLs: [String] = []
        for photoData in selectedPhotos {
            let url = try await uploadPhotoUseCase.execute(userId: userId, imageData: photoData)
            photoURLs.append(url)
        }

        let profile = Profile(
            id: userId,
            name: name.trimmed,
            age: age,
            bio: bio.trimmed,
            gender: gender,
            interestedIn: interestedIn,
            photos: photoURLs,
            interests: interests
        )

        _ = try await updateProfileUseCase.execute(profile)
        AppLogger.general.info("Onboarding completed for user: \(userId)")
    }
}
