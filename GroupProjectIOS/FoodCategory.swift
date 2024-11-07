//
//  FoodCategory.swift
//  GroupProjectIOS
//
//  Created by Xiaoya Zou on 2024-11-06.
//

import Foundation
import FirebaseFirestore

struct FoodCategory: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var imageName : String
}

