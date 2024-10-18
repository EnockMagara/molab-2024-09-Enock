import SwiftUI

// Define the main content view for the EcoTrack app
struct ContentView: View {
    var body: some View {
        // NavigationView is used to create a navigation bar at the top of the screen
        NavigationView {
            // VStack is used to stack views vertically
            VStack {
                // Text view for the welcome message with a large title font and padding
                Text("Welcome to EcoTrack")
                    .font(.largeTitle) // Set the font to large title
                    .padding() // Add padding around the text
                
                // NavigationLink to CalculatorView with a custom view for the link
                NavigationLink(destination: CalculatorView()) {
                    // HStack to stack views horizontally
                    HStack {
                        // Image for the icon
                        Image(systemName: "plus.square.fill.on.square.fill")
                            .imageScale(.large) // Set the image scale to large
                            .padding() // Add padding around the image
                        // Text for the link
                        Text("Calculate Carbon Footprint")
                            .font(.headline) // Set the font to headline
                    }
                }
                .padding() // Add padding around the NavigationLink
                
                // NavigationLink to AlternativesView with a custom view for the link
                NavigationLink(destination: AlternativesView()) {
                    // HStack to stack views horizontally
                    HStack {
                        // Image for the icon
                        Image(systemName: "leaf")
                            .imageScale(.large) // Set the image scale to large
                            .padding() // Add padding around the image
                        // Text for the link
                        Text("Find Sustainable Alternatives")
                            .font(.headline) // Set the font to headline
                    }
                }
                .padding() // Add padding around the NavigationLink
                
                // NavigationLink to ChallengesView with a custom view for the link
                NavigationLink(destination: ChallengesView()) {
                    // HStack to stack views horizontally
                    HStack {
                        // Image for the icon
                        Image(systemName: "person.2")
                            .imageScale(.large) // Set the image scale to large
                            .padding() // Add padding around the image
                        // Text for the link
                        Text("Join Community Challenges")
                            .font(.headline) // Set the font to headline
                    }
                }
                .padding() // Add padding around the NavigationLink
            }
        }
    }
}