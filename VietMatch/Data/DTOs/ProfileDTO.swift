import Foundation

struct ProfileDTO: Codable {
    let id: String
    let name: String
    let age: Int
    let bio: String
    let gender: String
    let interestedIn: String
    let photos: [String]
    let latitude: Double?
    let longitude: Double?
    let city: String?
    let interests: [String]
    let jobTitle: String?
    let company: String?
    let school: String?
    let distancePreference: Int
    let ageRangeMin: Int
    let ageRangeMax: Int

    enum CodingKeys: String, CodingKey {
        case id, name, age, bio, gender, photos, interests, city
        case interestedIn = "interested_in"
        case latitude, longitude
        case jobTitle = "job_title"
        case company, school
        case distancePreference = "distance_preference"
        case ageRangeMin = "age_range_min"
        case ageRangeMax = "age_range_max"
    }

    func toDomain() -> Profile {
        let location: Location? = if let latitude, let longitude {
            Location(latitude: latitude, longitude: longitude, city: city)
        } else {
            nil
        }

        return Profile(
            id: id,
            name: name,
            age: age,
            bio: bio,
            gender: Gender(rawValue: gender) ?? .other,
            interestedIn: Gender(rawValue: interestedIn) ?? .other,
            photos: photos,
            location: location,
            interests: interests,
            jobTitle: jobTitle,
            company: company,
            school: school,
            distancePreference: distancePreference,
            ageRangeMin: ageRangeMin,
            ageRangeMax: ageRangeMax
        )
    }

    static func from(domain: Profile) -> ProfileDTO {
        ProfileDTO(
            id: domain.id,
            name: domain.name,
            age: domain.age,
            bio: domain.bio,
            gender: domain.gender.rawValue,
            interestedIn: domain.interestedIn.rawValue,
            photos: domain.photos,
            latitude: domain.location?.latitude,
            longitude: domain.location?.longitude,
            city: domain.location?.city,
            interests: domain.interests,
            jobTitle: domain.jobTitle,
            company: domain.company,
            school: domain.school,
            distancePreference: domain.distancePreference,
            ageRangeMin: domain.ageRangeMin,
            ageRangeMax: domain.ageRangeMax
        )
    }
}
