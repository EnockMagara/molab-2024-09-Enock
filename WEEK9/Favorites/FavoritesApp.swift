//
//  FavoritesApp.swift
//  Favorites
//
//  Created by Enock Mecheo on 07/11/2024.
//


import SwiftUI

@main
struct FavoritesApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appModel)
        }
    }
}
