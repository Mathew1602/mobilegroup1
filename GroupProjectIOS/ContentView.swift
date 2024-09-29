//
//  ContentView.swift
//  GroupProjectIOS
//  
//
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "house")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, Group Members :)")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
