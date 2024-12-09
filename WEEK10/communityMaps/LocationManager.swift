import Foundation
import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    private var locationManager = CLLocationManager()
    private var lastLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        print("LocationManager initialized")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("Received location update: \(location.coordinate)")
        
        // Check if the new location is significantly different from the last location
        if let lastLocation = lastLocation {
            let distance = location.distance(from: lastLocation)
            if distance > 50 { // Adjust the distance threshold as needed
                region.center = location.coordinate
                print("Map region updated to: \(region.center)")
            }
        } else {
            region.center = location.coordinate
            print("Map region updated to: \(region.center)")
        }
        
        lastLocation = location
    }

    func centerUserLocation() {
        if let location = locationManager.location {
            print("Centering map to user location: \(location.coordinate)")
            region.center = location.coordinate
        }
    }
} 