//
//  GroupProjectIOSApp.swift
//  GroupProjectIOS
//
//
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    
    @StateObject private var foodViewModel = FoodViewModel()
    @StateObject private var foodCategoryViewModel = FoodCategoryViewModel()
    
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      
  func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
          return .portrait // Lock the orientation to portrait
      }

    return true
  }
}

@main
struct GroupProjectIOSApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var foodViewModel = FoodViewModel()
    @StateObject private var foodCategoryViewModel = FoodCategoryViewModel()
    @State private var imageData: Data? = nil
    
    @AppStorage("useSystemDefault") private var useSystemDefault: Bool = true
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }

                AddFoodView()
                    .tabItem {
                        Label("Add", systemImage: "plus.circle")
                    }

                SearchResultsView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    /* Fix camera view in tabview if I have time - Mathew
                CameraViewInTabView(isPresented: .constant(true), imageData: $imageData)
                    .tabItem {
                        Label("Camera", systemImage: "camera")
                    }
                     */
                
                NearestGroceryView()
                    .tabItem {
                    Label("Find Store", systemImage: "map")
                }
                

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
            .environmentObject(foodCategoryViewModel)
            .environmentObject(foodViewModel)
            .preferredColorScheme(useSystemDefault ? nil : (isDarkMode ? .dark : .light))
        }
    }
}
