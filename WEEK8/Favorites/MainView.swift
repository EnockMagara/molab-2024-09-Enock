
import SwiftUI
import MapKit

struct MainView: View {
    @StateObject private var appModel = AppModel() // Initialize the app model
    @State private var isListView = false // State to toggle between map and list views

    var body: some View {
        NavigationView {
            VStack {
                if isListView {
                    ListView() // Show list view if isListView is true
                } else {
                    MapView() // Show map view if isListView is false
                }
                ToggleViewButton(isListView: $isListView) // Button to toggle views
            }
            .navigationTitle("Favorites") // Set the navigation title
            .environmentObject(appModel) // Provide the app model to subviews
        }
    }
}

struct MapView: View {
    @EnvironmentObject var appModel: AppModel // Access the app model

    var body: some View {
        Map(coordinateRegion: $appModel.mapRegion, annotationItems: appModel.locations) { location in
            MapAnnotation(coordinate: location.coordinate) {
                VStack {
                    Image(systemName: "star.circle")
                        .resizable()
                        .foregroundColor(.red)
                        .frame(width: 44, height: 44)
                        .background(.white)
                        .clipShape(Circle())
                    Text(location.name)
                        .fixedSize()
                }
                .onTapGesture {
                    appModel.selectedPlace = location // Set selected place on tap
                }
            }
        }
        .ignoresSafeArea() // Extend map to safe area
    }
}

struct ListView: View {
    @EnvironmentObject var appModel: AppModel // Access the app model

    var body: some View {
        List {
            ForEach(appModel.locations) { location in
                Text(location.name)
                    .onTapGesture {
                        appModel.selectedPlace = location // Set selected place on tap
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
            isListView.toggle() // Toggle the view state
        }) {
            Text(isListView ? "Show Map" : "Show List") // Change button text based on state
                .padding()
                .background(.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
    }
}

