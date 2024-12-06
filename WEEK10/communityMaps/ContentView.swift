import SwiftUI
import PhotosUI
import CoreLocation
import MapKit

struct MainView: View {
    @StateObject private var appModel = AppModel() // Initialize the app model
    @State private var showAddEventView = false // State to control navigation
    @State private var selectedLocation: CLLocationCoordinate2D? // State for selected location
    @State private var navigateToMap = false // State to control navigation
    @State private var selectedImage: PhotosPickerItem? // State for the selected image item
    @State private var showImagePicker = false // State to control image picker
    @State private var selectedImageData: Data? // State for the selected image data
    @State private var selectedTab = 0
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                MapView(selectedLocation: $selectedLocation, navigateToMap: $navigateToMap) // Pass bindings
                    .navigationTitle("Maps") // Set the title for this tab
            }
            .tabItem {
                Image(systemName: "map")
                Text("Maps")
            }
            .tag(0)
            
            NavigationView {
                ProfileView()
                    .navigationTitle("Profile") // Set the title for this tab
            }
            .tabItem {
                Image(systemName: "person")
                Text("Profile")
            }
            .tag(1)
            
            NavigationView {
                EventsView()
                    .navigationTitle("Events") // Set the title for this tab
            }
            .tabItem {
                Image(systemName: "calendar")
                Text("Events")
            }
            .tag(2)
            
            NavigationView {
                StarredListView(selectedTab: $selectedTab, selectedLocation: $selectedLocation)
                    .navigationTitle("Starred") // Set the title for this tab
            }
            .tabItem {
                Image(systemName: "star")
                Text("Starred")
            }
            .tag(3)
        }
        .environmentObject(appModel) // Provide the app model to subviews
        .frame(maxHeight: .infinity) // Allow TabView to take available space

        Button(action: {
            shareStarredList(appModel: appModel) 
        }) {
            Text("Share Starred List")
        }
        .sheet(isPresented: $showAddEventView) {
            AddEventView()
                .environmentObject(appModel) // Inject appModel into AddEventView
        }
    }
}

// Placeholder views for Profile, Events, and Starred List
struct ProfileView: View {
    @State private var isEditing = false // State to control edit mode
    @State private var username = "John Doe" // Example username
    @State private var bio = "Loves hiking and photography." // Example bio

    var body: some View {
        VStack {
            // Profile Information
            VStack(alignment: .leading, spacing: 10) {
                Text("Username: \(username)")
                    .font(.headline)
                
                Text("Bio: \(bio)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()

            // Edit Profile Button
            Button(action: {
                isEditing.toggle() // Toggle edit mode
                print("Edit Profile button tapped") // Debug print
            }) {
                Text("Edit Profile")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .sheet(isPresented: $isEditing) {
                EditProfileView(username: $username, bio: $bio)
            }

            Spacer()
        }
        .navigationTitle("Profile")
    }
}

struct EditProfileView: View {
    @Binding var username: String // Binding to username
    @Binding var bio: String // Binding to bio

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Profile")) {
                    TextField("Username", text: $username) // Edit username
                    TextField("Bio", text: $bio) // Edit bio
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(trailing: Button("Done") {
                // Dismiss the view
                print("Done editing profile") // Debug print
            })
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

struct EventsView: View {
    @EnvironmentObject var appModel: AppModel // Access the app model

    var body: some View {
        List(appModel.events) { event in
            VStack(alignment: .leading) {
                Text(event.name) // Display event name
                    .font(.headline)
                Text(event.description) // Display event description
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Date: \(event.date, formatter: dateFormatter)") // Display event date
                    .font(.subheadline)
                Text("Address: \(event.address)") // Display event address
                    .font(.subheadline)
            }
            .padding()
        }
        .navigationTitle("Events") // Set the title for the navigation view
    }
}

// Date formatter for displaying event dates
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

struct StarredListView: View {
    @EnvironmentObject var appModel: AppModel
    @Binding var selectedTab: Int // Binding to change the tab
    @Binding var selectedLocation: CLLocationCoordinate2D? // Binding for selected location
    @State private var navigateToMap = false // State to control navigation

    var body: some View {
        List(appModel.starredLocations, id: \.id) { location in
            VStack(alignment: .leading, spacing: 10) {
                Text("Tag: \(location.tag)")
                Text("Description: \(location.description ?? "No description")")
                Text("Lat: \(location.latitude), Lon: \(location.longitude)")
                
                if let imageData = location.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .padding(.vertical, 5)
                }
                
                HStack {
                    Spacer()
                    Button(action: {
                        selectedLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                        selectedTab = 0
                        navigateToMap = true
                    }) {
                        Image(systemName: "arrow.right.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Starred Locations")
        .background(
            NavigationLink(
                destination: MapView(selectedLocation: $selectedLocation, navigateToMap: $navigateToMap),
                isActive: $navigateToMap
            ) {
                EmptyView()
            }
        )
    }
}

struct MapView: View {
    @EnvironmentObject var appModel: AppModel
    @StateObject var locationManager = LocationManager()
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @Binding var navigateToMap: Bool

    @State private var showAlert = false // State to control alert
    @State private var tag: String = "" // State for the tag
    @State private var description: String = "" // State for the description
    @State private var selectedImage: PhotosPickerItem? // State for the selected image item
    @State private var showImagePicker = false // State to control image picker
    @State private var selectedImageData: Data? // State for the selected image data

    var body: some View {
        ZStack {
            Map(coordinateRegion: $locationManager.region, annotationItems: appModel.starredLocations) { location in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)) {
                    Button(action: {
                        // Show modal with image
                    }) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                }
            }
            .onAppear {
                if let newLocation = selectedLocation {
                    locationManager.region.center = newLocation // Center map on new location
                }
            }
            .gesture(
                TapGesture()
                    .onEnded { _ in
                        let center = locationManager.region.center
                        selectedLocation = center
                        selectedImageData = nil // Reset image data
                        showAlert = true // Show alert when location is selected
                    }
            )
            .alert("Star the Location?", isPresented: $showAlert) {
                TextField("Enter a tag", text: $tag) // Input for tag
                TextField("Enter a description", text: $description) // Input for description
                Button("Star") {
                    if let location = selectedLocation {
                        appModel.starLocation(
                            latitude: location.latitude,
                            longitude: location.longitude,
                            tag: tag,
                            description: description, // Pass the description
                            imageData: selectedImageData // Pass the image data
                        )
                    }
                }
                Button(selectedImageData == nil ? "Share Image" : "Image Selected") {
                    showImagePicker = true // Show image picker
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Enter a tag and description for this location. Do you want to share an image of the location?")
            }
            .sheet(isPresented: $showImagePicker, onDismiss: {
                showAlert = true // Reopen the alert after image picker is dismissed
            }) {
                PhotosPicker(selection: $selectedImage, matching: .images) {
                    Text("Select an Image")
                }
                .onChange(of: selectedImage) { newItem in
                    if let newItem = newItem {
                        Task {
                            if let data = try? await newItem.loadTransferable(type: Data.self) {
                                selectedImageData = data // Store the image data
                                showImagePicker = false // Close the image picker
                            }
                        }
                    }
                }
            }
        }
    }

    func centerUserLocationAction() {
        withAnimation {
            locationManager.centerUserLocation()
        }
    }

    func getAddressFromCoordinates(latitude: Double, longitude: Double, completion: @escaping (String?) -> Void) {
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

struct ListView: View {
    @EnvironmentObject var appModel: AppModel // Access the app model
    @Binding var isListView: Bool // Binding to toggle state

    var body: some View {
        List {
            ForEach(appModel.locations.indices, id: \.self) { index in
                VStack(alignment: .leading) {
                    Text(appModel.locations[index].name) // Display location name
                    if let note = appModel.locations[index].description {
                        Text(note) // Display location note if available
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .onTapGesture {
                    appModel.selectedPlace = appModel.locations[index] // Set selected place on tap
                    appModel.mapRegion.center = CLLocationCoordinate2D(
                        latitude: appModel.locations[index].latitude,
                        longitude: appModel.locations[index].longitude
                    ) // Center map on location
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

struct AddEventView: View {
    @EnvironmentObject var appModel: AppModel
    @Environment(\.presentationMode) var presentationMode

    @State private var eventName: String = ""
    @State private var eventDescription: String = ""
    @State private var eventDate: Date = Date()
    @State private var eventAddress: String = ""
    @State private var selectFromMap: Bool = false
    @State private var navigateToMap = false
    @State private var selectedLocation: CLLocationCoordinate2D? // Store selected location

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Details")) {
                    TextField("Event Name", text: $eventName)
                    TextField("Description", text: $eventDescription)
                    DatePicker("Date", selection: $eventDate, displayedComponents: .date)
                }
                
                Section(header: Text("Location")) {
                    Toggle("Select from Map", isOn: $selectFromMap)
                    if selectFromMap {
                        Button("Choose Location on Map") {
                            navigateToMap = true
                        }
                    } else {
                        TextField("Address", text: $eventAddress)
                    }
                }
                
                Button(action: {
                    saveEvent()
                }) {
                    Text("Save Event")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Add Event")
            .background(
                NavigationLink(
                    destination: MapView(selectedLocation: $selectedLocation, navigateToMap: $navigateToMap),
                    isActive: $navigateToMap
                ) {
                    EmptyView()
                }
            )
        }
    }
    
    func saveEvent() {
        // Use selectedLocation if available, otherwise use eventAddress
        let address = selectFromMap && selectedLocation != nil ? "Lat: \(selectedLocation!.latitude), Lon: \(selectedLocation!.longitude)" : eventAddress
        
        appModel.addEvent(name: eventName, description: eventDescription, date: eventDate, address: address)
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView()
            .environmentObject(AppModel()) // Inject appModel for preview
    }
}

func shareStarredList(appModel: AppModel) {
    var itemsToShare: [Any] = []
    
    for location in appModel.starredLocations {
        let locationInfo = """
        Tag: \(location.tag)
        Note: \(location.description ?? "No description")
        Coordinates: Lat \(location.latitude), Lon \(location.longitude)
        """
        
        itemsToShare.append(locationInfo)
        
        if let imageData = location.imageData, let image = UIImage(data: imageData) {
            itemsToShare.append(image) // Add image to share items
        }
    }
    
    let activityController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
    
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let rootViewController = windowScene.windows.first?.rootViewController {
        rootViewController.present(activityController, animated: true, completion: nil)
    }
}

