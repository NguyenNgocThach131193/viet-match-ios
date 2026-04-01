import XCTest
@testable import VietMatch

@MainActor
final class ProfileViewModelTests: XCTestCase {
    var sut: ProfileViewModel!
    var mockProfileRepo: MockProfileRepository!

    // A minimal valid 1x1 red JPEG for tests that need real image data
    private var validImageData: Data {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
        let img = renderer.image { ctx in
            UIColor.red.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        return img.jpegData(compressionQuality: 0.8)!
    }

    override func setUp() {
        super.setUp()
        mockProfileRepo = MockProfileRepository()
        let getProfileUseCase = GetProfileUseCase(profileRepository: mockProfileRepo)
        let updateProfileUseCase = UpdateProfileUseCase(profileRepository: mockProfileRepo)
        let uploadPhotoUseCase = UploadPhotoUseCase(profileRepository: mockProfileRepo)
        let logoutUseCase = LogoutUseCase(authRepository: MockAuthRepository())
        sut = ProfileViewModel(
            currentUserId: "user_1",
            getProfileUseCase: getProfileUseCase,
            updateProfileUseCase: updateProfileUseCase,
            logoutUseCase: logoutUseCase,
            uploadPhotoUseCase: uploadPhotoUseCase,
            profileRepository: mockProfileRepo
        )
        sut.profile = Profile(id: "user_1", name: "Test", age: 25, bio: "Bio",
                               photos: ["https://example.com/photo1.jpg"])
    }

    override func tearDown() {
        sut = nil
        mockProfileRepo = nil
        super.tearDown()
    }

    // MARK: - loadProfile with injected userId

    func test_loadProfile_usesInjectedUserId() async {
        let expectedProfile = Profile(id: "user_1", name: "Test", age: 25, bio: "Bio")
        mockProfileRepo.getProfileResult = .success(expectedProfile)

        await sut.loadProfile()

        XCTAssertEqual(mockProfileRepo.getProfileCallCount, 1)
        XCTAssertEqual(sut.profile?.id, "user_1")
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - addPhoto

    func test_addPhoto_success_appendsPhotoURL() async {
        mockProfileRepo.uploadPhotoResult = .success("https://example.com/photo2.jpg")

        await sut.addPhoto(data: validImageData)

        XCTAssertEqual(sut.profile?.photos.count, 2)
        XCTAssertEqual(sut.profile?.photos.last, "https://example.com/photo2.jpg")
        XCTAssertFalse(sut.isUploadingPhoto)
    }

    func test_addPhoto_setsIsUploadingPhotoToFalseAfterCompletion() async {
        mockProfileRepo.uploadPhotoResult = .success("https://example.com/photo2.jpg")

        await sut.addPhoto(data: validImageData)

        XCTAssertFalse(sut.isUploadingPhoto)
    }

    func test_addPhoto_invalidImageData_setsErrorMessage() async {
        await sut.addPhoto(data: Data())

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(sut.profile?.photos.count, 1)
        XCTAssertFalse(sut.isUploadingPhoto)
    }

    func test_addPhoto_uploadFailure_setsErrorMessage() async {
        mockProfileRepo.uploadPhotoResult = .failure(NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Upload failed"]))

        await sut.addPhoto(data: validImageData)

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(sut.profile?.photos.count, 1)
        XCTAssertFalse(sut.isUploadingPhoto)
    }

    func test_addPhoto_whenMaxPhotosReached_doesNotUpload() async {
        sut.profile?.photos = ["url1", "url2", "url3", "url4", "url5", "url6"]

        await sut.addPhoto(data: validImageData)

        XCTAssertEqual(mockProfileRepo.uploadPhotoCallCount, 0)
        XCTAssertEqual(sut.profile?.photos.count, 6)
    }

    // MARK: - removePhoto

    func test_removePhoto_success_removesPhotoFromArray() async {
        sut.profile?.photos = ["https://example.com/photo1.jpg", "https://example.com/photo2.jpg"]

        await sut.removePhoto(url: "https://example.com/photo1.jpg")

        XCTAssertEqual(sut.profile?.photos.count, 1)
        XCTAssertEqual(sut.profile?.photos.first, "https://example.com/photo2.jpg")
        XCTAssertEqual(mockProfileRepo.deletePhotoCallCount, 1)
    }

    func test_removePhoto_whenOnlyOnePhoto_doesNotRemove() async {
        XCTAssertEqual(sut.profile?.photos.count, 1)

        await sut.removePhoto(url: "https://example.com/photo1.jpg")

        XCTAssertEqual(sut.profile?.photos.count, 1)
        XCTAssertEqual(mockProfileRepo.deletePhotoCallCount, 0)
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_removePhoto_failure_setsErrorMessage() async {
        sut.profile?.photos = ["https://example.com/photo1.jpg", "https://example.com/photo2.jpg"]
        mockProfileRepo.deletePhotoResult = .failure(NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Delete failed"]))

        await sut.removePhoto(url: "https://example.com/photo1.jpg")

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(sut.profile?.photos.count, 2)
        XCTAssertFalse(sut.isDeletingPhoto)
    }
}
