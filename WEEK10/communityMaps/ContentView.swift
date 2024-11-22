import SwiftUI
import PhotosUI
import CoreLocation
import MapKit

struct MainView: View {
    @StateObject private var appModel = AppModel() // Initialize the app model
    @State private var showAddEventView = false // State to control navigation

    var body: some View {
        TabView {
            NavigationView {
                MapView()
                    .navigationTitle("Maps") // Set the title for this tab
            }
            .tabItem {
                Image(systemName: "map")
                Text("Maps")
            }
            
            NavigationView {
                ProfileView()
                    .navigationTitle("Profile") // Set the title for this tab
            }
            .tabItem {
                Image(systemName: "person")
                Text("Profile")
            }
            
            NavigationView {
                EventsView()
                    .navigationTitle("Events") // Set the title for this tab
            }
            .tabItem {
                Image(systemName: "calendar")
                Text("Events")
            }
            
            NavigationView {
                StarredListView()
                    .navigationTitle("Starred") // Set the title for this tab
            }
            .tabItem {
                Image(systemName: "star")
                Text("Starred")
            }
        }
        .environmentObject(appModel) // Provide the app model to subviews
        .frame(maxHeight: .infinity) // Allow TabView to take available space

        Button(action: {
            showAddEventView = true // Trigger navigation
        }) {
            Text("Add Event")
        }
        .sheet(isPresented: $showAddEventView) {
            AddEventView()
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
    @State private var showingAddEventView = false

    var body: some View {
        NavigationView {
            ZStack {
                // Map view
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
                                        showingAddEventView = true // Show detail view
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
                                        showingAddEventView = true // Show detail view
                                    }
                            }
                            Text(location.name)
                                .fixedSize()
                        }
                    }
                }
                .ignoresSafeArea() // Extend map to safe area

                // Overlay for search and buttons
                VStack {
                    HStack {
                        // Search field
                        TextField("Search for maps or events...", text: .constant(""))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)

                        // Profile icon
                        Button(action: {
                            appModel.showingProfile = true // Set state to show Profile view
                        }) {
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding()
                        }
                    }
                    .padding()

                    // Buttons below the search bar
                    HStack {
                        // Create Map button
                        Button(action: {
                            // Action for Create Map
                        }) {
                            Label("Create Map", systemImage: "map")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding()

                        Spacer()

                        // Add Event button
                        Button(action: {
                            showingAddEventView = true // Trigger sheet presentation
                        }) {
                            Label("Add Event", systemImage: "calendar")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding()
                        .sheet(isPresented: $showingAddEventView) {
                            AddEventView()
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }

                // Navigation link to ProfileView
                NavigationLink(destination: ProfileView(), isActive: $appModel.showingProfile) {
                    EmptyView()
                }
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

struct AddEventView: View {
    @State private var eventName: String = "" // State for event name
    @State private var eventDescription: String = "" // State for event description
    @State private var eventDate: Date = Date() // State for event date
    @State private var eventAddress: String = "" // State for event address

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Details")) {
                    TextField("Event Name", text: $eventName) // Input for event name
                    TextField("Description", text: $eventDescription) // Input for event description
                    DatePicker("Date", selection: $eventDate, displayedComponents: .date) // Date picker for event date
                }
                
                Section(header: Text("Location")) {
                    TextField("Address", text: $eventAddress) // Input for event address
                }
                
                Button(action: {
                    print("Save Event button tapped") // Debug print
                    saveEvent()
                }) {
                    Text("Save Event")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Add Event") // Title of the navigation view
            .onAppear {
                print("AddEventView appeared") // Debug print
            }
        }
    }
    
    func saveEvent() {
        // Logic to save the event
        print("Event Saved: \(eventName), \(eventDescription), \(eventDate), \(eventAddress)") // Debug print
    }
}

struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView()
    }
}

