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
            Text("Hello! Xiaoya is here")
            Text("Hello! Mathew is here")
            Text("Merge branch to main from xcode")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
