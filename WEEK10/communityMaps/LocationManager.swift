import Foundation
import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    private var locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self // Set the delegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // Set desired accuracy
        locationManager.requestWhenInUseAuthorization() // Request location access
        locationManager.startUpdatingLocation() // Start updating location
    }

    // CLLocationManagerDelegate method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return } // Get the last location
        region.center = location.coordinate // Update the region's center
    }

    func centerUserLocation() {
        if let location = locationManager.location {
            region.center = location.coordinate // Center the map on the user's location
        }
    }
} 