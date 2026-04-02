import Foundation
import Combine
import UserNotifications

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var showLogoutConfirmation = false
    @Published var showDeleteConfirmation = false
    @Published var distancePreference: Double = 50
    @Published var ageRangeMin: Double = 18
    @Published var ageRangeMax: Double = 50
    @Published var notificationsEnabled = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let logoutUseCase: LogoutUseCaseProtocol
    private let deleteAccountUseCase: DeleteAccountUseCaseProtocol
    private let getProfileUseCase: GetProfileUseCaseProtocol
    private let updateProfileUseCase: UpdateProfileUseCaseProtocol
    private let fcmService: FCMServiceProtocol
    private let firestoreService: FirestoreServiceProtocol
    private let currentUserId: String
    private var cancellables = Set<AnyCancellable>()
    private var currentProfile: Profile?

    init(
        currentUserId: String,
        logoutUseCase: LogoutUseCaseProtocol,
        deleteAccountUseCase: DeleteAccountUseCaseProtocol,
        getProfileUseCase: GetProfileUseCaseProtocol,
        updateProfileUseCase: UpdateProfileUseCaseProtocol,
        fcmService: FCMServiceProtocol,
        firestoreService: FirestoreServiceProtocol
    ) {
        self.currentUserId = currentUserId
        self.logoutUseCase = logoutUseCase
        self.deleteAccountUseCase = deleteAccountUseCase
        self.getProfileUseCase = getProfileUseCase
        self.updateProfileUseCase = updateProfileUseCase
        self.fcmService = fcmService
        self.firestoreService = firestoreService

        setupPreferenceSaving()
    }

    func loadPreferences() async {
        guard !currentUserId.isEmpty else { return }
        async let profileLoad: Void = loadProfile()
        async let notifLoad: Void = loadNotificationState()
        _ = await (profileLoad, notifLoad)
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

    func deleteAccount() async {
        isLoading = true
        do {
            try await deleteAccountUseCase.execute(userId: currentUserId)
        } catch {
            errorMessage = "Xóa tài khoản thất bại. Vui lòng thử lại."
            AppLogger.general.error("deleteAccount failed: \(error.localizedDescription)")
        }
        isLoading = false
    }

    func toggleNotifications(enabled: Bool) async {
        guard !currentUserId.isEmpty else { return }
        if enabled {
            do {
                let granted = try await fcmService.requestPermission()
                guard granted else {
                    notificationsEnabled = false
                    return
                }
                let token = try await fcmService.getFCMToken()
                try await firestoreService.updateDocument(
                    collection: "users",
                    documentId: currentUserId,
                    fields: ["fcmToken": token]
                )
                notificationsEnabled = true
                AppLogger.general.info("FCM token saved for user \(self.currentUserId)")
            } catch {
                notificationsEnabled = false
                AppLogger.general.error("Failed to enable notifications: \(error.localizedDescription)")
            }
        } else {
            do {
                try await firestoreService.updateDocument(
                    collection: "users",
                    documentId: currentUserId,
                    fields: ["fcmToken": ""]
                )
                AppLogger.general.info("FCM token cleared for user \(self.currentUserId)")
            } catch {
                AppLogger.general.error("Failed to clear FCM token: \(error.localizedDescription)")
            }
            notificationsEnabled = false
        }
    }

    // MARK: - Private

    private func loadProfile() async {
        do {
            let profile = try await getProfileUseCase.execute(userId: currentUserId)
            currentProfile = profile
            distancePreference = Double(profile.distancePreference)
            ageRangeMin = Double(profile.ageRangeMin)
            ageRangeMax = Double(profile.ageRangeMax)
        } catch {
            AppLogger.general.warning("Settings: failed to load profile — \(error.localizedDescription)")
        }
    }

    private func loadNotificationState() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        notificationsEnabled = settings.authorizationStatus == .authorized
    }

    private func setupPreferenceSaving() {
        Publishers.CombineLatest3($distancePreference, $ageRangeMin, $ageRangeMax)
            .dropFirst()
            .debounce(for: .seconds(0.8), scheduler: RunLoop.main)
            .sink { [weak self] _, _, _ in
                Task { await self?.savePreferences() }
            }
            .store(in: &cancellables)
    }

    private func savePreferences() async {
        guard var profile = currentProfile else { return }
        profile.distancePreference = Int(distancePreference)
        profile.ageRangeMin = Int(ageRangeMin)
        profile.ageRangeMax = Int(ageRangeMax)
        do {
            currentProfile = try await updateProfileUseCase.execute(profile)
        } catch {
            AppLogger.general.error("Settings: failed to save preferences — \(error.localizedDescription)")
        }
    }
}
