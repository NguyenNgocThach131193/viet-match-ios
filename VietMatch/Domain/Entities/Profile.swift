import Foundation

struct Profile: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var age: Int
    var bio: String
    var gender: Gender
    var interestedIn: Gender
    var photos: [String]
    var location: Location?
    var interests: [String]
    var jobTitle: String?
    var company: String?
    var school: String?
    var distancePreference: Int // in km
    var ageRangeMin: Int
    var ageRangeMax: Int

    init(
        id: String,
        name: String = "",
        age: Int = 18,
        bio: String = "",
        gender: Gender = .other,
        interestedIn: Gender = .other,
        photos: [String] = [],
        location: Location? = nil,
        interests: [String] = [],
        jobTitle: String? = nil,
        company: String? = nil,
        school: String? = nil,
        distancePreference: Int = 50,
        ageRangeMin: Int = 18,
        ageRangeMax: Int = 50
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.bio = bio
        self.gender = gender
        self.interestedIn = interestedIn
        self.photos = photos
        self.location = location
        self.interests = interests
        self.jobTitle = jobTitle
        self.company = company
        self.school = school
        self.distancePreference = distancePreference
        self.ageRangeMin = ageRangeMin
        self.ageRangeMax = ageRangeMax
    }
}

enum Gender: String, Codable, CaseIterable {
    case male
    case female
    case other
}

struct Location: Codable, Equatable {
    let latitude: Double
    let longitude: Double
    var city: String?
}
