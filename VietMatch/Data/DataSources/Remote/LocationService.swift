import Foundation
import CoreLocation

protocol LocationServiceProtocol {
    func requestPermission()
    func startUpdating(userId: String)
    func stopUpdating()
}

final class LocationService: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let profileRepository: ProfileRepositoryProtocol
    private var currentUserId: String?
    private var lastUpdatedLocation: CLLocation?
    private let minimumDistanceChange: CLLocationDistance = 500 // metres

    init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdating(userId: String) {
        currentUserId = userId
        let status = locationManager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }

    func stopUpdating() {
        currentUserId = nil
        locationManager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last, let userId = currentUserId else { return }

        if let last = lastUpdatedLocation,
           newLocation.distance(from: last) < minimumDistanceChange { return }

        lastUpdatedLocation = newLocation
        reverseGeocode(location: newLocation, userId: userId)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if (status == .authorizedWhenInUse || status == .authorizedAlways), let userId = currentUserId {
            manager.startUpdatingLocation()
            AppLogger.general.info("Location: permission granted, starting updates for user \(userId)")
        }
    }

    // MARK: - Private

    private func reverseGeocode(location: CLLocation, userId: String) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self else { return }
            let city = placemarks?.first?.locality ?? placemarks?.first?.administrativeArea
            let domainLocation = Location(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                city: city
            )
            Task {
                do {
                    try await self.profileRepository.updateLocation(userId: userId, location: domainLocation)
                } catch {
                    AppLogger.general.warning("Location: failed to update — \(error.localizedDescription)")
                }
            }
        }
    }
}
