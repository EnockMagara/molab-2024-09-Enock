import SwiftUI
import MapKit
import CoreLocation

class AppModel: ObservableObject {
    @Published var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @Published var locations: [Location] = []
    
    @Published var selectedPlace: Location?
    @Published var showingProfile: Bool = false
    @Published var events: [Event] = []
    @Published var showingMapSelection: Bool = false
    @Published var starredLocations: [StarredLocation] = []

    func addLocation(name: String, coordinate: CLLocationCoordinate2D, note: String?, image: UIImage?) {
        let newLocation = Location(id: UUID(), name: name, description: note ?? "", latitude: coordinate.latitude, longitude: coordinate.longitude)
        locations.append(newLocation)
    }

    func addEvent(name: String, description: String, date: Date, address: String) {
        let newEvent = Event(name: name, description: description, date: date, address: address)
        events.append(newEvent)
    }

    func removeLocation(at offsets: IndexSet) {
        locations.remove(atOffsets: offsets)
    }

    func starLocation(latitude: Double, longitude: Double, tag: String, description: String?, imageData: Data?) {
        getAddressFromCoordinates(latitude: latitude, longitude: longitude) { [weak self] address in
            guard let self = self else { return }
            
            let addressString = address ?? "Unknown Address"
            let newStarredLocation = StarredLocation(
                id: UUID(),
                latitude: latitude,
                longitude: longitude,
                tag: tag + " - " + addressString,
                description: description,
                imageData: imageData
            )
            self.starredLocations.append(newStarredLocation)
        }
    }

    private func getAddressFromCoordinates(latitude: Double, longitude: Double, completion: @escaping (String?) -> Void) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Error in reverse geocoding: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let placemark = placemarks?.first {
                var addressString = ""
                
                if let name = placemark.name {
                    addressString += name + ", "
                }
                if let locality = placemark.locality {
                    addressString += locality + ", "
                }
                if let administrativeArea = placemark.administrativeArea {
                    addressString += administrativeArea + ", "
                }
                if let country = placemark.country {
                    addressString += country
                }
                
                completion(addressString)
            } else {
                completion(nil)
            }
        }
    }
}


// Example Location struct
struct Location: Codable, Equatable, Identifiable {
    let id: UUID
    var name: String
    var description: String?
    var latitude: Double
    var longitude: Double
    var imageData: Data?
}

// Example Event struct
struct Event: Identifiable {
    let id = UUID() // Unique identifier
    let name: String // Name of the event
    let description: String // Description of the event
    let date: Date // Date of the event
    let address: String // Address of the event
}

// Define a struct for starred locations
struct StarredLocation: Identifiable {
    let id: UUID
    let latitude: Double
    let longitude: Double
    let tag: String
    let description: String?
    let imageData: Data?
}

