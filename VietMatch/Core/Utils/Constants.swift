import Foundation

enum Constants {
    enum Firebase {
        static let usersCollection = "users"
        static let profilesCollection = "profiles"
        static let matchesCollection = "matches"
        static let swipesCollection = "swipes"
        static let messagesSubcollection = "messages"
    }

    enum App {
        static let appName = "VietMatch"
        static let maxPhotos = 6
        static let minAge = 18
        static let maxAge = 100
        static let defaultDiscoverLimit = 20
        static let maxBioLength = 500
        static let defaultDistance = 50
        static let maxDistance = 160
    }

    enum StoragePath {
        static let photos = "photos"
        static let profilePhotos = "profile_photos"
    }
}
