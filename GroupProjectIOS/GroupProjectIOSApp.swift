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

    return true
  }
}

@main
struct GroupProjectIOSApp: App {
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var foodViewModel = FoodViewModel()
    @StateObject private var foodCategoryViewModel = FoodCategoryViewModel()
    
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
                    .tabItem{
                        Label("Search", systemImage: "magnifyingglass")
                    }
                NearestGroceryView().tabItem{
                    Label("List", systemImage: "map")
                }

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                        }
                  }
            .environmentObject(foodCategoryViewModel)
            .environmentObject(foodViewModel)
        }
    }
}
