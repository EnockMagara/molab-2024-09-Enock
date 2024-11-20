import SwiftUI
import MapKit

class AppModel: ObservableObject {
    @Published var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Example coordinates
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @Published var locations: [Location] = [
        Location(name: "Golden Gate Bridge", coordinate: CLLocationCoordinate2D(latitude: 37.8199, longitude: -122.4783)),
        Location(name: "Alcatraz Island", coordinate: CLLocationCoordinate2D(latitude: 37.8267, longitude: -122.4230))
    ] // Sample locations
    
    @Published var selectedPlace: Location? // Optional to store selected location

    // Method to remove a location
    func removeLocation(at offsets: IndexSet) {
        locations.remove(atOffsets: offsets)
    }

    // Method to add a new location
    func addLocation(name: String, coordinate: CLLocationCoordinate2D, note: String?, image: UIImage?) {
        let newLocation = Location(name: name, coordinate: coordinate, note: note, image: image)
        locations.append(newLocation) // Add the new location to the list
    }
}

// Example Location struct
struct Location: Identifiable {
    let id = UUID() // Unique identifier
    let name: String // Name of the location
    let coordinate: CLLocationCoordinate2D // Coordinate of the location
    var note: String? // Optional note for the location
    var image: UIImage? // Optional image for the location
}

