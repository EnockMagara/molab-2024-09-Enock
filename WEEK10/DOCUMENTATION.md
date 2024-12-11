# MapJournal App Documentation

## Table of Contents
1. [Overview](#overview)
2. [Features](#features)
3. [Architecture](#architecture)
4. [Development Journey](#development-journey)
   - [Week 9: Project Setup and Planning](#week-1-project-setup-and-planning)
   - [Week 10: User Interface Development](#week-2-user-interface-development)
   - [Week 11: Data Management and Authentication](#week-12-data-management-and-authentication)
   - [Week 13: Location Services and Sharing](#week-4-location-services-and-sharing)
5. [Getting Started](#getting-started)
6. [User Interface](#user-interface)
7. [Data Management](#data-management)
8. [Authentication](#authentication)
9. [Troubleshooting](#troubleshooting)
10. [Future Enhancements](#future-enhancements)

## Overview
MapJournal is an iOS app that allows users to discover, save, and share their favorite places. Users can add locations, share experiences, and explore the world around them. The app integrates with Google Sign-In for user authentication and uses Firebase for data storage and management.

## Features
- User authentication with Google Sign-In
- Interactive map view to explore and add locations
- Ability to star and save favorite locations
- Detailed information for each starred location, including tags, descriptions, and images
- Sharing functionality to share starred locations with others
- Profile view to manage user information and sign out

## Architecture
The MapJournal app is built using the following technologies and frameworks:
- SwiftUI: Used for building the user interface and handling user interactions
- MapKit: Provides the map view and location-related functionality
- CoreLocation: Used for accessing the user's location and geocoding
- Firebase: Used for data storage (Firestore) and user authentication (Google Sign-In)
- GoogleSignIn: Handles user authentication with Google Sign-In

The app follows the MVVM (Model-View-ViewModel) architectural pattern, separating the concerns of data management, user interface, and business logic.

## Development Journey

### Week 9: Project Setup and Planning
- Set up the Xcode project and created the basic structure for the MapJournal app.
- Defined the app's features, user interface, and data models.
- Researched and selected the necessary frameworks and libraries, such as SwiftUI, MapKit, CoreLocation, and Firebase.
- Created a project repository on GitHub to track progress and collaborate with the development team.

### Week 10: User Interface Development
- Designed and implemented the main views of the app using SwiftUI.
- Created the Welcome View with a sign-in button and a brief description of the app.
- Developed the Main View with a tab view containing the Maps, Starred, and Profile tabs.
- Implemented the Map View with an interactive map using MapKit and the ability to add new locations.
- Created the Starred List View to display the user's starred locations.
- Designed the Profile View to show user information and provide options to edit the profile and sign out.
- Implemented navigation between views using SwiftUI's navigation system.
- Challenges faced:
  - Deciding on the overall layout and user flow of the app.
  - Ensuring a consistent and visually appealing design across all views.
  - Integrating MapKit and handling user interactions with the map view.
- Creative decisions:
  - Opted for a clean and minimalistic design to focus on the app's core functionality.
  - Used a tab view for easy navigation between the main sections of the app.
  - Implemented a floating action button on the map view to allow users to quickly add new locations.
- Relevant code:
  - [ContentView.swift](https://github.com/EnockMagara/molab-2024-09-Enock/blob/main/WEEK10/communityMaps/ContentView.swift)

### Week 11: Data Management and Authentication
- Integrated Firebase into the app for data storage and user authentication.
- Set up Firestore to store starred locations and event data.
- Implemented the `AppModel` class to manage data operations and updates.
- Created the `StarredLocation` and `Event` data models to represent the app's data.
- Implemented functions to fetch, add, and remove starred locations and events.
- Integrated Google Sign-In for user authentication using the `GoogleSignIn` framework.
- Developed the `SignInWithGoogleHelper` class to handle the sign-in process and retrieve user profile information.
- Challenges faced:
  - Designing the data models to efficiently store and retrieve data from Firestore.
  - Handling asynchronous data operations and updating the user interface accordingly.
  - Implementing a secure and user-friendly authentication flow with Google Sign-In.
- Creative decisions:
  - Chose Firebase for its ease of use, real-time data synchronization, and built-in authentication support.
  - Decided to use Google Sign-In for a seamless and familiar authentication experience for users.
  - Structured the data models to allow for efficient querying and updating of starred locations and events.
- Relevant code:
  - [AppModel.swift](https://github.com/EnockMagara/molab-2024-09-Enock/blob/main/WEEK10/communityMaps/AppModel.swift)

### Week 12: Location Services and Sharing
- Implemented location services using CoreLocation to access the user's current location.
- Developed the `LocationManager` class to handle location updates and region monitoring.
- Added the ability for users to center the map on their current location.
- Implemented geocoding functionality to convert coordinates to human-readable addresses.
- Created the sharing feature to allow users to share their starred locations with others.
- Integrated the `UIActivityViewController` to present sharing options to the user.
- Challenges faced:
  - Ensuring proper handling of location permissions and user privacy.
  - Accurately converting coordinates to addresses using geocoding.
  - Designing a user-friendly sharing flow that supports multiple sharing options.
- Creative decisions:
  - Decided to use CoreLocation for its simplicity and native integration with iOS.
  - Implemented a custom `LocationManager` class to encapsulate location-related functionality.
  - Chose to support multiple sharing options, such as messaging, email, and social media, to provide flexibility to users.
- Relevant code:
  - [LocationManager.swift](https://github.com/EnockMagara/molab-2024-09-Enock/blob/main/WEEK10/communityMaps/LocationManager.swift)

Throughout the development process, regular code reviews and testing were conducted to ensure code quality, identify and fix bugs, and maintain a stable app. The app underwent multiple iterations based on user feedback and testing results to refine the user experience and add new features.

The MapJournal app development journey showcases the thought process, challenges, and creative decisions made during each week of development. The app's source code can be found in the [GitHub repository](https://github.com/EnockMagara/molab-2024-09-Enock/tree/main/WEEK10/communityMaps), which reflects the progress and evolution of the app over time.

## Getting Started
To run the MapJournal app locally, follow these steps:
1. Clone the project repository from [GitHub](https://github.com/your-repo-url).
2. Open the project in Xcode.
3. Set up a Firebase project and add the necessary configuration files (`GoogleService-Info.plist`).
4. Configure the Google Sign-In credentials in the Firebase project.
5. Build and run the app on a simulator or physical device.

## User Interface
The MapJournal app consists of the following main views:
- Welcome View: Displays a welcome message and a button to sign in with Google.
- Main View: Contains a tab view with three tabs - Maps, Starred, and Profile.
  - Maps Tab: Shows an interactive map view where users can explore and add locations.
  - Starred Tab: Displays a list of starred locations saved by the user.
  - Profile Tab: Allows users to view and edit their profile information and sign out.
- Map View: Displays a map with annotations for starred locations. Users can tap on the map to add new locations.
- Starred List View: Shows a list of starred locations with details such as tags, descriptions, and images.
- Profile View: Displays the user's profile information and provides options to edit the profile and sign out.

## Data Management
The MapJournal app uses Firebase Firestore for data storage and management. The main data models include:
- StarredLocation: Represents a starred location with properties such as latitude, longitude, tag, address, description, and image URL.
- Event: Represents an event with properties like name, description, date, and address.

The app communicates with Firestore using the Firebase SDK to fetch and store data. The `AppModel` class acts as the central data manager, handling data operations and updates.

## Authentication
User authentication in the MapJournal app is handled by Google Sign-In. The app uses the `GoogleSignIn` framework to authenticate users and retrieve their profile information. The authentication flow is managed by the `SignInWithGoogleHelper` class, which handles the sign-in process and returns the user's authentication tokens and profile details.


## Troubleshooting
If you encounter any issues while running or using the MapJournal app, consider the following troubleshooting steps:
- Ensure that you have a stable internet connection for data synchronization with Firebase.
- Double-check your Firebase configuration and ensure that the necessary credentials are correctly set up.
- Verify that you have the required permissions for location access and photo library access.
- Check the Xcode console for any error messages or logs that may provide insights into the issue.
- Refer to the Firebase documentation for any Firebase-related issues or error codes.

## Future Enhancements
Here are some potential future enhancements for the MapJournal app:
- Implement user-to-user sharing and collaboration features.
- Add support for offline data caching and synchronization.
- Integrate with additional social media platforms for sharing and authentication.
- Implement search functionality to find specific locations or events.
- Enhance the user interface with animations and visual improvements.
- Provide personalized recommendations based on user preferences and history.