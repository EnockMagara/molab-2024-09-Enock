import SwiftUI
import PhotosUI
import CoreLocation
import MapKit
import GoogleSignIn
import GoogleSignInSwift
import UIKit
import FirebaseFirestore

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct MainView: View {
    @StateObject private var appModel = AppModel() // Initialize the app model
    @State private var showAddEventView = false // State to control navigation
    @State private var selectedLocation: CLLocationCoordinate2D? // State for selected location
    @State private var navigateToMap = false // State to control navigation
    @State private var selectedImage: PhotosPickerItem? // State for the selected image item
    @State private var showImagePicker = false // State to control image picker
    @State private var selectedImageData: Data? // State for the selected image data
    @State private var selectedTab = 0
    @State private var isSignedIn = false // Track sign-in status
    @State private var googleSignInResult: GoogleSignInResult? // Manage Google Sign-In result

    var body: some View {
        if isSignedIn {
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
                    StarredListView(selectedTab: $selectedTab, selectedLocation: $selectedLocation)
                        .navigationTitle("Starred") // Set the title for this tab
                }
                .tabItem {
                    Image(systemName: "star")
                    Text("Starred")
                }
                .tag(1) // Update tag to 1
                
                NavigationView {
                    ProfileView(isSignedIn: $isSignedIn, googleSignInResult: $googleSignInResult) // Pass binding
                        .navigationTitle("Profile") // Set the title for this tab
                }
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
                .tag(2) // Update tag to 2
            }
            .environmentObject(appModel) // Provide the app model to subviews
            .frame(maxHeight: .infinity) // Allow TabView to take available space

            .sheet(isPresented: $showAddEventView) {
                AddEventView()
                    .environmentObject(appModel) // Inject appModel into AddEventView
            }
        } else {
            WelcomeView(isSignedIn: $isSignedIn, googleSignInResult: $googleSignInResult) // Pass binding
        }
    }
}

// Placeholder views for Profile, Events, and Starred List
struct ProfileView: View {
    @Binding var isSignedIn: Bool
    @Binding var googleSignInResult: GoogleSignInResult?
    @State private var showSignInError = false

    var body: some View {
        VStack(spacing: 20) {
            // Profile information card
            VStack(alignment: .leading, spacing: 10) {
                if let result = googleSignInResult {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title)
                        Text("Username: \(result.displayName ?? "Unknown")")
                            .font(.headline)
                    }
                    Text("Email: \(result.email ?? "No email")")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    Text("Not signed in")
                        .font(.headline)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.secondarySystemBackground)))
            .padding(.horizontal, 20)

            // Sign out button card
            Button(action: {
                Task {
                    do {
                        if googleSignInResult == nil {
                            let helper = SignInWithGoogleHelper(GIDClientID: "230807118556-seejp6ota1q96kmmf9fi8qq6il6n1492.apps.googleusercontent.com")
                            googleSignInResult = try await helper.signIn()
                        } else {
                            GIDSignIn.sharedInstance.signOut()
                            googleSignInResult = nil
                            isSignedIn = false
                        }
                    } catch {
                        showSignInError = true
                    }
                }
            }) {
                Text(googleSignInResult == nil ? "Sign in with Google" : "Sign out")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .shadow(color: .gray, radius: 5, x: 0, y: 2)
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .navigationTitle("Profile")
        .alert("Sign-In Error", isPresented: $showSignInError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Failed to sign in with Google.")
        }
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
        ProfileView(isSignedIn: .constant(false), googleSignInResult: .constant(nil))
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
    @Binding var selectedTab: Int
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @State private var navigateToMap = false
    @State private var selectedLocations: Set<UUID> = [] // Track selected locations
    @State private var locationToDelete: StarredLocation? // Track location to delete
    @State private var showDeleteConfirmation = false // Show confirmation alert

    var body: some View {
        VStack {
            Text("Tap a card to view it on the map")
                .font(.headline)
                .padding()
                .background(Color.white.opacity(0.7))
                .cornerRadius(10)
                .padding(.top, 0)

            List {
                ForEach(appModel.starredLocations, id: \.id) { location in
                    HStack {
                        Image(systemName: selectedLocations.contains(location.id) ? "checkmark.square" : "square")
                            .foregroundColor(selectedLocations.contains(location.id) ? .blue : .gray)
                            .onTapGesture {
                                if selectedLocations.contains(location.id) {
                                    selectedLocations.remove(location.id)
                                } else {
                                    selectedLocations.insert(location.id)
                                }
                            }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                if let imageURL = location.imageURL {
                                    AsyncImage(url: URL(string: imageURL)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                            .shadow(radius: 4)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .onAppear {
                                        print("Loading image from URL: \(imageURL)") // Debugging output
                                    }
                                } else {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.orange)
                                        .onAppear {
                                            print("No image URL for location: \(location.tag)") // Debugging output
                                        }
                                }
                                Text("Tag: \(location.tag)")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            Text("Address: \(location.address)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Description: \(location.description ?? "No description")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Lat: \(location.latitude), Lon: \(location.longitude)")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        .onTapGesture {
                            selectedLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                            selectedTab = 0
                            navigateToMap = true
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemBackground)))
                    .shadow(color: .gray.opacity(0.5), radius: 4, x: 0, y: 2)
                    .padding(.vertical, 5)
                }
                .onDelete(perform: confirmDelete)
            }
        }
        .navigationTitle("Starred Locations")
        .navigationBarItems(trailing: Button(action: {
            shareStarredList(appModel: appModel, selectedLocations: selectedLocations)
        }) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Share")
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 10)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .shadow(color: .gray.opacity(0.5), radius: 2, x: 0, y: 2)
        })
        .padding(.top, 20)
        .background(Color(UIColor.systemGroupedBackground))
        .background(
            NavigationLink(
                destination: MapView(selectedLocation: $selectedLocation, navigateToMap: $navigateToMap),
                isActive: $navigateToMap
            ) {
                EmptyView()
            }
        )
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Location"),
                message: Text("Are you sure you want to delete this location?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let location = locationToDelete {
                        deleteLocation(location)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func confirmDelete(at offsets: IndexSet) {
        if let index = offsets.first {
            locationToDelete = appModel.starredLocations[index]
            showDeleteConfirmation = true
        }
    }

    private func deleteLocation(_ location: StarredLocation) {
        if let index = appModel.starredLocations.firstIndex(where: { $0.id == location.id }) {
            // Remove from local list
            appModel.starredLocations.remove(at: index)
            
            // Remove from Firestore
            let db = Firestore.firestore()
            db.collection("starredLocations").whereField("latitude", isEqualTo: location.latitude)
                .whereField("longitude", isEqualTo: location.longitude)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Error finding document: \(error.localizedDescription)")
                        return
                    }
                    
                    snapshot?.documents.forEach { document in
                        document.reference.delete { error in
                            if let error = error {
                                print("Error deleting document: \(error.localizedDescription)")
                            } else {
                                print("Document successfully deleted")
                            }
                        }
                    }
                }
        }
    }
}

func shareStarredList(appModel: AppModel, selectedLocations: Set<UUID>) {
    var itemsToShare: [Any] = []
    
    for location in appModel.starredLocations where selectedLocations.contains(location.id) {
        let locationInfo = """
        Tag: \(location.tag)
        Note: \(location.description ?? "No description")
        Address: \(location.address)
        Coordinates: Lat \(location.latitude), Lon \(location.longitude)
        """
        
        itemsToShare.append(locationInfo)
        
        if let imageURL = location.imageURL, let url = URL(string: imageURL), let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
            itemsToShare.append(image)
        }
    }
    
    let activityController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
    
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let rootViewController = windowScene.windows.first?.rootViewController {
        rootViewController.present(activityController, animated: true, completion: nil)
    }
}

struct MapView: View {
    @EnvironmentObject var appModel: AppModel
    @StateObject var locationManager = LocationManager()
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @Binding var navigateToMap: Bool

    @State private var showAlert = false
    @State private var tag: String = ""
    @State private var description: String = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var showImagePicker = false
    @State private var selectedImageData: Data?
    @State private var initialRegion: MKCoordinateRegion?
    @State private var selectedStarredLocation: StarredLocation?
    @State private var showImageModal = false
    @State private var isViewingFromList = false // Track if viewing from list

    var body: some View {
        ZStack {
            Map(coordinateRegion: $locationManager.region, annotationItems: appModel.starredLocations) { location in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)) {
                    Button(action: {
                        selectedStarredLocation = location
                        showImageModal = true
                    }) {
                        if let imageURL = location.imageURL {
                            AsyncImage(url: URL(string: imageURL)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                    .shadow(radius: 4)
                            } placeholder: {
                                ProgressView()
                            }
                        } else {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                }
            }
            .onAppear {
                if initialRegion == nil {
                    locationManager.centerUserLocation()
                    initialRegion = locationManager.region
                }
            }
            .onChange(of: selectedLocation) { newLocation in
                if let newLocation = newLocation {
                    locationManager.region.center = newLocation
                }
            }
            .gesture(
                TapGesture()
                    .onEnded { _ in
                        if !isViewingFromList {
                            let center = locationManager.region.center
                            selectedLocation = center
                            selectedImageData = nil
                            showAlert = true
                        }
                    }
            )
            .alert("Star the Location?", isPresented: $showAlert) {
                TextField("Enter a tag, e.g., Great place to eat shawarma", text: $tag)
                TextField("Enter a description, e.g., Best shawarma in town!", text: $description)
                Button("Select Image (Optional)") {
                    showImagePicker = true
                }
                Button("Star") {
                    if let location = selectedLocation {
                        appModel.starLocation(
                            latitude: location.latitude,
                            longitude: location.longitude,
                            tag: tag,
                            description: description,
                            imageData: selectedImageData
                        )
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Enter a tag and description for this location. Optionally, you can share an image of the location.")
            }
            .sheet(isPresented: $showImagePicker, onDismiss: {
                showAlert = true
            }) {
                PhotosPicker(selection: $selectedImage, matching: .images) {
                    Text("Select an Image")
                }
                .onChange(of: selectedImage) { newItem in
                    if let newItem = newItem {
                        Task {
                            if let data = try? await newItem.loadTransferable(type: Data.self) {
                                selectedImageData = data
                                showImagePicker = false
                            }
                        }
                    }
                }
            }


            VStack {
                Text("Tap on the map to star a location")
                    .font(.headline)
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.top, 10)
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button(action: {
                        locationManager.centerUserLocation()
                    }) {
                        Image(systemName: "star.fill")
                            .font(.title)
                            .foregroundColor(.yellow)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.trailing)
                }
            }
        }
        .sheet(item: $selectedStarredLocation) { location in
            if let imageURL = location.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
            } else {
                Text("No image available")
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

struct GoogleSignInResult {
    let idToken: String
    let accessToken: String
    let email: String?
    let firstName: String?
    let lastName: String?
    let fullName: String?
    let profileImageUrl: URL?
    
    var displayName: String? {
        fullName ?? firstName ?? lastName
    }
    
    init?(result: GIDSignInResult) {
        guard let idToken = result.user.idToken?.tokenString else {
            return nil
        }

        self.idToken = idToken
        self.accessToken = result.user.accessToken.tokenString
        self.email = result.user.profile?.email
        self.firstName = result.user.profile?.givenName
        self.lastName = result.user.profile?.familyName
        self.fullName = result.user.profile?.name
        
        let dimension = round(400 * UIScreen.main.scale)
        
        if result.user.profile?.hasImage == true {
            self.profileImageUrl = result.user.profile?.imageURL(withDimension: UInt(dimension))
        } else {
            self.profileImageUrl = nil
        }
    }
}

final class SignInWithGoogleHelper {
    
    init(GIDClientID: String) {
        let config = GIDConfiguration(clientID: GIDClientID)
        GIDSignIn.sharedInstance.configuration = config
    }
        
    @MainActor
    func signIn(viewController: UIViewController? = nil) async throws -> GoogleSignInResult {
        guard let topViewController = viewController ?? UIApplication.topViewController() else {
            throw GoogleSignInError.noViewController
        }
                
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topViewController)
        
        guard let result = GoogleSignInResult(result: gidSignInResult) else {
            throw GoogleSignInError.badResponse
        }
        
        return result
    }
    
    private enum GoogleSignInError: LocalizedError {
        case noViewController
        case badResponse
        
        var errorDescription: String? {
            switch self {
            case .noViewController:
                return "Could not find top view controller."
            case .badResponse:
                return "Google Sign In had a bad response."
            }
        }
    }
}

extension UIApplication {
    static func topViewController(base: UIViewController? = UIApplication.shared.connectedScenes
                                    .filter { $0.activationState == .foregroundActive }
                                    .compactMap { $0 as? UIWindowScene }
                                    .first?.windows
                                    .filter { $0.isKeyWindow }.first?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

struct WelcomeView: View {
    @Binding var isSignedIn: Bool
    @Binding var googleSignInResult: GoogleSignInResult?
    @State private var showSignInError = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                Spacer() // Push content down

                // Welcome message with large title font
                Text("Welcome to MapJournal")
                    .font(.largeTitle)
                    .fontWeight(.bold) // Make the text bold
                    .foregroundColor(.primary) // Use primary color for text

                // Description text with body font
                Text("Discover and save your favorite places. Add locations, share experiences, and explore the world around you.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary) // Use secondary color for text
                    .padding(.horizontal, 30) // Add horizontal padding

                Spacer() // Push content to the top

                // Google Sign-In button
                GoogleSignInButton {
                    Task {
                        do {
                            let helper = SignInWithGoogleHelper(GIDClientID: "230807118556-seejp6ota1q96kmmf9fi8qq6il6n1492.apps.googleusercontent.com")
                            googleSignInResult = try await helper.signIn()
                            isSignedIn = true
                        } catch {
                            showSignInError = true
                        }
                    }
                }
                .frame(width: 250, height: 50) // Set button size
                .background(Color.blue) // Set button background color
                .foregroundColor(.white) // Set button text color
                .cornerRadius(10) // Round button corners
                .padding(.bottom, 50) // Add bottom padding

                Spacer() // Push content to the bottom
            }
            .frame(height: geometry.size.height * 0.75) // Set height to 75% of the screen
            .background(Color(UIColor.systemBackground)) // Set background color
            .edgesIgnoringSafeArea(.all) // Extend background to edges
            .alert("Sign-In Error", isPresented: $showSignInError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Failed to sign in with Google.")
            }
        }
    }
}

