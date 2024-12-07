//
//  communityMapsApp.swift
//  communityMaps
//
//  Created by Enock Mecheo on 14/11/2024.
//

import SwiftUI
import FirebaseCore
import Firebase
import UIKit
import GoogleSignIn

@main
struct communityMapsAppApp: App {
    @StateObject private var appModel = AppModel()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appModel)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}