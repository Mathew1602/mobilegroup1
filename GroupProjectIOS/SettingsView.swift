//
//  SettingsView.swift
//  GroupProjectIOS
//
//  Created by Xiaoya Zou on 2024-11-06.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        
        NavigationStack{
            
            VStack {
                Toggle("Enable Dark Mode", isOn: $isDarkMode)
                    .padding()
                Spacer()
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(FoodCategoryViewModel())
        .environmentObject(FoodViewModel())
}
