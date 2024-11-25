//
//  SettingsView.swift
//  GroupProjectIOS
//
//  Created by Xiaoya Zou on 2024-11-06.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("useSystemDefault") private var useSystemDefault = true
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        
        NavigationStack {
            
            VStack {
                Toggle("Use System Default theme", isOn: $useSystemDefault)
                    .padding()
                
                if !useSystemDefault {
                    Toggle("Enable Dark Mode", isOn: $isDarkMode)
                        .padding()
                }
                
                Spacer()
            }
            .onAppear {
                if useSystemDefault {
                    isDarkMode = (colorScheme == .dark)
                }
            }
            .preferredColorScheme(useSystemDefault ? nil : (isDarkMode ? .dark : .light))
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(FoodCategoryViewModel())
        .environmentObject(FoodViewModel())
}
