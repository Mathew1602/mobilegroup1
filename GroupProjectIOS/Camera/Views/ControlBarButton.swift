//
//  Untitled.swift
//  GroupProjectIOS
//
//  Created by Mathew Boyd on 2024-11-10.
//

import SwiftUI

struct ControlBarButton: View {
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(label)
                .tint(.white)
                .font(.title3)
                .fontWeight(.semibold)
        }
    }
}
