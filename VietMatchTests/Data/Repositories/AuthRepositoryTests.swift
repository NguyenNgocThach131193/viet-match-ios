import XCTest
@testable import VietMatch

final class AuthRepositoryTests: XCTestCase {

    func test_userDTO_toDomain_mapsCorrectly() {
        let dto = UserDTO(
            id: "1",
            email: "test@test.com",
            displayName: "Test User",
            profileCompleted: true,
            createdAt: 1700000000,
            lastActiveAt: 1700000000
        )

        let user = dto.toDomain()

        XCTAssertEqual(user.id, "1")
        XCTAssertEqual(user.email, "test@test.com")
        XCTAssertEqual(user.displayName, "Test User")
        XCTAssertTrue(user.profileCompleted)
    }

    func test_userDTO_fromDomain_mapsCorrectly() {
        let user = User(
            id: "1",
            email: "test@test.com",
            displayName: "Test User",
            profileCompleted: false
        )

        let dto = UserDTO.from(domain: user)

        XCTAssertEqual(dto.id, "1")
        XCTAssertEqual(dto.email, "test@test.com")
        XCTAssertEqual(dto.displayName, "Test User")
        XCTAssertFalse(dto.profileCompleted)
    }

    func test_profileDTO_toDomain_mapsLocation() {
        let dto = ProfileDTO(
            id: "1",
            name: "Test",
            age: 25,
            bio: "Bio",
            gender: "male",
            interestedIn: "female",
            photos: ["photo1.jpg"],
            latitude: 10.8231,
            longitude: 106.6297,
            city: "Ho Chi Minh",
            interests: ["Travel"],
            jobTitle: "Dev",
            company: nil,
            school: nil,
            distancePreference: 50,
            ageRangeMin: 18,
            ageRangeMax: 30
        )

        let profile = dto.toDomain()

        XCTAssertEqual(profile.name, "Test")
        XCTAssertEqual(profile.location?.city, "Ho Chi Minh")
        XCTAssertEqual(profile.gender, .male)
        XCTAssertEqual(profile.interestedIn, .female)
    }
}
