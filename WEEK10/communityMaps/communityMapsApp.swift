//
//  communityMapsApp.swift
//  communityMaps
//
//  Created by Enock Mecheo on 14/11/2024.
//

import SwiftUI

@main
struct communityMapsAppApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appModel)
        }
    }
}