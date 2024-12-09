//AppModel.swift

import SwiftUI
import MapKit
import CoreLocation
import FirebaseFirestore
import FirebaseStorage
import UIKit

func saveImageLocally(image: UIImage, fileName: String) -> URL? {
    guard let data = image.jpegData(compressionQuality: 1.0) else { return nil }
    let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    
    do {
        try data.write(to: fileURL)
        return fileURL
    } catch {
        print("Error saving image: \(error.localizedDescription)")
        return nil
    }
}

class AppModel: ObservableObject {
    // Firestore instance
    private let db = Firestore.firestore()
    
    @Published var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.6931, longitude: -73.9856),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @Published var locations: [Location] = []
    @Published var selectedPlace: Location?
    @Published var showingProfile: Bool = false
    @Published var events: [Event] = []
    @Published var showingMapSelection: Bool = false
    @Published var starredLocations: [StarredLocation] = []

    init() {
        fetchStarredLocations() // Fetch data on initialization
    }

    // Function to fetch starred locations from Firestore
    func fetchStarredLocations() {
        db.collection("starredLocations").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }
            
            self?.starredLocations = snapshot?.documents.compactMap { document in
                let data = document.data()
                guard let latitude = data["latitude"] as? Double,
                      let longitude = data["longitude"] as? Double,
                      let tag = data["tag"] as? String,
                      let address = data["address"] as? String else {
                    return nil
                }
                
                let description = data["description"] as? String
                let imageURL = data["imageURL"] as? String
                
                return StarredLocation(
                    id: UUID(),
                    latitude: latitude,
                    longitude: longitude,
                    tag: tag,
                    address: address,
                    description: description,
                    imageURL: imageURL
                )
            } ?? []
        }
    }

    // Function to upload image to Firebase Storage
    func uploadImageToStorage(imageData: Data, format: String, completion: @escaping (Result<String, Error>) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("images/\(UUID().uuidString).\(format)")
        
        print("Starting image upload...")

        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Upload error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            print("Image uploaded successfully. Fetching download URL...")

            imageRef.downloadURL { url, error in
                if let error = error {
                    print("URL error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                if let url = url {
                    print("Image URL: \(url.absoluteString)")
                    completion(.success(url.absoluteString))
                }
            }
        }
    }

    // Function to add a location
    func addLocation(name: String, coordinate: CLLocationCoordinate2D, note: String?, image: UIImage?) {
        let newLocation = Location(id: UUID(), name: name, description: note ?? "", latitude: coordinate.latitude, longitude: coordinate.longitude)
        locations.append(newLocation)
    }

    // Function to add an event
    func addEvent(name: String, description: String, date: Date, address: String) {
        let newEvent = Event(name: name, description: description, date: date, address: address)
        events.append(newEvent)
    }

    // Function to remove a location
    func removeLocation(at offsets: IndexSet) {
        locations.remove(atOffsets: offsets)
    }

    // Function to star a location
    func starLocation(latitude: Double, longitude: Double, tag: String, description: String?, imageData: Data?) {
        getAddressFromCoordinates(latitude: latitude, longitude: longitude) { [weak self] address in
            guard let self = self else { return }
            
            let addressString = address ?? "Unknown Address"
            
            if let imageData = imageData {
                self.uploadImageToStorage(imageData: imageData, format: "jpg") { result in
                    switch result {
                    case .success(let url):
                        let newStarredLocation = StarredLocation(
                            id: UUID(),
                            latitude: latitude,
                            longitude: longitude,
                            tag: tag,
                            address: addressString,
                            description: description,
                            imageURL: nil // Do not store image data
                        )
                        self.saveStarredLocation(location: newStarredLocation, imageURL: url)
                    case .failure(let error):
                        print("Error uploading image: \(error.localizedDescription)")
                    }
                }
            } else {
                let newStarredLocation = StarredLocation(
                    id: UUID(),
                    latitude: latitude,
                    longitude: longitude,
                    tag: tag,
                    address: addressString,
                    description: description,
                    imageURL: nil
                )
                self.saveStarredLocation(location: newStarredLocation, imageURL: nil)
            }
        }
    }

    // Function to save a starred location to Firestore
    private func saveStarredLocation(location: StarredLocation, imageURL: String?) {
        var locationData: [String: Any] = [
            "latitude": location.latitude,
            "longitude": location.longitude,
            "tag": location.tag,
            "address": location.address,
            "description": location.description ?? ""
        ]
        
        if let imageURL = imageURL {
            locationData["imageURL"] = imageURL
        }
        
        db.collection("starredLocations").addDocument(data: locationData) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully")
            }
        }
    }

    // Function to get address from coordinates
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

    // Function to handle image upload
    func handleImageUpload(imageData: Data) {
        let format = determineImageFormat(imageData: imageData)

        uploadImageToStorage(imageData: imageData, format: format) { result in
            switch result {
            case .success(let url):
                self.saveImageURLToFirestore(url: url) { result in
                    switch result {
                    case .success:
                        print("Image URL stored in Firestore.")
                    case .failure(let error):
                        print("Error saving image URL to Firestore: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print("Error uploading image: \(error.localizedDescription)")
            }
        }
    }

    // Helper function to determine image format
    private func determineImageFormat(imageData: Data) -> String {
        if let image = UIImage(data: imageData), let cgImage = image.cgImage {
            switch cgImage.alphaInfo {
            case .none, .noneSkipLast, .noneSkipFirst:
                return "jpg"
            default:
                return "png"
            }
        }
        return "jpg"
    }

    // Function to save image URL to Firestore
    func saveImageURLToFirestore(url: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let documentData: [String: Any] = [
            "imageURL": url,
            "timestamp": Timestamp(date: Date())
        ]

        print("Saving image URL to Firestore...")

        db.collection("images").addDocument(data: documentData) { error in
            if let error = error {
                print("Error saving image URL to Firestore: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("Image URL stored in Firestore successfully.")
                completion(.success(()))
            }
        }
    }
}



struct Location: Codable, Equatable, Identifiable {
    let id: UUID
    var name: String
    var description: String?
    var latitude: Double
    var longitude: Double
    var imageData: Data?
}


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
    let address: String
    let description: String?
    let imageURL: String?
}

