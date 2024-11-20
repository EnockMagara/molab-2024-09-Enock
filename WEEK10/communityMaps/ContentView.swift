import SwiftUI
import PhotosUI
import CoreLocation
import MapKit

struct MainView: View {
    @StateObject private var appModel = AppModel() // Initialize the app model

    var body: some View {
        VStack {
            // Main content area
            TabView {
                MapView() // First tab for Maps
                    .tabItem {
                        Label("Maps", systemImage: "map") // Tab label and icon
                    }
                
                ProfileView() // Second tab for Profile
                    .tabItem {
                        Label("Profile", systemImage: "person") // Tab label and icon
                    }
                
                EventsView() // Third tab for Events
                    .tabItem {
                        Label("Events", systemImage: "calendar") // Tab label and icon
                    }
                
                StarredListView() // Fourth tab for Starred List
                    .tabItem {
                        Label("Starred", systemImage: "star") // Tab label and icon
                    }
            }
            .environmentObject(appModel) // Provide the app model to subviews
            .frame(maxHeight: .infinity) // Allow TabView to take available space

            // Navigation bar
            HStack {
                Spacer()
                Button(action: {
                    // Action for Maps
                }) {
                    Label("Maps", systemImage: "map")
                }
                Spacer()
                Button(action: {
                    // Action for Events
                }) {
                    Label("Events", systemImage: "calendar")
                }
                Spacer()
                Button(action: {
                    // Action for Profile
                }) {
                    Label("Profile", systemImage: "person")
                }
                Spacer()
                Button(action: {
                    // Action for Starred List
                }) {
                    Label("Starred", systemImage: "star")
                }
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6)) // Background color for the nav bar
        }
    }
}

// Placeholder views for Profile, Events, and Starred List
struct ProfileView: View {
    var body: some View {
        Text("Profile View") // Display text for Profile
    }
}

struct EventsView: View {
    var body: some View {
        Text("Events View") // Display text for Events
    }
}

struct StarredListView: View {
    var body: some View {
        Text("Starred List View") // Display text for Starred List
    }
}

struct MapView: View {
    @EnvironmentObject var appModel: AppModel // Access the app model
    @State private var showingInput = false // State to show input prompt
    @State private var newLocationName = "" // State for new location name
    @State private var newLocationNote = "" // State for new location note
    @State private var newCoordinate = CLLocationCoordinate2D() // State for new location coordinate
    @State private var selectedPhotoItem: PhotosPickerItem? // State for selected photo item
    @State private var newImage: UIImage? // State for new location image
    @State private var showingDetail = false // State to show detail view

    var body: some View {
        Map(coordinateRegion: $appModel.mapRegion, annotationItems: appModel.locations) { location in
            MapAnnotation(coordinate: location.coordinate) {
                VStack {
                    if let image = location.image {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                            .onTapGesture {
                                appModel.selectedPlace = location
                                showingDetail = true // Show detail view
                            }
                    } else {
                        Image(systemName: "star.circle")
                            .resizable()
                            .foregroundColor(.red)
                            .frame(width: 44, height: 44)
                            .background(.white)
                            .clipShape(Circle())
                            .onTapGesture {
                                appModel.selectedPlace = location
                                showingDetail = true // Show detail view
                            }
                    }
                    Text(location.name)
                        .fixedSize()
                }
            }
        }
        .ignoresSafeArea() // Extend map to safe area
        .gesture(
            TapGesture().onEnded { _ in
                newCoordinate = appModel.mapRegion.center // Store the coordinate
                reverseGeocode(coordinate: newCoordinate) // Perform reverse geocoding
                showingInput = true // Show the input prompt
            }
        )
        .sheet(isPresented: $showingInput) {
            VStack {
                TextField("Location Name", text: $newLocationName) // Input for location name
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                TextField("Note", text: $newLocationNote) // Input for location note
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Text("Select Image") // Button to select image
                }
                .onChange(of: selectedPhotoItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            newImage = uiImage // Convert to UIImage
                        } else {
                            print("Failed to load image")
                        }
                    }
                }
                .padding()
                Button("Add Location") {
                    appModel.addLocation(name: newLocationName, coordinate: newCoordinate, note: newLocationNote, image: newImage)
                    showingInput = false // Dismiss the input prompt
                    newImage = nil
                    newLocationName = ""
                    newLocationNote = ""
                }
                .padding()
            }
            .padding()
        }
        .sheet(isPresented: $showingDetail) {
            if let selectedPlace = appModel.selectedPlace {
                VStack {
                    if let image = selectedPlace.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    }
                    Text(selectedPlace.name)
                        .font(.title)
                        .padding()
                    if let note = selectedPlace.note {
                        Text(note)
                            .padding()
                    }
                }
                .padding()
            }
        }
    }

    private func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                newLocationName = placemark.name ?? "Unknown Location"
            } else {
                newLocationName = "Unknown Location"
            }
        }
    }
}

struct ListView: View {
    @EnvironmentObject var appModel: AppModel // Access the app model
    @Binding var isListView: Bool // Binding to toggle state

    var body: some View {
        List {
            ForEach(appModel.locations) { location in
                VStack(alignment: .leading) {
                    Text(location.name) // Display location name
                    if let note = location.note {
                        Text(note) // Display location note if available
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .onTapGesture {
                    appModel.selectedPlace = location // Set selected place on tap
                    appModel.mapRegion.center = location.coordinate // Center map on location
                    isListView = false // Switch to map view
                }
            }
            .onDelete { indices in
                appModel.removeLocation(at: indices) // Remove location on delete
            }
        }
    }
}

struct ToggleViewButton: View {
    @Binding var isListView: Bool // Binding to toggle state

    var body: some View {
        Button(action: {
            isListView.toggle() // Toggle between map and list views
        }) {
            Text(isListView ? "Show Map" : "Show List") // Change button text
                .padding()
                .background(.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
    }
}
